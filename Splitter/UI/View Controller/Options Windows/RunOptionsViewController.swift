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
	@IBOutlet weak var CompareToPopUpButton: NSPopUpButton!
	
	@IBOutlet weak var RoundDiffPopUpButton: NSPopUpButton!
	override func viewDidLoad() {
        super.viewDidLoad()
		print(CompareToPopUpButton.itemTitles)
		switch delegate?.compareTo {
		case .personalBest:
			CompareToPopUpButton.selectItem(at: 1)
		default:
			CompareToPopUpButton.selectItem(at: 0)
		}
        // Do view setup here.
    }
	@IBAction func changeCompareToPopUpButton(_ sender: Any) {
		if CompareToPopUpButton.selectedItem?.title == "Personal Best" {
			delegate?.compareTo = .personalBest
		} else {
			delegate?.compareTo = .previousSplit
		}
	}
	@IBAction func changeRoundDiffPopupButton(_ sender: Any) {
		
	}
	
}
