//
//  TextFields.swift
//  Splitter
//
//  Created by Michael Berk on 3/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

extension NSView {
	func findVC() -> NSViewController? {
		if let nextR = self.nextResponder as? NSViewController {
				   return nextR
		} else if let nextR = self.nextResponder as? NSView {
		   return nextR.findVC()
		} else {
		   return nil
		}
	}
}
protocol Themeable {
	func setColor(run: SplitterRun)
	func setColorObserver()
	var themeable: Bool {get set}
}
extension Themeable {
	static var runKey: String {
		return "run"
	}
	func setColorObserver() {
		NotificationCenter.default.addObserver(forName: .updateComponentColors, object: nil, queue: nil, using: { notification in
			if themeable, let run = (notification.userInfo?[Self.runKey])! as? SplitterRun {
				setColor(run: run)
			}
		})
	}
}

class MetadataField: ThemedTextField  {
	
	private var observerSet = false
	
	override func setColor(run: SplitterRun) {
		//Fields not in VC won't be colored
		if self.controller == .mainViewController {
			let vc = self.findVC() as! ViewController
			self.textColor = vc.run.textColor
		}
	}
	
	override func textDidChange(_ notification: Notification) {
		super.textDidChange(notification)
		loadData()
		
	}
	var controller: metaController? {
		if (findVC() as? ViewController) != nil {
			return .mainViewController
		} else if (findVC() as? InfoOptionsViewController) != nil {
			return .infoViewController
		} else if let _ = findVC() as? RunOptionsViewController {
			return .runOptionsViewController
		}
		return nil
	}
	
	func loadData() {
		switch controller {
		case .mainViewController:
			let c = findVC() as! ViewController
			c.updateRun()
			if let tabVC = c.infoPanelPopover?.contentViewController as? InfoPopoverTabViewController {
				if let infoVC = tabVC.tabView.selectedTabViewItem?.viewController as? InfoOptionsViewController {
					infoVC.getDataFromMain()
				}
			}
		default:
			let c = findVC() as! InfoOptionsViewController
			c.sendDataToMain()
		}
	}
}
class ThemedImage: NSImageView, Themeable {
	var themeable: Bool = true
	var run: SplitterRun!
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setColorObserver()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setColorObserver()
	}
	func setColor(run: SplitterRun) {
		if let image = self.image, image.isTemplate {
			self.contentTintColor = run.textColor
		}
	}
}

///Game Icon
class MetadataImage: ThemedImage {
	var controller: metaController?
	override var themeable: Bool {
		get {
			if run.gameIcon == nil {
				return true
			}
			return false
		}
		set {}
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	func setup() {
		self.target = self
		self.action = #selector(imageChanged(_:))
		NotificationCenter.default.addObserver(forName: .gameIconEdited, object: nil, queue: nil, using: { notification in
			self.image = self.run.gameIcon
			self.setPlaceholderImage()
			self.setColor(run: self.run)
		})
	}
	override func setColor(run: SplitterRun) {
		if themeable {
			self.contentTintColor = run.textColor
		}
	}
	
	func setPlaceholderImage() {
		if self.image == nil {
			self.image = .gameControllerIcon
		}
	}
	
	@objc func imageChanged(_ sender: Any?) {
		run.gameIcon = self.image
		setPlaceholderImage()
	}
	
	var allowsUpdate = true
	
	func loadData() {
		
		switch controller {
		case .mainViewController:
			if let c = findVC() as? ViewController {
				if let tabVC = c.infoPanelPopover?.contentViewController as? InfoPopoverTabViewController {
					if let infoVC = tabVC.tabView.selectedTabViewItem?.viewController as? InfoOptionsViewController {
						infoVC.getImageFromMain()
					}
				}
			}
		default:
			if let c = findVC() as? InfoOptionsViewController {
				c.sendImageToMain()
			}
		}
	}
	
}
extension MetadataImage {
	override func mouseDown(with event: NSEvent) {
		if event.clickCount > 1 {
			self.setImage()
		}
	}
	func pictureFileDialog() -> NSOpenPanel{
		let dialog = NSOpenPanel();
		dialog.title                   = "Choose an image file"
		dialog.showsResizeIndicator    = true
		dialog.showsHiddenFiles        = false
		dialog.canChooseDirectories    = false
		dialog.canCreateDirectories    = false
		dialog.allowsMultipleSelection = false
		dialog.allowedFileTypes        = ["png"]
		return dialog
	}
	
	func setImage() {
		let dialog = pictureFileDialog()
		
		let response = dialog.runModal()
			if response == .OK {
				let result = dialog.url
				
				if (result != nil) {
					 let imageFile = try? Data(contentsOf: result!)
					 
					 let myImage = NSImage(data: imageFile!)
					 
					self.image = myImage
					self.imageChanged(nil)
			}
		}
	}
}



extension InfoOptionsViewController {
	
	///Loads the popover with data from the main window
	func getDataFromMain() {
		//If the user types a title on the view controller, then shows the info panel (without pressing enter on the TF first), delegate is nil
		if let delegate = self.delegate {
			iconWell.run = delegate.run
			runTitleField.stringValue = delegate.run.title
			categoryField.stringValue = delegate.categoryField.stringValue
			attemptField.stringValue = "\(delegate.run.attempts ?? 0)"
			platformField.stringValue = delegate.platform ?? ""
			versionField.stringValue = run.gameVersion ?? ""
			regionField.stringValue = run.region
			
			if let st = delegate.startTime {
	//			let sDate = dateToRFC339String(date: st)
				let sDate = startEndDateFormatter.string(from: st)
				
				startTimeLabel.stringValue = sDate
			}
			if let et = delegate.endTime {
				let eDate = startEndDateFormatter.string(from: et)
				endTimeLabel.stringValue = eDate
			}
		}
		
	}
	
	///Sends data from the popover to the main window
	func sendDataToMain() {
		delegate?.runTitleField.stringValue = runTitleField.stringValue
		run.title = runTitleField.stringValue
		
		delegate?.categoryField.stringValue = categoryField.stringValue
		run.subtitle = categoryField.stringValue
		
		delegate?.attemptField.stringValue = attemptField.stringValue
		run.attempts = Int(attemptField.stringValue) ?? 0
		
		delegate?.platform = platformField.stringValue
		run.platform = platformField.stringValue
		
		run.gameVersion = versionField.stringValue
		
		delegate?.gameRegion = regionField.stringValue
		run.region = regionField.stringValue
		
//		delegate?.updateAttemptField()
	}
	func sendImageToMain() {
		delegate?.gameIconButton.image = iconWell.image
	}
	func getImageFromMain() {
		iconWell.allowsUpdate = false
		iconWell.image = delegate?.gameIconButton.image
		iconWell.allowsUpdate = true
	}
	
}


enum metaController {
	case mainViewController
	case infoViewController
	case runOptionsViewController
}

extension ViewController: NSTextViewDelegate {
	func textView(_ view: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int) -> NSMenu? {
		return nil
	}
}

extension NSImage {
	static var gameControllerIcon: NSImage {
		let icon = #imageLiteral(resourceName: "Game Controller")
		icon.isTemplate = true
		return icon
	}
}
