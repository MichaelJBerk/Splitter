//
//  WindowSettingViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/29/22.
//  Copyright © 2022 Michael Berk. All rights reserved.
//

import Cocoa

class WindowSettingViewController: NSViewController, LoadableNib {
	
	var runViewController: ViewController!
	var run: SplitterRun {
		runViewController.run
	}
	
	@IBOutlet weak var gridView: NSGridView!
	var contentView: NSView!
	
	@IBOutlet weak var hideTitleBarCheck: NSButton!
	@IBOutlet weak var keepOnTopCheck: NSButton!
	@IBOutlet weak var hideTitleCheck: NSButton!
	
	@IBOutlet weak var titleHelp: HelpButton!
	@IBOutlet weak var topHelp: HelpButton!
	
	@IBOutlet weak var noteLabel: NSTextField!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		viewDidAppear()
		NotificationCenter.default.addObserver(forName: .menuBarModeChanged, object: nil, queue: nil, using: { _ in
			self.toggleTopCheckDisable()
		})
		toggleTopCheckDisable()
    }
	
	
	func toggleTopCheckDisable() {
		keepOnTopCheck.isEnabled = !Settings.menuBarMode
	}
	
	var note = """
Note: These settings will be saved to this file, and will take effect whenever the file is opened.
"""
	
	///Sets the help buttons next to each option, as well as their popovers
	func setHelpButtons() {
		titleHelp.helpString = """
Hide the Title Bar for a more compact appearance.
You can still close the window either with ⌘W or from the "Window" menu.
"""
		
		topHelp.helpString = """
  Enabling this will make the window "float" above any other windows you have open.
  This is separate from Overlay Mode in Preferences.
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
		if let d = runViewController {
			d.titleBarHidden = hideTitleBar
			d.windowFloat = keepOnTop
			d.hideTitle = hideTitle
			d.showHideTitleBar()
			d.setFloatingWindow()
			
			d.setColorForControls()
			d.showHideTitle()
		}
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
			}
		})
	}
	
	func loadFromDelegate() {
		if let d = runViewController {

			hideTitleBar = d.titleBarHidden
			keepOnTop = d.windowFloat
			hideTitle = d.hideTitle
			
			hideTitleBarCheck.target = self
			keepOnTopCheck.target = self
			hideTitleCheck.target = self
			
			hideTitleBarCheck.action = #selector(sendSettings(_:))
			keepOnTopCheck.action = #selector(sendSettings(_:))
			hideTitleCheck.action = #selector(sendSettings(_:))
			
			if let doc = run.document, doc is Document {
				noteLabel.stringValue = splitNoteText
			} else {
				noteLabel.stringValue = notSplitNoteText
			}
		}
		
		setHelpButtons()
	}
	
}

class HelpButton: NSButton {
	
	var sourceView: NSView?
	var helpString: String?
	var popView: NSView?
	
	init() {
		super.init(frame: NSRect(x: 0, y: 0, width: 30, height: 30))
		setup()
	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	var trackingArea: NSTrackingArea?
	
	func setup() {
		trackingArea = NSTrackingArea(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInActiveApp], owner: self, userInfo: nil)
		addTrackingArea(trackingArea!)
		self.bezelStyle = .helpButton
		self.title = ""
		self.target = self
		self.action = #selector(displayHelpPopover)
		
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		
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
		let labelView = WindowSettingHelpLabel(labelWithString: helpString ?? "")
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
		pop?.show(relativeTo: .init(x: 0, y: 0, width: 0, height: 0), of: self, preferredEdge: .maxY)
	}
	
	
	
	
}

class WindowSettingHelpLabel: NSTextField {
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

