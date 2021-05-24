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

class MetadataField: NSTextField  {
	
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
				if let attemptsInt = Int(c.attemptField.stringValue) {
					c.attempts = attemptsInt
				}
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

class MetadataImage: NSImageView {
	var controller: metaController?
	
	override var image: NSImage? {
		willSet {
		}
		didSet {
			var newValue = self.image
			if newValue == nil {
				newValue = #imageLiteral(resourceName: "Game Controller")
				self.image = newValue
			}
			if let i = findVC() as? ViewController {
				if i.gameIcon != newValue {
					if newValue == #imageLiteral(resourceName: "Game Controller") {
					} else {
						if let tabVC = i.infoPanelPopover?.contentViewController as? InfoPopoverTabViewController {
								if let infoVC = tabVC.tabView.selectedTabViewItem?.viewController as? InfoOptionsViewController {
									infoVC.getDataFromMain()
								}
							}
					}
				}
			}
		if let i = findVC() as? InfoOptionsViewController {
				i.sendDataToMain()
				
			} else if let i = findVC() as? ViewController {
				
			}
			
		}
	}
	
	func loadData() {
		switch controller {
		case .mainViewController:
			if let c = findVC() as? ViewController {
				if let tabVC = c.infoPanelPopover?.contentViewController as? InfoPopoverTabViewController {
					if let infoVC = tabVC.tabView.selectedTabViewItem?.viewController as? InfoOptionsViewController {
						infoVC.getDataFromMain()
					}
				}
			}
		default:
			if let c = findVC() as? InfoOptionsViewController {
				c.sendDataToMain()
			}
		}
	}
	
}


extension InfoOptionsViewController {
	
	///Loads the popover with data from the main window
	func getDataFromMain() {
		runTitleField.stringValue = delegate!.runTitleField.stringValue
		categoryField.stringValue = delegate!.categoryField.stringValue
		attemptField.stringValue = "\(delegate?.attempts ?? 0)"
		platformField.stringValue = delegate?.platform ?? ""
		versionField.stringValue = delegate!.gameVersion ?? ""
		regionField.stringValue = delegate!.gameRegion ?? ""
		
		iconWell.image = delegate?.gameIcon
		
		if let st = delegate?.startTime {
//			let sDate = dateToRFC339String(date: st)
			let sDate = startEndDateFormatter.string(from: st)
			
			startTimeLabel.stringValue = sDate
		}
		if let et = delegate?.endTime {
			let eDate = startEndDateFormatter.string(from: et)
			endTimeLabel.stringValue = eDate
		}
	}
	
	///Sends data from the popover to the main window
	func sendDataToMain() {
		delegate?.runTitleField.stringValue = runTitleField.stringValue
		delegate?.categoryField.stringValue = categoryField.stringValue
		if let attemptsInt = Int(attemptField.stringValue) {
			delegate?.attempts = attemptsInt
		}
		
		delegate?.platform = platformField.stringValue
		delegate?.gameVersion = versionField.stringValue
		delegate?.gameRegion = regionField.stringValue
		delegate?.gameIconButton.image = iconWell.image
		
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
