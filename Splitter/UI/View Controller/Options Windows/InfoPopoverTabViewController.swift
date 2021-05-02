//
//  AdvancedTabViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/3/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

var splitNoteText = "Note: These settings will be saved to this file, and will take effect whenever the file is opened. "
var notSplitNoteText = "Note: These settings will not be saved to this file unless it is saved in the .split format"

protocol advancedTabDelegate {
	var delegate: ViewController? { get set }
	var run: SplitterRun! {get set}
	func setupDelegate()
	var height: CGFloat {get}
}

extension advancedTabDelegate {
	
	var height: CGFloat {
		return 325
	}
	
}
///ViewController that manages the "Get Info" popover
class InfoPopoverTabViewController: NSTabViewController {
	static var storyboardID = "Advanced"
	var delegate: ViewController?
	var run: SplitterRun!

    override func viewDidLoad() {
        super.viewDidLoad()
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
			if var v = i.viewController as? advancedTabDelegate {
				v.delegate = self.delegate
				v.run = self.run
				v.setupDelegate()
			} else if var v = i.viewController?.view as? advancedTabDelegate {
				v.delegate = self.delegate
				v.run = self.run
				v.setupDelegate()
			}
		}
	}
    
	override func addTabViewItem(_ tabViewItem: NSTabViewItem) {
		tabViewItem.color = .blue
		super.addTabViewItem(tabViewItem)
	}
	override func viewWillDisappear() {
		NSColorPanel.shared.close()
		super.viewWillDisappear()
	}
}
