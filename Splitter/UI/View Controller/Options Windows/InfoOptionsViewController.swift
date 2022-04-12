//
//  InfoOptionsViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/3/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import LiveSplitKit



class InfoOptionsViewController: NSViewController, NSPopoverDelegate, NSTextFieldDelegate {
	static var storyboardID = "infoTab"
	var run: SplitterRun!
	var delegate: ViewController?
	@IBOutlet weak var runTitleField: NSTextField!
	@IBOutlet weak var categoryField: NSTextField!
	@IBOutlet weak var attemptField: NSTextField!
	@IBOutlet weak var platformField: NSTextField!
	@IBOutlet weak var versionField: NSTextField!
	@IBOutlet weak var regionField: NSTextField!
	
	@IBOutlet weak var iconWell: MetadataImage!
	
	@IBOutlet weak var offsetField: NSTextField!
	
	@IBOutlet weak var comparisonPopUp: NSPopUpButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		getDataFromRun()
		
		iconWell.allowsUpdate = false
		iconWell.image = run.gameIcon
		iconWell.allowsUpdate = true
		
		attemptField.formatter = OnlyIntegerValueFormatter()
		
		runTitleField.delegate = self
		categoryField.delegate = self
		attemptField.delegate = self
		platformField.delegate = self
		versionField.delegate = self
		regionField.delegate = self
		
		comparisonPopUp.target = self
		comparisonPopUp.action = #selector(comparisonSelected(_:))
		
		NotificationCenter.default.addObserver(forName: .runEdited, object: run, queue: nil, using: { _ in
			self.getDataFromRun()
		})
		
    }
	
	var cComparisons: [String] {
		let r = run.timer.lsRun
		let compLen = r.customComparisonsLen()
		var comps = [String]()
		for i in 0..<compLen {
			comps.append(r.customComparison(i))
		}
		return comps
		
	}
	
	@objc func breakFunc() {
		
	}
	
	@IBAction func offsetTextFieldEdited(_ sender: Any?) {
		run.offset = Double(offsetField.stringValue) ?? 0
		run.updateLayoutState()
		let offset = run.offset
		offsetField.stringValue = "\(offset)"
		delegate?.updateTimer()
	}
	
	@IBOutlet weak var startEndDateFormatter: DateFormatter!
	
	func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		let realAppearance = view.effectiveAppearance.name
		popover.appearance = NSAppearance(named: realAppearance)
		return true
	}
	
	func controlTextDidEndEditing(_ obj: Notification) {
		updateRun()
	}
	
	///Loads the popover with data from the main window
	func getDataFromRun() {
		//If the user types a title on the view controller, then shows the info panel (without pressing enter on the TF first), delegate is nil
		if let delegate = self.delegate {
			iconWell.run = delegate.run
			runTitleField.stringValue = run.title
			categoryField.stringValue = run.subtitle
			attemptField.stringValue = "\(delegate.run.attempts)"
			platformField.stringValue = run.platform
			versionField.stringValue = run.gameVersion
			regionField.stringValue = run.region
			
			let current = run.getRunComparision()

			comparisonPopUp.menu = NSMenu()
			for comp in TimeComparison.allCases {
				comparisonPopUp.menu?.addItem(.init(title: comp.menuItemTitle, action: nil, keyEquivalent: ""))
			}
			comparisonPopUp.selectItem(withTitle: current.menuItemTitle)
		}
	}
	
	@objc func comparisonSelected(_ sender: NSPopUpButton) {
		guard let selectedItem = sender.selectedItem else {return}
		for comp in TimeComparison.allCases {
			if comp.menuItemTitle == selectedItem.title {
				run.setRunComparison(to: comp)
				return
			}
		}
	}
	
	///Sends data from the popover to the main window
	func updateRun() {
		run.title = runTitleField.stringValue
		run.subtitle = categoryField.stringValue
		run.attempts = Int(attemptField.stringValue) ?? 0
		run.platform = platformField.stringValue
		run.gameVersion = versionField.stringValue
		run.region = regionField.stringValue
	}
	
	@IBAction func clickComparisionHelpButton(_ sender: NSButton) {
		let comparisonHelpURL = URL(string: "https://github.com/MichaelJBerk/Splitter/wiki/Comparisons")!
		NSWorkspace.shared.open(comparisonHelpURL)
	}
	
}

class OnlyIntegerValueFormatter: NumberFormatter {

	override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {

		if partialString.isEmpty {
			return true
		}

		return Int(partialString) != nil
	}
}
