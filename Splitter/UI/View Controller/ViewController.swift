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

extension Notification.Name {
	static let timerStateChanged = Notification.Name("timerStateChanged")
}

class ViewController: NSViewController {
	
	//MARK: - Setting Up Buttons
	weak var gameIconButton: MetadataImage!
	weak var infoPanelPopoverButton: ThemedButton!
	weak var columnOptionsPopoverButton: ThemedButton!
	
	override var undoManager: UndoManager? {
		view.window?.windowController?.document?.undoManager
	}
	
//MARK: - Container Views
	@IBOutlet weak var mainStackView: DraggingStackView!
	@IBOutlet weak var tableButtonsStack: NSStackView!
	
//MARK: - Popovers
	var columnOptionsPopover: NSPopover?
	var columnOptionsWindow: NSWindow?
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
	/**
	The only color managed directly by ViewController is `selectedColor` - the others are managed by `run`.
	This is because of the weirdness with how LSL files can store color as different objects. We'll take care of that someother time.
	*/
	
	///
	var selectedColor: NSColor = .splitterRowSelected {
		willSet {
			let oldColor = self.selectedColor
			undoManager?.registerUndo(withTarget: self, handler: { r in
				r.selectedColor = oldColor
			})
			undoManager?.setActionName("Set Color")
			
		}
	}
	
	
//MARK: - Other UI Elements
	@IBOutlet weak var runTitleField: ThemedTextField!
	@IBOutlet weak var categoryField: ThemedTextField!
	@IBOutlet weak var timerLabel: ThemedTextField!
	@IBOutlet weak var currentTimeLabel: ThemedTextField!
	var attemptField: ThemedTextField!
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
	var milHundrethTimer = Timer()
	
	///The timer's state - either stopped, running, or paused
	var timerState: TimerState {
		get {
			run.timer.timerState
		}
		set {
			run.timer.timerState = newValue
		}
	}
	
	//MARK: - Split Data/Properties
	
	var currentSplit: TimeSplit? = nil
	var currentSplits: [SplitTableRow] = []
	var backupSplits: [SplitTableRow] = []
	var loadedFilePath: String = ""

