//
//  ViewController.swift
//  Splitter
//
//  Created by Michael Berk on 12/22/19.
//  Copyright © 2019 Michael Berk. All rights reserved.
//

import Cocoa
import Preferences
import AppCenter
import AppCenterCrashes
import SplitsIOKit
//Only doing this to show the TCTestView
import SwiftUI

class ViewController: NSViewController {
	
	//MARK: - Setting Up Buttons
	var shouldTrashCanBeHidden: Bool {
		if buttonHidden {
			return true
		}
		switch self.timerState {
			case .stopped:
				return false
			default:
				return true
		}
	}
	var shouldStopButtonBeHidden: Bool {
		stopButton.isEnabled = true
		if buttonHidden {
			return true
		}
		switch self.timerState {
			case .stopped:
				return true
			default:
				return false
		}
	}
	@IBOutlet weak var trashCanPopupButton: NSPopUpButton!
	@IBOutlet weak var stopButton: NSButton!
	@IBOutlet weak var startButton: NSButton!
	@IBOutlet weak var nextButton: NSButton!
	@IBOutlet weak var prevButton: NSButton!
	@IBOutlet weak var plusButton: NSButton!
	@IBOutlet weak var minusButton: NSButton!
	@IBOutlet weak var gameIconButton: MetadataImage!
	@IBOutlet weak var infoPanelPopoverButton: ThemedButton!
	@IBOutlet weak var columnOptionsPopoverButton: NSButton!
	
//MARK: - Container Views
	@IBOutlet weak var metadataView: NSView!
	@IBOutlet weak var innerMetatdataStack: NSStackView!
	@IBOutlet weak var tableButtonsStack: NSStackView!
	@IBOutlet weak var bottomStackView: DraggingStackView!
	
//MARK: - Popovers
	var columnOptionsPopover: NSPopover?
	var infoPanelPopover: NSPopover?
	
	
//MARK: - Setting up Menu Items
	var timerStopItem: NSMenuItem? {
		if let pauseItem = view.window?.menu?.item(withIdentifier: menuIdentifiers.runMenu.stop) {
			return pauseItem
		}
		return nil
	}
	
	var startSplitItem: NSMenuItem? {
		if let stopStart = view.window?.menu?.item(withIdentifier: menuIdentifiers.runMenu.StartSplit) {
			return stopStart
		}
		return nil
	}
	var pauseMenuItem: NSMenuItem? {
		if let pauseItem = view.window?.menu?.item(withIdentifier: menuIdentifiers.runMenu.pause) {
			return pauseItem
		}
		return nil
	}
	var addRowMenuItem: NSMenuItem? {
		return view.window?.menu?.item(withIdentifier: menuIdentifiers.runMenu.addRow)
	}
	var removeRowMenuItem: NSMenuItem? {
		return view.window?.menu?.item(withIdentifier: menuIdentifiers.runMenu.removeRow)
	}
	
//MARK: - Colors
	var bgColor: NSColor = .splitterDefaultColor {
		didSet {
			view.window?.backgroundColor = self.bgColor
			if self.bgColor.isLight()! {
				view.window?.appearance = NSAppearance(named: .aqua)
			} else {
				view.window?.appearance = NSAppearance(named: .darkAqua)
			}
		}
	}
	
	var selectedColor: NSColor = .splitterRowSelected
	
	var diffsLongerColor: NSColor = .red
	var diffsShorterColor: NSColor = .green
	var diffsNeutralColor: NSColor = .blue
	
	
//MARK: - Other UI Elements
	@IBOutlet weak var runTitleField: MetadataField!
	@IBOutlet weak var categoryField: MetadataField!
	@IBOutlet weak var timerLabel: NSTextField!
	@IBOutlet weak var currentTimeLabel: NSTextField!
	var attemptField: MetadataField!
	@IBOutlet weak var splitsTableView: SplitterTableView!
	
	var cellIdentifier: NSUserInterfaceItemIdentifier?
	
