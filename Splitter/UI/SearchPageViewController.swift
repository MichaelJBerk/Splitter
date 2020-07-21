//
//  SearchPageViewController.swift
//  Splitter
//
//  Created by Michael Berk on 7/17/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

class SearchPageViewController: NSPageController, NSPageControllerDelegate {
	

	var viewIDS = ["Label1", "Label2"]
    override func viewDidLoad() {
        super.viewDidLoad()
		delegate = self
		arrangedObjects = viewIDS
        // Do view setup here.
    }
	
	func pageController(_ pageController: NSPageController, viewControllerForIdentifier identifier: NSPageController.ObjectIdentifier) -> NSViewController {
		return NSStoryboard(name: "Search", bundle: nil).instantiateController(withIdentifier: identifier) as! NSViewController
	}
	func pageController(_ pageController: NSPageController, identifierFor object: Any) -> String {
		  return String(describing: object)
	   
	  }
   
	  func pageControllerDidEndLiveTransition(_ pageController: NSPageController) {
		  self.completeTransition()
	  }
    
}
