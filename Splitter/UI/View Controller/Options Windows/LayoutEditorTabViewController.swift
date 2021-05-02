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
					var newSize = v.preferredContentSize
					newSize.height += window.titlebarHeight
					window.animator().setSize(newSize: newSize, display: true, animate: true)
				}
			}
		}
	}
	override func viewDidDisappear() {
		viewController.columnOptionsWindow = nil
		super.viewDidDisappear()
	}
    
}

extension NSWindow {
	/// Sets the size of the window’s frame rectangle, with optional animation, according to a given size rectangle, thereby setting its and size onscreen.
	///
	/// - Note: Unlike `setFrame`, this method will try to keep the window at its current hieght
	/// - Parameters:
	///   - newSize: The size for the window, including the title bar.
	///   - display: Specifies whether the window redraws the views that need to be displayed. When true the window sends a `displayIfNeeded()` message down its view hierarchy, thus redrawing all views.
	///   - animate: Specifies whether the window performs a smooth resize. true to perform the animation, whose duration is specified by `animationResizeTime(_:)`.
	func setSize(newSize: NSSize, display: Bool, animate: Bool) {
		var newY = self.frame.origin.y
		newY += self.frame.size.height
		newY -= newSize.height
		let newFrame = NSRect(x: self.frame.origin.x, y: newY, width: newSize.width, height: newSize.height)
		self.setFrame(newFrame, display: display, animate: animate)
	}
	
	var titlebarHeight: CGFloat {
		frame.height - contentRect(forFrameRect: frame).height
	}

}