	//MARK: - Touch Bar Controls
	var touchBarTotalTimeLabel: NSTextField = NSTextField(labelWithString: "00:00:00.00")
	var touchBarDelegate: RunTouchBarDelegate!
	
	
//MARK: - Timer Properties
	
	var run: SplitterRun!
	
	var timerStarted = false
	var timerPaused = false
	
	
	var timer = Timer()
	var lscTimer: LSTimer?
	var refreshUITimer = Timer()
	var milHundrethTimer = Timer()
	
	///States that the timer can be in
	enum TimerState {
		case stopped
		case running
		case paused
	}
	
	///The timer's state - either stopped, running, or paused
	var timerState: TimerState = .stopped {
		didSet {
			stopButton.isHidden = shouldStopButtonBeHidden
			trashCanPopupButton.isHidden = shouldTrashCanBeHidden
			let prevSplitItem = view.window?.menu?.item(withIdentifier: menuIdentifiers.runMenu.back)
			if timerState == .stopped {
				setMenuItemEnabled(item: timerStopItem, enabled: false)
				timerStopItem?.title = "Stop Timer"
				startSplitItem?.title = "Start Timer"
				
				setMenuItemEnabled(item: startSplitItem, enabled: true)
				setMenuItemEnabled(item: prevSplitItem, enabled: false)
				setMenuItemEnabled(item: pauseMenuItem, enabled: false)
				
				addDeleteEnabled(true)
				splitBackEnabled(false)
				stopTimer()
				self.splitsTableView.reloadData(forRowIndexes: IndexSet(arrayLiteral: 0), columnIndexes: IndexSet(arrayLiteral: 0,1,2,3,4,5))
			} else if timerState == .running {
				timerStopItem?.title = "Stop Timer"
				setMenuItemEnabled(item: timerStopItem, enabled: true)
				
				startSplitItem?.title = "Split"
				setMenuItemEnabled(item: startSplitItem, enabled: true)
				setMenuItemEnabled(item: prevSplitItem, enabled: true)
				
				setMenuItemEnabled(item: pauseMenuItem, enabled: true)
				pauseMenuItem?.title = "Pause Timer"
				
				addDeleteEnabled(false)
				splitBackEnabled(true)
				touchBarDelegate.startSplitTitle = nextButton.baseTitle
				
			} else if timerState == .paused {
				setMenuItemEnabled(item: timerStopItem, enabled: true)
				timerStopItem?.title = "Stop Timer"
				setMenuItemEnabled(item: prevSplitItem, enabled: false)
				setMenuItemEnabled(item: pauseMenuItem, enabled: true)
				
				pauseMenuItem?.title = "Resume Timer"
				
				
				setMenuItemEnabled(item: startSplitItem, enabled: false)
				
				addDeleteEnabled(true)
				splitBackEnabled(false)
			}
			touchBarDelegate.enableDisableButtons()
			
		}
	}
	
	//TODO: see if I should just have a var "addDeleteEnabled" and set both equal to it instead of having a function for it
	///Sets whethert the + and - buttons beneath the Table View are enabled or not
	func addDeleteEnabled(_ enabled: Bool) {
		plusButton.isEnabled = enabled
		minusButton.isEnabled = enabled
		setMenuItemEnabled(item: addRowMenuItem, enabled: enabled)
		setMenuItemEnabled(item: removeRowMenuItem, enabled: enabled)
	}
	///Sets whethert the "split" and "back" buttons are enabled or not
	func splitBackEnabled(_ enabled: Bool) {
		nextButton.isEnabled = enabled
		prevButton.isEnabled = enabled
	}

	//MARK: - Split Data/Properties
	
	var currentSplit: TimeSplit? = nil
	var currentSplits: [SplitTableRow] = []
	var backupSplits: [SplitTableRow] = []
	var loadedFilePath: String = ""