	var compareTo: TimeComparison {
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
	var appearance: SplitterAppearance?
	var shouldLoadSplits = false
	
	//MARK: Splits.io Uploading
	var splitsIOUploader: SplitsIOUploader!
	
	//MARK: - Settings
	var enabledMenuItems:[NSUserInterfaceItemIdentifier: Bool] = [:]
	
	var windowFloat = false
	var buttonHidden = false
	var titleBarHidden = false
	var showBestSplits = false
	var hideTitle = false
	
	var hotkeysController: HotkeysViewController?
	
	@objc func breakFunc() {
		
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
	var titleRow: TitleComponent!
	var scrollViewComponent: SplitsComponent!
	
	func addToStack(view: SplitterComponent) {
		let position: Int = mainStackView.arrangedSubviews.count
		mainStackView.insertArrangedSubview(view, at: position)
		NSLayoutConstraint.activate([
			view.leadingConstraint,
			view.trailingConstraint
		])
		mainStackView.setCustomSpacing(view.afterSpacing, after: view)
	}
	func setupTitleRow() {
		titleRow = TitleComponent.instantiateView(run: self.run)
		titleRow.viewController = self
		titleRow.setupDefaultGameIcon()
		addToStack(view: titleRow)
		runTitleField = titleRow.gameTitleField
		categoryField = titleRow.gameSubtitleField
		gameIconButton = titleRow.gameIconButton
		infoPanelPopoverButton = titleRow.infoButton
	}
	
	func setupSplitTable() {
		scrollViewComponent = SplitsComponent.instantiateView()
		scrollViewComponent.viewController = self
		scrollViewComponent.run = self.run
		addToStack(view: scrollViewComponent)
		let splitTable = scrollViewComponent.documentView as! SplitterTableView
		splitsTableView = splitTable
		splitsTableView.viewController = self
		splitsTableView.delegate = self
		splitsTableView.dataSource = self
	}
	
	
	func setupOptionsRow() {
		optionsRow = OptionsRow.instantiateView(with: self.run, self)
		addToStack(view: optionsRow)
		columnOptionsPopoverButton = optionsRow.columnOptionsButton
		tableButtonsStack = optionsRow.tableButtonsStack
	}
	
	func setupPrevNextRow() {
		prevNextRow = PrevNextRow.instantiateView(run: run, viewController: self)
		
		addToStack(view: prevNextRow)
	}
	func setupStartRow() {
		startRow = StartRow.instantiateView(run: run, viewController: self)
		addToStack(view: startRow)
	}
	func setupTimeRow() {
		timeRow = TimeRow.instantiateView(run: run, viewController: self)
		addToStack(view: timeRow)
		
		timerLabel = timeRow.timeLabel
		attemptField = timeRow.attemptsField
	}
	
	func setupKeyValueComponent(key: KeyValueComponentType) {
		if let lIndex = run.addComponent(component: key.componentType) {
			let sumOfBestRow = KeyValueComponent.instantiateView(with: run, self, type: key, layoutIndex: lIndex)
			addToStack(view: sumOfBestRow)
			view.window?.layoutIfNeeded()
		}
	}
	func removeSumOfBestRow() {
		if let row = mainStackView.views.first(where: {$0 is KeyValueComponent}) {
			mainStackView.removeView(row)
		}
	}
	func removeView(view: SplitterComponent) {
		if let type = SplitterComponentType.FromType(view) {
			if view is KeyValueComponent {
				run.removeComponent(component: type)
			}
		}
		mainStackView.removeView(view)
	}
	
	private func setupDefaultStack() {
		setupTitleRow()
		setupSplitTable()
		setupOptionsRow()
		setupTimeRow()
		setupStartRow()
		setupPrevNextRow()
//		setupKeyValueComponent(key: .sumOfBest)
//		(mainStackView.views.last as? SplitterComponent)?.isHidden = true
//		setupKeyValueComponent(key: .previousSegment)
//		(mainStackView.views.last as? SplitterComponent)?.isHidden = true
//		setupKeyValueComponent(key: .totalPlaytime)
//		(mainStackView.views.last as? SplitterComponent)?.isHidden = true
	}
	///Handles various window-related tasks
	private func windowSetup() {
		
		if let welcome = AppDelegate.shared?.welcomeWindow {
			//Close the welcome window, if it's already open
			welcome.close()
		}
		view.window?.delegate = self
		view.window?.isMovableByWindowBackground = true
		
		view.window?.standardWindowButton(.zoomButton)?.isHidden = true
		view.window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
	}
	///Handles various tasks to set up certain keyboard commands, as well as the Touch Bar
	private func keyAndMenuSetup() {
		touchBarDelegate = RunTouchBarDelegate(splitFunc: startSplitTimer, pauseFunc: pauseResumeTimer, prevFunc: goToPrevSplit, stopFunc: stopTimer, sourceVC: self)
		
		#if DEBUG
		let breakMI = NSMenuItem(title: "Break", action: #selector(breakFunc), keyEquivalent: "b")
		breakMI.keyEquivalentModifierMask = .command
		breakMI.identifier = breakID
		NSApp.mainMenu?.item(at: 0)?.submenu?.addItem(breakMI)
		#endif
		
		setMenuItemEnabled(item: timerStopItem, enabled: false)
		setRightClickMenus()
	}
	
	private func addTimerStateChangedObserver() {
		NotificationCenter.default.addObserver(forName: .timerStateChanged, object: self.run.timer, queue: nil) {notification in
			if let timerState = notification.userInfo?["timerState"] as? TimerState {
				self.timerStateChanged(timerState: timerState)
			}
		}
	}
	private func addSplitChangedObserver() {
		NotificationCenter.default.addObserver(forName: .splitChanged, object: nil, queue: nil, using: { notification in
			self.updateButtonTitles()
		})
	}
	private func timerStateChanged(timerState: TimerState) {
		let prevSplitItem = view.window?.menu?.item(withIdentifier: menuIdentifiers.runMenu.back)
		if timerState == .stopped {
			setMenuItemEnabled(item: timerStopItem, enabled: false)
			timerStopItem?.title = "Cancel Run"
			startSplitItem?.title = "Start Timer"
			
			setMenuItemEnabled(item: startSplitItem, enabled: true)
			setMenuItemEnabled(item: prevSplitItem, enabled: false)
			setMenuItemEnabled(item: pauseMenuItem, enabled: false)
			
			setMenuItemEnabled(item: addRowMenuItem, enabled: true)
			setMenuItemEnabled(item: removeRowMenuItem, enabled: true)
			stopTimer()
			self.splitsTableView.reloadData(forRowIndexes: IndexSet(arrayLiteral: 0), columnIndexes: IndexSet(arrayLiteral: 0,1,2,3,4,5))
		} else if timerState == .running {
			timerStopItem?.title = "Cancel Run"
			setMenuItemEnabled(item: timerStopItem, enabled: true)
			
			startSplitItem?.title = "Split"
			setMenuItemEnabled(item: startSplitItem, enabled: true)
			setMenuItemEnabled(item: prevSplitItem, enabled: true)
			
			setMenuItemEnabled(item: pauseMenuItem, enabled: true)
			pauseMenuItem?.title = "Pause Timer"
			
			setMenuItemEnabled(item: addRowMenuItem, enabled: false)
			setMenuItemEnabled(item: removeRowMenuItem, enabled: false)
			touchBarDelegate.startSplitTitle = run.nextButtonTitle
			
		} else if timerState == .paused {
			setMenuItemEnabled(item: timerStopItem, enabled: true)
			timerStopItem?.title = "Cancel Run"
			setMenuItemEnabled(item: prevSplitItem, enabled: false)
			setMenuItemEnabled(item: pauseMenuItem, enabled: true)
			
			pauseMenuItem?.title = "Resume Timer"
			
			
			setMenuItemEnabled(item: startSplitItem, enabled: false)
		}
		touchBarDelegate.enableDisableButtons()
	}
	///Loads the data from the supplied `runInfo` file
	private func loadRunInfo() {
		if runInfoData != nil {
			if let doc = document as? Document,
			   let v = doc.versionUsed {
				if v < 4 {
					loadFromOldRunInfo(icons: doc.iconArray)
				} else {
					loadFromRunInfo()
					if let run = doc.run {
						self.run = run
						self.run.updateLayoutState()
						undoManager?.disableUndoRegistration()
						titleRow.setupDefaultGameIcon()
						undoManager?.enableUndoRegistration()
					}
				}
				if let gameIcon = doc.gameIcon {
					self.run.gameIcon = gameIcon
					self.run.updateLayoutState()
				}
			}
		}
	}
	
	func addComponent(_ component: SplitterComponentType) {
		switch component {
		case .title:
			setupTitleRow()
		case .splits:
			setupSplitTable()
		case .tableOptions:
			setupOptionsRow()
		case .time:
			setupTimeRow()
		case .start:
			setupStartRow()
		case .prevNext:
			setupPrevNextRow()
		case .sumOfBest:
			setupKeyValueComponent(key: .sumOfBest)
		case .previousSegment:
			setupKeyValueComponent(key: .previousSegment)
		case .totalPlaytime:
			setupKeyValueComponent(key: .totalPlaytime)
		}
	}
	
	
	var document: SplitterDoc!
	
	//MARK: - Main Functions
	override func viewWillAppear() {
		super.viewWillAppear()
		if run == nil {
			run = SplitterRun(run: Run(), isNewRun: true)
			run.document = self.document
		}
		undoManager?.disableUndoRegistration()
		print(run.segmentCount)
		if let components = appearance?.components {
			for component in components {
				addComponent(component.type)
				try? (mainStackView.views.last as! SplitterComponent).loadState(from: component)
			}
		} else {
			setupDefaultStack()
		}
		
		windowSetup()
		loadRunInfo()
		keyAndMenuSetup()
		run.document = document
	
		//Load the SplitterAppearance file if it exists. Otherwise, use the default appearance
		if appearance != nil {
			setSplitterAppearance(appearance: appearance!)
		} else {
			setUpDefaults()
		}
		
		//Handle FileID, for proper window placement restoration
		if fileID == nil {
			fileID = UUID().uuidString
		}
		view.window?.setFrameAutosaveName(fileID!)
		
		//Need to add a blank split b/c of how LiveSplit-Core works
		if currentSplits.count == 0 {
			addBlankSplit()
		}
		
		view.window?.makeFirstResponder(splitsTableView)
		
		splitsIOUploader = SplitsIOUploader(viewController: self)
		
		self.addTimerStateChangedObserver()
		//This line of code looks redundant, but it's here in order to make the timerState's notification trigger
		self.timerState = .stopped
		self.addSplitChangedObserver()
		
		updateTextFields()
		
		print("VWA Done!")
		splitsTableView.reloadData()
		setColorForControls()
		
		NotificationCenter.default.addObserver(forName: .runEdited, object: nil, queue: nil, using: { notification in
			self.updateTextFields()
			self.updateTimer()
		})
		NotificationCenter.default.addObserver(forName: .splitsEdited, object: nil, queue: nil, using: { notification in
			self.splitsTableView.reloadData()
		})
		NotificationCenter.default.addObserver(forName: .updateIsEdited, object: self.run.timer, queue: nil, using: { notification in
			self.document.updateChangeCount(.changeDone)
		})
		NotificationCenter.default.addObserver(forName: .runColorChanged, object: nil, queue: nil, using: { _ in
			self.setColorForControls()
		})
		undoManager?.enableUndoRegistration()
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
	
	///Sets up default appearance. Used when opening a new file, or any other case where there's no `splitterAppearance` file
	func setUpDefaults() {
		titleBarHidden = Settings.hideTitleBar
		showHideTitleBar()
		
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
		self.view.wantsLayer = true
	}
	
	override func viewWillDisappear() {
		infoPanelPopover?.contentViewController?.view.window?.close()
		columnOptionsPopover?.contentViewController?.view.window?.close()
		columnOptionsWindow?.close()
		super.viewWillDisappear()
	}
	
	///Displays the "get info" popover
	@IBAction func displayInfoPopover(_ sender: Any) {
		infoPanelPopover?.contentViewController?.view.window?.close()
		let destination = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: InfoPopoverTabViewController.storyboardID) as! InfoPopoverTabViewController
		destination.delegate = self
		destination.run = self.run
		let pop = NSPopover()
		pop.delegate = self
		pop.contentViewController = destination
		pop.contentSize = NSSize(width: 450, height: 325)
		pop.behavior = .semitransient
		pop.appearance = NSAppearance(named: .vibrantDark)
		pop.show(relativeTo: infoPanelPopoverButton.frame, of: titleRow, preferredEdge: .maxX)
		infoPanelPopover = pop
		destination.setupTabViews()
	}
	
	///Displays the "column options" popover
	@IBAction func displayColumnOptionsPopover(_ sender: Any) {
		columnOptionsPopover?.contentViewController?.view.window?.close()
		let layoutEditor = NSStoryboard(name: "LayoutEditor", bundle: nil).instantiateInitialController() as! LayoutEditorViewController
		layoutEditor.runController = self
		let pop = NSPopover()
		pop.delegate = self
		pop.contentViewController = layoutEditor
		pop.appearance = NSAppearance(named: .vibrantDark)
		pop.behavior = .semitransient
		var columnOptionsFrame = columnOptionsPopoverButton.frame
		columnOptionsFrame = self.tableButtonsStack.convert(columnOptionsFrame, to: self.view)
		let redView = NSView(frame: columnOptionsFrame)
		redView.wantsLayer = true
		redView.layer?.backgroundColor = NSColor.red.cgColor
		self.view.addSubview(redView)
		pop.show(relativeTo: columnOptionsFrame, of: self.view, preferredEdge: .maxX)
//		pop.show(relativeTo: columnOptionsPopoverButton.frame, of: tableButtonsStack, preferredEdge: .maxX)
		columnOptionsPopover = pop
	}
	
	func displayColumnOptionsAsWindow(sender: Any?) {
		if let coWindow = columnOptionsWindow {
			coWindow.makeKeyAndOrderFront(self)
		} else {
			let layoutEditor = NSStoryboard(name: "LayoutEditor", bundle: nil).instantiateInitialController() as! LayoutEditorViewController
			layoutEditor.runController = self
			
			let coPanel = NSPanel(contentViewController: layoutEditor)
			coPanel.titlebarAppearsTransparent = true
			coPanel.styleMask.insert(.utilityWindow)
			coPanel.styleMask.insert(.fullSizeContentView)
			coPanel.titleVisibility = .hidden
			coPanel.standardWindowButton(.miniaturizeButton)?.isHidden = true
			coPanel.standardWindowButton(.zoomButton)?.isHidden = true
			coPanel.isMovableByWindowBackground = true
			
			coPanel.animationBehavior = .utilityWindow
			
			var coButtonPoint = CGPoint(x: columnOptionsPopoverButton.frame.maxX, y: 0)
			coButtonPoint = columnOptionsPopoverButton.convert(coButtonPoint, to: view)
			coButtonPoint = view.window!.convertPoint(toScreen: coButtonPoint)
			coButtonPoint.x += 10
			coPanel.setFrameTopLeftPoint(coButtonPoint)
			coPanel.collectionBehavior = .transient
			coPanel.appearance = self.view.effectiveAppearance
			let windowController = NSWindowController(window: coPanel)
			columnOptionsWindow = coPanel
			windowController.showWindow(nil)
			
		}
	}
	func openSplitsEditorWindow() {
		let tvc = SplitsEditorViewController.instantiateView(with: run)
//		let win = NSPanel(contentViewController: tvc)
//		win.title = "Split Editor"
//		win.styleMask.insert(.utilityWindow)
//		win.styleMask.insert(.fullSizeContentView)
//		win.delegate = document
//		let winC = NSWindowController(window: win)
//		winC.document = document
//		win.appearance = self.view.effectiveAppearance
//		winC.showWindow(nil)
		presentAsSheet(tvc)
	}
	var splitsEditorPopover: NSPopover?
	
	func openSplitsEditorPopover() {
		splitsEditorPopover?.close()
		let tvc = SplitsEditorViewController.instantiateView(with: run)
		let pop = NSPopover()
		pop.delegate = self
		pop.contentViewController = tvc
		pop.behavior = .semitransient
		var columnOptionsFrame = columnOptionsPopoverButton.frame
		columnOptionsFrame = self.tableButtonsStack.convert(columnOptionsFrame, to: self.view)
		pop.show(relativeTo: columnOptionsFrame, of: self.view, preferredEdge: .maxX)
		splitsEditorPopover = pop
		
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
