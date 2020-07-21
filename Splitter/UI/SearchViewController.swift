//
//  SearchViewController.swift
//  Splitter
//
//  Created by Michael Berk on 7/17/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

class SearchViewController: NSViewController, NSPageControllerDelegate {
	@IBOutlet weak var nextButton: NSButton!
	@IBOutlet weak var prevButton: NSButton!
	weak var tabViewController: NSTabViewController?
	weak var pageViewController: NSPageController?
	@IBOutlet weak var containerView: NSView!
	var viewIDS = ["Label1", "Label2"]
	

    override func viewDidLoad() {
		
        super.viewDidLoad()
		
		
        // Do view setup here.
    }
	
	@IBAction func nextClick(_ sender: Any?) {
//		pageViewController.navigateForward(sender)
		tabViewController?.transitionOptions = .slideForward
		tabViewController?.tabView.selectNextTabViewItem(sender)
	}
	@IBAction func prevClick(_ sender: Any?) {
//		pageViewController.navigateBack(sender)
		tabViewController?.transitionOptions = .slideBackward
		tabViewController?.tabView.selectPreviousTabViewItem(sender)
	}
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		guard let pageViewController = segue.destinationController as? NSPageController else {
			guard let tabViewController = segue.destinationController as? NSTabViewController else {return}
			
			self.tabViewController = tabViewController
			
			return
		}
		pageViewController.delegate = self
		pageViewController.arrangedObjects = viewIDS
		self.pageViewController = pageViewController
//		guard let tabViewController = segue.destinationController as? NSTabViewController else {return}
//		self.tabViewController = tabViewController
	}
	func pageController(_ pageController: NSPageController, frameFor object: Any?) -> NSRect {
		return containerView.visibleRect
	}
	func pageController(_ pageController: NSPageController, viewControllerForIdentifier identifier: NSPageController.ObjectIdentifier) -> NSViewController {
		let vc = NSStoryboard(name: "Search", bundle: nil).instantiateController(withIdentifier: identifier) as! NSViewController
		vc.view.autoresizingMask = [.height, .width]
		
		return vc
	}
	func pageController(_ pageController: NSPageController, identifierFor object: Any) -> String {
		  return String(describing: object)
	   
	  }
   
	  func pageControllerDidEndLiveTransition(_ pageController: NSPageController) {
		  pageController.completeTransition()
		pageController.selectedViewController!.view.autoresizingMask = [.height, .width]
	  }
	
    
}

class label1VC: NSView {
//	override func draw(_ dirtyRect: NSRect) {
//		
////		view.window?.backgroundColor = .red
//		NSColor.red.set()
//		dirtyRect.fill()
//		super.draw(dirtyRect)
//		
//		// Drawing code here.
//	}
}


class label2VC: NSView {
//	override func draw(_ dirtyRect: NSRect) {
//		NSColor.red.set()
//		dirtyRect.fill()
//		super.draw(dirtyRect)
//
//		// Do view setup here.
//	}
}
