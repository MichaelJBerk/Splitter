//
//  ViewController.swift
//  Splitter
//
//  Created by Michael Berk on 12/22/19.
//  Copyright © 2019 Michael Berk. All rights reserved.
//

import Cocoa
import Preferences

import Carbon

class ViewController: NSViewController {
	
//MARK: - Setting Up Buttons
	@IBOutlet weak var trashCanPopupButton: NSPopUpButton!
	var shouldTrashCanBeHidden: Bool {
		if UIHidden {
			return true
		}
		switch self.timerState {
			case .stopped:
				return false
			default:
				return true
		}
	}
	@IBOutlet weak var stopButton: NSButton!
	var shouldStopButtonBeHidden: Bool {
		stopButton.isEnabled = true
		if UIHidden {
			return true
		}
		switch self.timerState {
			case .stopped:
				return true
			default:
				return false
		}
	}

	
	@IBOutlet weak var StartButton: NSButton!
	@IBOutlet weak var nextButton: NSButton!
	@IBOutlet weak var prevButton: NSButton!
	@IBOutlet weak var plusButton: NSButton!
	@IBOutlet weak var minusButton: NSButton!
	@IBOutlet weak var gameIconButton: IconButton!
	@IBOutlet weak var pauseButton: NSButton!
	
	
	@IBOutlet weak var advancedPopoverButton: NSButton!
	@IBOutlet weak var columnOptionsPopoverButton: NSButton!
	
//MARK: - Setting Up Popovers
	var columnOptionsPopover: SplitterPopover?
	var advancedPopover: SplitterPopover?
	
	
//MARK: - Setting up Menu Items
	var timerStopItem: NSMenuItem? {
		if let pauseItem = view.window?.menu?.item(withIdentifier: menuIdentifiers.timerMenu.stop) {
			return pauseItem
		}
		return nil
	}
	
	var startSplitItem: NSMenuItem? {
		if let stopStart = view.window?.menu?.item(withIdentifier: menuIdentifiers.timerMenu.StartSplit) {
			return stopStart
		}
		return nil
	}
	
//MARK: - Other UI Elements
	@IBOutlet weak var GameTitleLabel: NSTextField!
	@IBOutlet weak var SubtitleLabel: NSTextField!
	@IBOutlet weak var TimerLabel: NSTextField!
	@IBOutlet weak var currentTimeLabel: NSTextField!
	
	@IBOutlet weak var splitsTableView: NSTableView!
	
	var cellIdentifier: NSUserInterfaceItemIdentifier?
	
//MARK: - Timer Properties
	var timerStarted = false
	var timerPaused = false
	
	
	var timer = Cocoa.Timer()
	var refreshUITimer = Cocoa.Timer()
	var milHundrethTimer = Cocoa.Timer()
	
	enum TimerState {
		case stopped
		case running
		case paused
	}
	
	var timerState: TimerState = .stopped {
		didSet {
			stopButton.isHidden = shouldStopButtonBeHidden
			trashCanPopupButton.isHidden = shouldTrashCanBeHidden
			if timerState == .stopped {
				timerStopItem?.isEnabled = false
				timerStopItem?.title = "Stop Timer"
				
				startSplitItem?.title = "Start Timer"
				
				addDeleteEnabled(true)
				nextBackEnabled(false)
			} else if timerState == .running {
				timerStopItem?.title = "Stop Timer"
				timerStopItem?.isEnabled = true
				
				startSplitItem?.title = "Split"
				
				addDeleteEnabled(false)
				nextBackEnabled(true)
			} else if timerState == .paused {
				timerStopItem?.isEnabled = true
				timerStopItem?.title = "Stop Timer"
				
				startSplitItem?.title = "Resume Timer"
				addDeleteEnabled(true)
				nextBackEnabled(false)
			}
		}
	}
	
	func addDeleteEnabled(_ enabled: Bool) {
		plusButton.isEnabled = enabled
		minusButton.isEnabled = enabled
	}
	
	func nextBackEnabled(_ enabled: Bool) {
		nextButton.isEnabled = enabled
		prevButton.isEnabled = enabled
	}

	//MARK: - Split Data/Properties
	
	var currentSplit: TimeSplit? = nil
	var currentSplits: [splitTableRow] = []
	var loadedFilePath: String = ""
	var currentSplitNumber = 0 {
		didSet {
			let totalSplits = currentSplits.count - 1
			if currentSplitNumber == totalSplits && timerState != .stopped {
				nextButton.title = "Finish"
			} else {
				nextButton.title = "Next"
			}
		}
	}

	//MARK: - External File Split Data
	//Stuff that holds data from files
	var splitsIOSchemaVersion = "v1.0.1"
	var splitsIOData: SplitsIOExchangeFormat!
	var runInfoData: runInfo?
	
	var appearance: splitterAppearance?
		
		var shouldLoadSplits = false
	
	//MARK: - Icon Data
	
	var iconArray: [NSImage?] {
		get {
			var icons: [NSImage?] = []
			var i = 0
			while i < currentSplits.count {
				let cS = currentSplits[i]
				if cS.splitIcon != nil {
					icons.append(cS.splitIcon)
				} else {
					icons.append(nil)
				}
					
					i = i + 1
				}
			return icons
		}
		set(icons) {
			var i = 0
			var cI: NSImage?
			while i < currentSplits.count {
				if i > icons.count - 1 {
					cI = nil
				}
				else {
					cI = icons[i]
				}
				currentSplits[i].splitIcon = cI
				i = i + 1
			}
			splitsTableView.reloadData()
		}
	}
	var gameIcon: NSImage? = nil {
		didSet {
			if gameIcon != nil {
				gameIconButton.image = gameIcon
			} else {
				gameIconButton.image = #imageLiteral(resourceName: "Game Controller")
			}
		}
	}
	//TODO: This isn't really necessary, so remove it
	var gameIconFileName: String? = "gameicon.png"
	
	
	//MARK: - Settings
	
