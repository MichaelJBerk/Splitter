//
//  AppearanceViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/12/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import Preferences

class AppearanceViewController: NSViewController, advancedTabDelegate {
	var delegate: ViewController?
	var run: SplitterRun!
	
	@IBOutlet weak var hideTitleBarCheck: NSButton!
	@IBOutlet weak var keepOnTopCheck: NSButton!
	@IBOutlet weak var hideTitleCheck: NSButton!
	
	@IBOutlet weak var gridView: NSGridView!
	
	@IBOutlet weak var titleHelp: helpButton!
	@IBOutlet weak var topHelp: helpButton!
	
	@IBOutlet weak var noteLabel: NSTextField!
	@IBOutlet weak var backgroundImageWell: NSImageView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
        // Do view setup here.
    }
	
	@IBAction func settingsSender(_ sender: Any) {
		sendSettings(sender)
	}
	

	
	var note = """
Note: These settings will be saved to this file, and will take effect whenever the file is opened.
"""
	
	///Sets the help buttons next to each option, as well as their popovers
	func setHelpButtons() {
		titleHelp.appVC = self
		titleHelp.helpString = """
Hide the Title Bar for a more compact appearance.
You can still close the window either with ⌘W or from the "Window" menu.
"""
		
		topHelp.appVC = self
		topHelp.target = self
		topHelp.helpString = """
		Enabling this will make the window "float" above any other windows you have open.
		"""
	}
	
	
	var hideTitleBar: Bool {
		set {
			hideTitleBarCheck.state = .init(bool: newValue)
		}
		get {
			return hideTitleBarCheck.state.toBool() 
		}
	}
	var keepOnTop: Bool {
		set {
			keepOnTopCheck.state = .init(bool: newValue)
		}
		get {
			return keepOnTopCheck.state.toBool()
		}
	}
	
	var hideTitle: Bool {
		set {
			hideTitleCheck.state = .init(bool: newValue)
		}
		get {
			return hideTitleCheck.state.toBool()
		}
	}
	
	///Sends settings back to the original view controller
	@objc func sendSettings(_ sender: Any) {
		if run.undoManager?.isUndoing ?? false {
			run.undoManager?.disableUndoRegistration()
		}
		if let d = delegate {
			d.titleBarHidden = hideTitleBar
			d.windowFloat = keepOnTop
			d.hideTitle = hideTitle
			d.showHideTitleBar()
			d.setFloatingWindow()
			
			d.setColorForControls()
			d.showHideTitle()
		}
		run.backgroundImage = self.backgroundImageWell.image
		if run.undoManager?.isUndoing ?? false {
			run.undoManager?.enableUndoRegistration()
		}
	}
	
	///This doesn't do anything; it's just needed to conform to the protocol
	func setupDelegate() {
		
	}
	
	override func viewDidAppear() {
		addBackgroundImageObserver()
		loadFromDelegate()
	}
	func addBackgroundImageObserver() {
		NotificationCenter.default.addObserver(forName: .backgroundImageEdited, object: self.run, queue: nil, using: { notification in
			if self.run.undoManager?.isUndoing ?? false || self.undoManager?.isRedoing ?? false {
				if let image = notification.userInfo?["image"] as? NSImage {
					self.backgroundImageWell.image = image
				} else {
					self.backgroundImageWell.image = nil
				}
			}
		})
	}
	
	func loadFromDelegate() {
		if let d = delegate {

			hideTitleBar = d.titleBarHidden
			keepOnTop = d.windowFloat
			hideTitle = d.hideTitle
			
			hideTitleBarCheck.target = self
			keepOnTopCheck.target = self
			hideTitleCheck.target = self
			backgroundImageWell.target = self
			
			hideTitleBarCheck.action = #selector(sendSettings(_:))
			keepOnTopCheck.action = #selector(sendSettings(_:))
			hideTitleCheck.action = #selector(sendSettings(_:))
			backgroundImageWell.action = #selector(sendSettings(_:))
			
			if let doc = run.document, doc is Document {
				noteLabel.stringValue = splitNoteText
			} else {
				noteLabel.stringValue = notSplitNoteText
			}
		}
		
		backgroundImageWell.image = run.backgroundImage
		
		setHelpButtons()
	}
    
}

class helpButton: NSButton {
	
	var appVC: AppearanceViewController?
	var helpString: String?
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	var trackingArea: NSTrackingArea!
	func setup() {
		trackingArea = NSTrackingArea(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInActiveApp], owner: self, userInfo: nil)
		addTrackingArea(trackingArea)
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		self.bezelStyle = .helpButton
		self.title = ""
		self.target = self
		self.action = #selector(displayHelpPopover)
		
	}
	var pop: NSPopover?
	
	override func mouseEntered(with event: NSEvent) {
		super.mouseEntered(with: event)
		displayHelpPopover()
	}
	
	override func mouseExited(with event: NSEvent) {
		super.mouseExited(with: event)
		pop?.close()
		pop = nil
	}
	
	
	@objc func displayHelpPopover() {
		pop = NSPopover()
		let labelView = appearanceHelpLabel(labelWithString: helpString ?? "")
		labelView.sizeToFit()
		labelView.translatesAutoresizingMaskIntoConstraints = false
		
		
		let contentVC = NSViewController()
		let innerView = NSView()
		innerView.wantsLayer = true
		innerView.layer?.isOpaque = false
		innerView.layer?.backgroundColor = .clear
		contentVC.view = innerView
		contentVC.view.addSubview(labelView)
		
		NSLayoutConstraint.activate([
			labelView.centerXAnchor.constraint(equalTo: contentVC.view.centerXAnchor),
			labelView.centerYAnchor.constraint(equalTo: contentVC.view.centerYAnchor),
			contentVC.view.heightAnchor.constraint(equalTo: labelView.heightAnchor, constant: 30),
			contentVC.view.widthAnchor.constraint(equalTo: labelView.widthAnchor, constant: 30),
		])
		
		pop?.contentViewController = contentVC
		pop?.behavior = .transient
		
		pop?.show(relativeTo: appVC?.view.frame ?? CGRect.zero, of: self, preferredEdge: .maxY)
		
	}
	
	
	
	
}

class appearanceCheckButton: NSButton {
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		
	}
}


class appearanceHelpLabel: NSTextField {
	override var intrinsicContentSize: NSSize {
		// Guard the cell exists and wraps
		guard let cell = self.cell, cell.wraps else {return super.intrinsicContentSize}

		// Use intrinsic width to jive with autolayout
		let width = super.intrinsicContentSize.width

		// Set the frame height to a reasonable number
		self.frame.size.height = 750.0

		// Calcuate height
		let height = cell.cellSize(forBounds: self.frame).height

		return NSMakeSize(width, height);
	}
	override func textDidChange(_ notification: Notification) {
		super.textDidChange(notification)
		super.invalidateIntrinsicContentSize()
	}
}
