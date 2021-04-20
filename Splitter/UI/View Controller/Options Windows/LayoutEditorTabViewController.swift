//
//  LayoutEditorTabViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/22/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class LayoutEditorTabViewController: NSTabViewController {
	var visualEffect: NSVisualEffectView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
//		visualEffect = NSVisualEffectView(frame: NSRect(x: 0, y: 50, width: tabView.contentRect.width, height: tabView.contentRect.height + 500))
//		visualEffect.translatesAutoresizingMaskIntoConstraints = false
//		tabView.translatesAutoresizingMaskIntoConstraints = false
//		visualEffect.material = .dark
//		visualEffect.state = .active
//		self.view = visualEffect
//		visualEffect.addSubview(tabView)
		
//		visualEffect.leadingAnchor.constraint(equalTo: tabView.leadingAnchor).isActive = true
//		visualEffect.trailingAnchor.constraint(equalTo: tabView.trailingAnchor).isActive = true
//		visualEffect.topAnchor.constraint(equalTo: tabView.topAnchor).isActive = true
//		visualEffect.bottomAnchor.constraint(equalTo: tabView.bottomAnchor).isActive = true
        // Do view setup here.
    }
	var viewController: ViewController!
	
	override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
		super.tabView(tabView, didSelect: tabViewItem)
		self.title = tabViewItem?.label
		if let v = tabViewItem?.viewController {
			self.preferredContentSize = v.preferredContentSize
			if let pop = viewController.columnOptionsPopover {
				pop.contentSize = v.preferredContentSize
			} else {
				if let window = view.window {
					let newFrame = NSRect(x: window.frame.origin.x, y: window.frame.origin.y, width: v.preferredContentSize.width, height: v.preferredContentSize.height)
					self.view.window?.setFrame(newFrame, display: false, animate: false)
//					self.view.window?.animator().setFrame(newFrame, display: true, animate: true)
				}
			}
		}
	}
    
}
