//
//  CategoryViewController.swift
//  Splitter
//
//  Created by Michael Berk on 8/2/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import SplitsIOKit

protocol CategoryPickerDelegate {
	var game: SplitsIOGame? {get set}
}

class CategoryViewController: NSViewController {
	
	var delegate: CategoryPickerDelegate!
	var categories: [SplitsIOCat] = []
	var splitsIO = SplitsIOKit.shared
	var observer: NSKeyValueObservation?
	func fixAppearance(_ appearance: NSAppearance) {
		for view1 in view.subviews {
			view1.appearance = appearance
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		observer = NSApp.observe(\.effectiveAppearance, options: [.new, .old, .initial, .prior], changeHandler: {app, change in
			if let c = change.newValue {
				self.fixAppearance(c)
			}
		})
		popitem = categoryPopUpButton.selectedItem
		darkSpinnerView = DarkSpinnerView(sourceView: self.view, sourceFrame: self.view.frame)
		loadCategories { cats in
			if let cats = cats {
				self.categories = cats
				self.categoryPopUpButton.menu?.items = self.makeMenuItems(categories: cats)
//				self.categoryPopUpButton.selectItem(at: 0)
			}
			self.hideSpinner()
		}
	}
	
	//MARK: - Loading Spinner
	var darkSpinnerView: DarkSpinnerView?
	
	func showSpinner() {
//		categoryPopUpButton.select(nil)
		view.addSubview(darkSpinnerView!)
		categoryPopUpButton.isEnabled = false
		nextButton.isEnabled = false
	}
	
	func hideSpinner() {
		darkSpinnerView?.removeFromSuperview()
		categoryPopUpButton.isEnabled = true
		nextButton.isEnabled = true
		fixAppearance(NSApp.effectiveAppearance)	
	}
	
	//MARK: - Buttons
	
	@IBOutlet weak var cancelButton: NSButton!
	@IBOutlet weak var nextButton: NSButton!
	
	@IBAction func cancelButtonAction(_ sender: NSButton) {
		dismiss(nil)
	}
	@IBAction func nextButtonAction(_ sender: NSButton) {
		loadRun()
	}
	
	//MARK: Popup Button
	
	@IBOutlet weak var categoryPopUpButton: NSPopUpButton!
	var popitem: NSMenuItem? = nil
	
	@IBAction func popUpAction(_ sender: NSPopUpButton) {
		popitem = sender.selectedItem
	}
	//TODO: Get only user's categories, if download view is currently showing user's runs
	func loadCategories(completion: @escaping ([SplitsIOCat]?) -> Void) {
		if let game = delegate.game {
			showSpinner()
			if let shortName = game.shortname {
				splitsIO.getCategories(for: shortName, completion: { cats in
					let sorted = cats.sorted(by: { cat1, cat2 in
						return cat1.name < cat2.name
					})
					completion(sorted)
				})
			} else if game.categories.count > 0 {
				completion(game.categories)
			} else {
				completion(nil)
			}
		}
	}
	func makeMenuItems(categories: [SplitsIOCat]) -> [NSMenuItem] {
		var items: [NSMenuItem] = []
		for cat in categories {
			items.append(NSMenuItem(title: cat.name, action: nil, keyEquivalent: ""))
		}
		return items
	}
	
	//MARK: - Loading the run
	
	func loadRun() {
		let cat = categories[categoryPopUpButton.indexOfSelectedItem]
		
		let loadingView = LoadingViewController()
		loadingView.loadViewFromNib()
		loadingView.labelView.stringValue = "Downloading..."
		self.presentAsSheet(loadingView)
		
		splitsIO.getRunFromCat(categoryID: cat.id, completion: { run in
			if let run = run {
				let d = lss()
				d.template = true
				let url = URL(string: run)!
				d.tempURL = url
				NSDocumentController.shared.addDocument(d)
				d.makeWindowControllers()
				if let vc =  d.windowControllers.first?.window?.contentViewController as? ViewController {
					self.dismiss(loadingView)
					vc.view.window?.makeKeyAndOrderFront(nil)
				}
			} else {
                let alert = NSAlert()
                alert.messageText = "Splitter was unable to download the file"
                alert.runModal()
                self.dismiss(loadingView)
			}
		})
	}
	
	
}
