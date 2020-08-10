//
//  CategoryViewController.swift
//  Splitter
//
//  Created by Michael Berk on 8/2/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import SplitsIOKit

class CategoryViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		popitem = categoryPopUpButton.selectedItem
		showSpinner()
		loadCategories {
			self.hideSpinner()
		}
		
    }
	var model: DownloadModel!
	
	@IBOutlet weak var cancelButton: NSButton!
	@IBOutlet weak var nextButton: NSButton!
	var categories: [SplitsIOCat] = []
	var splitsIO = SplitsIOKit()
	
	@IBAction func cancelButtonAction(_ sender: NSButton) {
		dismiss(nil)
	}
	@IBAction func nextButtonAction(_ sender: NSButton) {
		loadRun()
	}
	func loadCategories(completion: @escaping () -> Void) {
		if let game = model.game {
			splitsIO.getCategories(for: game.shortname, completion: { cats in
				self.categories = cats
				self.categoryPopUpButton.menu?.items = self.makeMenuItems(categories: cats)
				completion()
			})
		}
	}
	func makeMenuItems(categories: [SplitsIOCat]) -> [NSMenuItem] {
		var items: [NSMenuItem] = []
		for cat in categories {
			items.append(NSMenuItem(title: cat.name, action: nil, keyEquivalent: ""))
		}
		return items
	}
	var darkSpinnerView: DarkSpinnerView?
	
	func showSpinner() {
		darkSpinnerView = DarkSpinnerView(sourceView: self.view)
		view.addSubview(darkSpinnerView!)
		categoryPopUpButton.isEnabled = false
		nextButton.isEnabled = false
	}
	
	func hideSpinner() {
		darkSpinnerView?.removeFromSuperview()
		categoryPopUpButton.isEnabled = true
		nextButton.isEnabled = true
	}
	
	@IBOutlet weak var categoryPopUpButton: NSPopUpButton!
	var popitem: NSMenuItem? = nil
	
	@IBAction func popUpAction(_ sender: NSPopUpButton) {
		popitem = sender.selectedItem
	}
	var vcToLoad: ViewController?
	
	func loadRun() {
		let cat = categories[categoryPopUpButton.indexOfSelectedItem]
		
		let loadingRunAlert = NSAlert()
		loadingRunAlert.messageText = "Loading run..."
		let loadingBar = NSProgressIndicator(frame: NSRect(x: 0, y: 0, width: 250, height: 16))
		loadingBar.isIndeterminate = true
		loadingRunAlert.accessoryView = loadingBar
		loadingBar.startAnimation(self)
		loadingRunAlert.beginSheetModal(for: view.window!, completionHandler: nil)
		
		splitsIO.getRunFromCat(categoryID: cat.id, completion: { run in
			let d = lss()
			let url = URL(string: run!)!
			d.tempURL = url
			NSDocumentController.shared.addDocument(d)
			d.makeWindowControllers()
			if let vc =  d.windowControllers.first?.window?.contentViewController as? ViewController {
				self.dismiss(self)
				vc.view.window?.makeKeyAndOrderFront(nil)
				self.view.window?.windowController?.close()
				AppDelegate.shared?.searchWindow.close()
			}
		})
	}
	
	
}
