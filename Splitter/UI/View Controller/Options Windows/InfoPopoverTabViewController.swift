//
//  AdvancedTabViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/3/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

protocol advancedTabDelegate {
	var delegate: ViewController? { get set }
	func setupDelegate()
}

class InfoPopoverTabViewController: NSTabViewController {
	var delegate: ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
		if let d = delegate {
		}
		
        // Do view setup here.
    }
	
	func setupTabViews() {
		for i in tabViewItems {
			if var v = i.viewController as? advancedTabDelegate {
				v.delegate = self.delegate
				v.setupDelegate()
			}
		}
	}
    
}
