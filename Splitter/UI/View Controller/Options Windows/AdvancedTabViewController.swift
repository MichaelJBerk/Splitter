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

class AdvancedTabViewController: NSTabViewController {
	var delegate: ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
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
