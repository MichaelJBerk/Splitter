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
	var height: CGFloat {get}
}

extension advancedTabDelegate {
	
	var height: CGFloat {
		return 325
	}
	
}
class InfoPopoverTabViewController: NSTabViewController {
	var delegate: ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
		if let d = delegate {
		}
		
        // Do view setup here.
    }
	override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
		super.tabView(tabView, didSelect: tabViewItem)
		var v = tabViewItem?.viewController as? advancedTabDelegate
		
		if v == nil {
			v = tabViewItem?.viewController?.view as? advancedTabDelegate
		}
		if v != nil {
			self.delegate?.infoPanelPopover?.contentSize.height = v!.height
		}
		
		
	}
	
	func setupTabViews() {
		for i in tabViewItems {
//			print(i.label)
			if var v = i.viewController as? advancedTabDelegate {
				v.delegate = self.delegate
				v.setupDelegate()
			} else if var v = i.viewController?.view as? advancedTabDelegate {
				v.delegate = self.delegate
				v.setupDelegate()
			}
		}
	}
    
}
