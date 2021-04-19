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
	
	@IBOutlet weak var hideTitleBarCheck: NSButton!
	@IBOutlet weak var hideButtonsCheck: NSButton!
	@IBOutlet weak var keepOnTopCheck: NSButton!
	@IBOutlet weak var hideTitleCheck: NSButton!
	
	@IBOutlet weak var gridView: NSGridView!
	
	@IBOutlet weak var titleHelp: helpButton!
	@IBOutlet weak var buttonHelp: helpButton!
	@IBOutlet weak var topHelp: helpButton!
	
	@IBOutlet weak var noteLabel: NSTextField!
	
	
	
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
		
		buttonHelp.appVC = self
		buttonHelp.target = self
		buttonHelp.helpString = """
		Hide the buttons on the window.
		You can still control the timer using the Menu Bar, Hotkeys, or the Right-Click menu.
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
	var hideButtons: Bool {
		set {
			hideButtonsCheck.state = .init(bool: newValue)
		}
		get {
			return hideButtonsCheck.state.toBool()
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
		if let d = delegate {
			d.titleBarHidden = hideTitleBar
			d.buttonHidden = hideButtons
			d.windowFloat = keepOnTop
			d.hideTitle = hideTitle
			d.showHideTitleBar()
			d.showHideUI()
			d.setFloatingWindow()
			
			d.setColorForControls()
			d.showHideTitle()
		}
	}
	
	///This doesn't do anything; it's just needed to conform to the protocol
	func setupDelegate() {
		
	}
	
	override func viewDidAppear() {
		if let d = delegate {

			hideTitleBar = d.titleBarHidden
			hideButtons = d.buttonHidden
			keepOnTop = d.windowFloat
			hideTitle = d.hideTitle
			
			hideTitleBarCheck.target = self
			hideButtonsCheck.target = self
			keepOnTopCheck.target = self
			hideTitleCheck.target = self
			
			hideTitleBarCheck.action = #selector(sendSettings(_:))
			hideButtonsCheck.action = #selector(sendSettings(_:))
			keepOnTopCheck.action = #selector(sendSettings(_:))
			hideTitleCheck.action = #selector(sendSettings(_:))
			
			if let doc = delegate?.view.window?.windowController?.document as? NSDocument {
				if doc.fileType != "Split File" {
					noteLabel.stringValue = notSplitNoteText
				} else {
					noteLabel.stringValue = splitNoteText
				}
			}
		}
		
		setHelpButtons()
	}
    
}

class helpButton: NSButton {
	
	var appVC: AppearanceViewController?
	var helpString: String?
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		self.bezelStyle = .helpButton
		self.title = ""
		self.target = self
		self.action = #selector(displayHelpPopover)
		
	}
	
	@objc func displayHelpPopover() {
		let pop = NSPopover()
		let labelView = appearanceHelpLabel(string: helpString ?? "")
		labelView.isEditable = false
		labelView.isSelectable = false
		labelView.cell?.wraps = true
		
		let contentVC = NSViewController()
		contentVC.view = labelView
		
		pop.contentViewController = contentVC
		pop.behavior = .transient
		
		pop.show(relativeTo: appVC?.view.frame ?? CGRect.zero, of: self, preferredEdge: .maxY)
		
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
