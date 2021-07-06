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
	@IBOutlet weak var offsetTextField: NSTextField!
	
	@IBAction func offsetTextFieldEdited(_ sender: Any?) {
		run.offset = Double(self.offsetTextField.stringValue) ?? 0
		run.updateLayoutState()
		let offset = run.offset
		offsetTextField.stringValue = "\(offset)"
		delegate?.updateTimer()
	}
	
	@IBOutlet weak var roundDiffPopUpButton: NSPopUpButton!
	override func viewDidLoad() {
        super.viewDidLoad()
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
}
