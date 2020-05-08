//
//  RunOptionsViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/3/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

class RunOptionsViewController: NSViewController, advancedTabDelegate {
	var delegate: ViewController?
	
	func setupDelegate() {
		
	}
	@IBOutlet weak var compareToPopUpButton: NSPopUpButton!
	
	@IBOutlet weak var roundDiffPopUpButton: NSPopUpButton!
	override func viewDidLoad() {
        super.viewDidLoad()
		compareToPopUpButton.selectItem(at: delegateComparison)
		roundDiffPopUpButton.selectItem(at: delegateRound)
		
        // Do view setup here.
    }
	override func viewWillAppear() {
		super.viewWillAppear()
		if let d = delegate {
			d.infoPanelPopover?.contentSize.height = 325
		}
	}
	
	
	private var delegateComparison: Int {
		switch delegate?.compareTo {
		case .personalBest:
			return 1
		default:
			return 0
		}
	}
	
	private var delegateRound: Int {
		switch delegate?.roundTo {
		case .hundredths:
			return 1
		default:
			return 0
		}
	}
	
	
	@IBAction func changeCompareToPopUpButton(_ sender: Any) {
		if compareToPopUpButton.selectedItem?.identifier == .personalBest {
			delegate?.compareTo = .personalBest
		} else {
			delegate?.compareTo = .previousSplit
		}
	}
	@IBAction func changeRoundDiffPopupButton(_ sender: Any) {
		if roundDiffPopUpButton.selectedItem?.identifier == .hundredths {
			delegate?.roundTo = .hundredths
		} else {
			delegate?.roundTo = .tenths
		}
		delegate?.splitsTableView.reloadData()
	}
	
}


fileprivate extension NSUserInterfaceItemIdentifier {
	static let tenths = NSUserInterfaceItemIdentifier("tenths")
	static let hundredths = NSUserInterfaceItemIdentifier("hundredths")
	
	static let personalBest = NSUserInterfaceItemIdentifier("personalBest")
	static let previousSplit = NSUserInterfaceItemIdentifier("previousSplit")
}