	var compareTo: LSComparison {
		get {
			return run.getComparision()
		}
		set {
			run.setComparison(to: newValue)
		}
	}
	
	var roundTo: SplitRounding = .tenths
	
	

	//MARK: - Other Split Metadata
	
	var platform: String {
		get {
			run.platform
		}
		set {
			run.platform = newValue
		}
	}
	
	var gameVersion: String?
	var gameRegion: String {
		get {
			run.region
		}
		set {
			run.region = newValue
		}
	}
	var startTime: Date?
	var endTime: Date?
	var fileID: String?

	//MARK: - External File Split Data
	//Stuff that holds data from files
	var splitsIOSchemaVersion = "v1.0.1"
	var splitsIOData: SplitsIOExchangeFormat!
	var runInfoData: runInfo?
	var lsPointer: UnsafeMutableRawPointer?
	var appearance: splitterAppearance?
	var shouldLoadSplits = false
	
	//MARK: Splits.io Uploading
	var splitsIOUploader: SplitsIOUploader!
	
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
	
	
	
	//MARK: - Settings
	var enabledMenuItems:[NSUserInterfaceItemIdentifier: Bool] = [:]
	
	var windowFloat = false
	var buttonHidden = false
	var titleBarHidden = false
	var showBestSplits = false
	var hideTitle = false
	
	var hotkeysController: HotkeysViewController?
	
	@objc func breakFunc() {
		for window in NSApp.windows {
			let w = window.styleMask
			print(window.title)
			
		}
	}
	
	var breakID = NSUserInterfaceItemIdentifier("break")
	