	var windowFloat = false
	var UIHidden = false
	var titleBarHidden = false
	var showBestSplits = false
	
	var hotkeysController: HotkeysViewController?
	
	//MARK: - Main Functions
	override func viewWillAppear() {
		super.viewWillAppear()
		
		view.window?.delegate = self
		//This line of code looks redundant, but it's here in order to make the timerState's property observer fire
		let ts = timerState
		timerState = ts
		
		view.window?.isOpaque = false
		view.window?.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
		splitsTableView.backgroundColor = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
		splitsTableView.delegate = self
		splitsTableView.dataSource = self

		let exportJSON = view.window?.menu?.item(withTag: 1)
		exportJSON?.isEnabled = false
		
		view.window?.isMovableByWindowBackground = true
		
		if StartButton.acceptsFirstResponder {
			StartButton.window?.makeFirstResponder(StartButton)
		}
		
		view.window?.standardWindowButton(.zoomButton)?.isHidden = true
		view.window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
		
		if let gi = gameIcon {
			gameIconButton.image = gi
		}
		
		timerStopItem?.isEnabled = false
	
		if appearance != nil {
			setSplitterAppearance(appearance: appearance!)
		} else {
			setUpDefaults()
		}
		
		if currentSplits.count == 0 {
			addBlankSplit()
		}
		
		gameIconButton.iconButtonType = .gameIcon
		view.window?.makeFirstResponder(splitsTableView)
		
		
		
	}
	
	func setUpDefaults() {
		titleBarHidden = Settings.hideTitleBar
		showHideTitleBar()
		
		
		UIHidden = Settings.hideUIButtons
		 showHideUI()
		
		windowFloat = Settings.floatWindow
		setFloatingWindow()
		
		showBestSplits = Settings.showBestSplits
		showHideBestSplits()
		
		
	}

	override func viewDidLoad() {
		
		
		super.viewDidLoad()
		self.view.wantsLayer = true
		
			
	}
	
	override func viewWillDisappear() {
		advancedPopover?.contentViewController?.view.window?.close()
		columnOptionsPopover?.contentViewController?.view.window?.close()
		super.viewWillDisappear()

	}
	
	@IBAction func displayAdvancedPopover(_ sender: Any) {
		advancedPopover?.contentViewController?.view.window?.close()
		let destination = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: ViewControllerID.advanced) as! AdvancedTabViewController
		destination.delegate = self
		let pop = SplitterPopover()
		pop.delegate = self
		pop.contentViewController = destination
		pop.contentSize = NSSize(width: 450, height: 220)
		pop.behavior = .semitransient
		pop.show(relativeTo: .null, of: advancedPopoverButton, preferredEdge: .maxX)
		advancedPopover = pop
		destination.setupTabViews()
	}
	
	@IBAction func displayColumnOptionsPopover(_ sender: Any) {
		columnOptionsPopover?.contentViewController?.view.window?.close()
		let destination = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: ViewControllerID.columnOptions) as! ColumnOptionsViewController
		destination.delegate = self
		let pop = SplitterPopover()
		pop.delegate = self
		pop.contentViewController = destination
		pop.behavior = .semitransient
		pop.show(relativeTo: .null, of: columnOptionsPopoverButton, preferredEdge: .maxX)
		columnOptionsPopover = pop
		destination.loadCheckBoxes()
		
		
	}
	
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	override func keyDown(with event: NSEvent) {
		super.keyDown(with: event)
		
	}

	
}

//TODO: See if this should be in a separate file, and if it should be with the VC or on its own or in Data
extension DateComponents {
	
	func millisecond() -> Double? {
		if nanosecond != nil {
			
			return round(Double(nanosecond!) / 1000000)
		}
		else {
			return nil
		}
	}
	mutating func setMillisecond(mil:Int) {
		self.nanosecond = mil * 1000000
	}
}


extension ViewController: NSWindowDelegate {

	func windowDidBecomeKey(_ notification: Notification) {
		let showHideUIItem = NSApp.mainMenu?.item(withIdentifier: menuIdentifiers.appearanceMenu.hideButtons)
		showHideUIItem?.title = showHideButtonsText
		
		let showHideTitleBarItem = NSApp.mainMenu?.item(withIdentifier: menuIdentifiers.appearanceMenu.hideTitleBar)
		showHideTitleBarItem?.title = showHideTitleBarItemText
		
		let showHideBestSplitsItem = NSApp.mainMenu?.item(withIdentifier: menuIdentifiers.appearanceMenu.showBestSplits)
		showHideBestSplitsItem?.title = showHideBestSplitsItemText
	}
}

extension ViewController: NSPopoverDelegate {
	func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		return true
	}
	
	
	override func present(_ viewController: NSViewController, asPopoverRelativeTo positioningRect: NSRect, of positioningView: NSView, preferredEdge: NSRectEdge, behavior: NSPopover.Behavior) {
		
		super.present(viewController, asPopoverRelativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge, behavior: behavior)
	}
}

class SplitterPopover: NSPopover {

}
