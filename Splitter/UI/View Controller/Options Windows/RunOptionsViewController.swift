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
	var run: SplitterRun!
	func setupDelegate() {
		
	}
	@IBOutlet weak var compareToPopUpButton: NSPopUpButton!
	@IBOutlet weak var offsetTextField: NSTextField!
	
	@IBAction func offsetTextFieldEdited(_ sender: Any?) {
//		delegate?.run.editRun { editor in
		run.offset = Double(self.offsetTextField.stringValue) ?? 0
//		}
		run.updateLayoutState()
		let offset = run.offset
		offsetTextField.stringValue = "\(offset)"
		delegate?.updateTimer()
	}
	
	@IBOutlet weak var roundDiffPopUpButton: NSPopUpButton!
	override func viewDidLoad() {
        super.viewDidLoad()
		compareToPopUpButton.selectItem(at: delegateComparison)
		let offset = run.offset
		offsetTextField.stringValue = "\(offset)"
		
		//Only allow vaild strings in the Offset Text Field
		NotificationCenter.default.addObserver(forName: NSTextField.textDidChangeNotification, object: offsetTextField, queue: nil, using: {notfication in
			let tf = notfication.object as! NSTextField
			let charSet = NSCharacterSet(charactersIn: "1234567890.-").inverted
			let chars = tf.stringValue.components(separatedBy: charSet)
			tf.stringValue = chars.joined()
		})
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
			delegate?.compareTo = .latest
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