	override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
	}
	
	var timeRow: TimeRow!
	var startRow: StartRow!
	var prevNextRow: PrevNextRow!
	var optionsRow: OptionsRow!
	func setupOptionsRow() {
		optionsRow = OptionsRow.instantiateView()//.createFromNib()
//		optionsRow.loadViewFromNib()
//		NSNib(nibNamed: "OptionsRow", bundle: nil)?.instantiate(withOwner: optionsRow, topLevelObjects: nil)
		optionsRow.viewController = self
		
		addToStack(view: optionsRow)
		plusButton = optionsRow.plusButton
		minusButton = optionsRow.minusButton
		columnOptionsPopoverButton = optionsRow.columnOptionsButton
		tableButtonsStack = optionsRow.tableButtonsStack
		
	}
	
	func setupPrevNextRow() {
		prevNextRow = PrevNextRow()
		prevNextRow.loadViewFromNib()
		prevNextRow.viewController = self
		
		addToStack(view: prevNextRow)
		prevButton = prevNextRow.prevButton
		nextButton = prevNextRow.nextButton
	}
	func setupStartRow() {
		startRow = StartRow()
		startRow.loadViewFromNib()
		startRow.viewController = self
		
		addToStack(view: startRow)
		startButton = startRow.startButton
		stopButton = startRow.stopButton
		trashCanPopupButton = startRow.trashCanPopupButton
	}
	func setupTimeRow() {
		timeRow = TimeRow()
		timeRow.loadViewFromNib()
		timeRow.viewController = self
		addToStack(view: timeRow)
		
		timerLabel = timeRow.timeLabel
		attemptField = timeRow.attemptsField
	}
	
	//MARK: - Main Functions
	override func viewWillAppear() {
		super.viewWillAppear()
		setupOptionsRow()
		setupTimeRow()
		setupStartRow()
		setupPrevNextRow()
		
		stopButton.image = nil
		let tsItem = trashCanPopupButton.menu?.items[0]
		tsItem?.image = nil
		infoPanelPopoverButton.image = nil
		if #available(macOS 11.0, *) {
			infoPanelPopoverButton.image = NSImage(systemSymbolName: "gearshape.fill", accessibilityDescription: nil)
			stopButton.image = NSImage(systemSymbolName: "stop.circle.fill", accessibilityDescription: nil)
			tsItem?.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
		} else {
			stopButton.image = NSImage(named: "stop")
			tsItem?.image = NSImage(named: "trash")
			infoPanelPopoverButton.image = NSImage(named: "gearshape")
			
		}
		if let welcome = AppDelegate.shared?.welcomeWindow {
			welcome.close()
		}
		run.tableColor = .splitterTableViewColor
        if #available(macOS 11.0, *) {
            splitsTableView.style = .fullWidth
        }
		#if DEBUG
		let breakMI = NSMenuItem(title: "Break", action: #selector(breakFunc), keyEquivalent: "b")
		breakMI.keyEquivalentModifierMask = .command
		breakMI.identifier = breakID
		NSApp.mainMenu?.item(at: 0)?.submenu?.addItem(breakMI)
		#endif
		
		view.window?.delegate = self
		
		touchBarDelegate = RunTouchBarDelegate(splitFunc: startSplitTimer, pauseFunc: pauseResumeTimer, prevFunc: goToPrevSplit, stopFunc: stopTimer, sourceVC: self)
		
		splitsTableView.delegate = self
		splitsTableView.dataSource = self
		
		view.window?.isMovableByWindowBackground = true
		
		if startButton.acceptsFirstResponder {
			startButton.window?.makeFirstResponder(startButton)
		}
		
		view.window?.standardWindowButton(.zoomButton)?.isHidden = true
		view.window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
		
		setMenuItemEnabled(item: timerStopItem, enabled: false)
	
		if appearance != nil {
			setSplitterAppearance(appearance: appearance!)
		} else {
			setUpDefaults()
		}
		if fileID == nil {
			fileID = UUID().uuidString
		}
		view.window?.setFrameAutosaveName(fileID!)
		if currentSplits.count == 0 {
			addBlankSplit()
		}
		
		view.window?.makeFirstResponder(splitsTableView)
		
		setRightClickMenus()
		attemptField.formatter = OnlyIntegerValueFormatter()
		
		splitsIOUploader = SplitsIOUploader(viewController: self)
		
		//This line of code looks redundant, but it's here in order to make the timerState's property observer fire
		let ts = timerState
		timerState = ts
		
		
		NotificationCenter.default.addObserver(forName: .phaseChanged, object: nil, queue: nil, using: { notification in
			let old: Int = Int(notification.userInfo!["oldPhase"] as! UInt8)
			let phase: Int = Int(notification.userInfo!["phase"] as! UInt8)
			if phase == 2 {
				self.timerState = .stopped
			}
			if phase == 1 && old != 1 {
				self.timerState = .running
			}
			if phase == 3 && old != 3 {
				self.timerState = .paused
			}
			
		})
		updateTextFields()
		gameIconButton.run = self.run
		if let gi = run.gameIcon {
			gameIconButton.image = gi
		} else {
			gameIconButton.image = .gameControllerIcon
		}
		print("VWA Done!")
		setColorForControls()
	}
	///Updates the run, with the current values from the view controller
	func updateRun() {
		run.title = runTitleField.stringValue
		run.subtitle = categoryField.stringValue
		if let attemptsInt = Int(attemptField.stringValue) {
			run.attempts = attemptsInt
		}
	}
	///Updates textfields from the values in the current run
	func updateTextFields() {
		runTitleField.stringValue = run.title
		categoryField.stringValue = run.subtitle
		attemptField.stringValue = "\(run.attempts)"
	}
	
	func addToStack(view: NSView) {
		bottomStackView.insertArrangedSubview(view, at: bottomStackView.arrangedSubviews.count)
		if let bottomSuper = bottomStackView.superview {
			NSLayoutConstraint.activate([
				view.leftAnchor.constraint(equalTo: bottomSuper.leftAnchor, constant: 7),
				view.rightAnchor.constraint(equalTo: bottomSuper.rightAnchor, constant: -7)
			])
		}
	}
	
	func setupConstraints() {
		gameToViewEdgeConstraint = NSLayoutConstraint(item: runTitleField.superview!, attribute: .trailing, relatedBy: .equal, toItem: runTitleField, attribute: .trailing, multiplier: 1, constant: 8)
		gameToViewEdgeConstraint?.isActive = false
		categoryToViewEdgeConstraint = NSLayoutConstraint(item: categoryField.superview!, attribute: .trailing, relatedBy: .equal, toItem: categoryField, attribute: .trailing, multiplier: 1, constant: 8)
		categoryToViewEdgeConstraint?.isActive = false
	}
	
	func setMenuItemEnabled(item: NSMenuItem?, enabled: Bool) {
		if let id = item?.identifier {
			enabledMenuItems[id] = enabled
		}
	}
	
	var gameToViewEdgeConstraint: NSLayoutConstraint?
	var categoryToViewEdgeConstraint: NSLayoutConstraint?
	
	func setRightClickMenus() {
		let standardMenu = view.menu
		
		let gimenu = standardMenu
		
		let resetIconMenuItem = NSMenuItem(title: "Reset Game Icon", action: #selector(removeGameIconMenuItem(sender:)), keyEquivalent: "")
		let setIconMenuItem = NSMenuItem(title: "Set Game Icon", action: #selector(pictureButtonPressed(_:)), keyEquivalent: "")
		gimenu?.addItem(NSMenuItem.separator())
		gimenu?.addItem(setIconMenuItem)
		gimenu?.addItem(resetIconMenuItem)
		gameIconButton.menu = gimenu
		
		let fe = self.view.window?.fieldEditor(true, for: runTitleField)
		let textMenu = fe?.menu
		textMenu?.addItem(.separator())
		let optionsMenu = NSMenu(title: "Splitter...")
		for i in standardMenu!.items {
			var icopy = NSMenuItem(title: i.title, action: i.action, keyEquivalent: i.keyEquivalent)
			if i.title == "" {
				icopy = NSMenuItem.separator()
			}
			optionsMenu.addItem(icopy)
		}
		let subMenuItem = NSMenuItem(title: "Splitter...", action: nil, keyEquivalent: "")
		
		if textMenu?.item(withTitle: "Splitter...") == nil {
			textMenu?.addItem(subMenuItem)
		}
		
		textMenu?.setSubmenu(optionsMenu, for: subMenuItem)
		fe?.menu = textMenu
		runTitleField.cell?.controlView?.menu = textMenu
		categoryField.menu = textMenu
		attemptField.menu = textMenu
		
	}
	
	func setUpDefaults() {
		titleBarHidden = Settings.hideTitleBar
		showHideTitleBar()
		
		
		buttonHidden = Settings.hideUIButtons
		 showHideUI()
		
		windowFloat = Settings.floatWindow
		setFloatingWindow()
		
		for c in splitsTableView.tableColumns {
			if c.identifier == STVColumnID.previousSplitColumn {
				c.isHidden = true
			}
			if c.identifier == STVColumnID.bestSplitColumn {
				c.width = 86
			}
		}
		
		
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		if run == nil {
			run = SplitterRun(run: Run())
		}
		self.view.wantsLayer = true
		splitsTableView.reloadData()
	}
	
	override func viewWillDisappear() {
		infoPanelPopover?.contentViewController?.view.window?.close()
		columnOptionsPopover?.contentViewController?.view.window?.close()
		super.viewWillDisappear()

	}
	
	///Displays the "get info" popover
	@IBAction func displayInfoPopover(_ sender: Any) {
		infoPanelPopover?.contentViewController?.view.window?.close()
		let destination = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: InfoPopoverTabViewController.storyboardID) as! InfoPopoverTabViewController
		destination.delegate = self
		let pop = NSPopover()
		pop.delegate = self
		pop.contentViewController = destination
		pop.contentSize = NSSize(width: 450, height: 325)
		pop.behavior = .semitransient
		pop.appearance = NSAppearance(named: .vibrantDark)
		pop.show(relativeTo: infoPanelPopoverButton.frame, of: innerMetatdataStack, preferredEdge: .maxX)
		infoPanelPopover = pop
		destination.setupTabViews()
	}
	
	///Displays the "column options" popover
	@IBAction func displayColumnOptionsPopover(_ sender: Any) {
		columnOptionsPopover?.contentViewController?.view.window?.close()
		let tabView = NSStoryboard(name: "LayoutEditor", bundle: nil).instantiateInitialController() as? LayoutEditorTabViewController
		tabView?.viewController = self
		let layoutEditor = tabView?.tabViewItems[0].viewController as! LayoutEditorViewController
		layoutEditor.runController = self
		let destination = tabView?.tabViewItems[1].viewController as! ColumnOptionsViewController
			//.instantiateController(withIdentifier: ColumnOptionsViewController.storyboardID) as! ColumnOptionsViewController
		destination.delegate = self
		let pop = NSPopover()
		pop.delegate = self
		pop.contentViewController = tabView
		pop.appearance = NSAppearance(named: .vibrantDark)
		pop.behavior = .semitransient
		pop.show(relativeTo: columnOptionsPopoverButton.frame, of: tableButtonsStack, preferredEdge: .maxX)
		columnOptionsPopover = pop
	}
	//This will be good to have for later
	func displayColumnOptionsAsWindow(sender: Any?) {
		let tabView = NSStoryboard(name: "LayoutEditor", bundle: nil).instantiateInitialController() as? LayoutEditorTabViewController
		let layoutEditor = tabView?.tabViewItems[0].viewController as! LayoutEditorViewController
		tabView?.viewController = self
		layoutEditor.runController = self
		let destination = tabView?.tabViewItems[1].viewController as! ColumnOptionsViewController
		destination.delegate = self
		
		let coPanel = NSPanel(contentViewController: tabView!)
		
		
//		coPanel.styleMask.insert(.utilityWindow)
//		coPanel.styleMask.insert(.hudWindow)
//		coPanel.styleMask.insert(.resizable)
//		coPanel.styleMask.insert(.fullSizeContentView)
		coPanel.titlebarAppearsTransparent = true
		coPanel.standardWindowButton(.miniaturizeButton)?.isHidden = true
		coPanel.standardWindowButton(.zoomButton)?.isHidden = true
		coPanel.isMovableByWindowBackground = true
		
		
		coPanel.animationBehavior = .none
//		coPanel.appearance = NSAppearance(named: .darkAqua)
		
		var coButtonPoint = CGPoint(x: columnOptionsPopoverButton.frame.maxX, y: 0)
		coButtonPoint = columnOptionsPopoverButton.convert(coButtonPoint, to: view)
		coButtonPoint = view.window!.convertPoint(toScreen: coButtonPoint)
		coPanel.setFrameTopLeftPoint(coButtonPoint)
		
		let windowController = NSWindowController(window: coPanel)
		
		windowController.showWindow(nil)
	}
	
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	//TODO: See if necessary
	override func keyDown(with event: NSEvent) {
		super.keyDown(with: event)
	}
}
extension Notification.Name {
	static let updateComponents = Notification.Name("updateComponents")
}

//TODO: See if this should be in a separate file, and if it should be with the VC or on its own or in Data
//IDK why I added this, but it looks important
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

// MARK: - Handling windows
//This code helps Splitter keep track of the different windows the app may have open
extension ViewController: NSWindowDelegate {

	func DidBecomeKey(_ notification: Notification) {
		let showHideUIItem = NSApp.mainMenu?.item(withIdentifier: menuIdentifiers.appearanceMenu.hideButtons)
		showHideUIItem?.title = showHideButtonsText
		
		let showHideTitleBarItem = NSApp.mainMenu?.item(withIdentifier: menuIdentifiers.appearanceMenu.hideTitleBar)
		showHideTitleBarItem?.title = showHideTitleBarItemText
		
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
