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
	
	@IBOutlet var tableView: NSTableView!

	override func viewDidLoad() {
		super.viewDidLoad()
		observer = NSApp.observe(\.effectiveAppearance, options: [.new, .old, .initial, .prior], changeHandler: {app, change in
			if let c = change.newValue {
				self.fixAppearance(c)
			}
		})
		
		darkSpinnerView = DarkSpinnerView(sourceView: self.view, sourceFrame: self.view.frame)
		loadCategories { cats in
			if let cats = cats {
				self.categories = cats
				self.tableView.reloadData()
			}
			self.hideSpinner()
		}
	}
	
	//MARK: - Loading Spinner
	var darkSpinnerView: DarkSpinnerView?
	
	func showSpinner() {
		view.addSubview(darkSpinnerView!)
	}
	
	func hideSpinner() {
		darkSpinnerView?.removeFromSuperview()
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
		if tableView.numberOfSelectedRows != 1 { return}
		let cat = categories[tableView.selectedRow]
		
		let loadingView = LoadingViewController()
		loadingView.loadViewFromNib()
		loadingView.labelView.stringValue = "Downloading..."
		self.presentAsSheet(loadingView)
		func showErrorAlert() {
			let alert = NSAlert()
			alert.messageText = "Splitter was unable to download the file"
			alert.runModal()
			self.dismiss(loadingView)
		}
		splitsIO.getRunFromCat(categoryID: cat.id, completion: { run in
			if let run = run {
				do {
					let d: lss = try (SplitterDocumentController.shared as! SplitterDocumentController).makeBlankUntitledDocument(ofType: DocFileType.liveSplit.rawValue) as! lss
					d.template = true
					let url = URL(string: run)!
					d.tempURL = url
					NSDocumentController.shared.addDocument(d)
					d.makeWindowControllers()
					if let vc =  d.windowControllers.first?.window?.contentViewController as? ViewController {
						self.dismiss(loadingView)
						vc.view.window?.makeKeyAndOrderFront(nil)
					}
				} catch {
					showErrorAlert()
				}
			} else {
				showErrorAlert()
			}
		})
	}
	
	
}

extension CategoryViewController: NSTableViewDelegate, NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return categories.count
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		if let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView {
			cell.textField?.stringValue = categories[row].name
			return cell
		}
		return nil
		
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		let selection: [Int] = tableView.selectedRowIndexes.map({$0})
		if selection.count > 0 {
			nextButton.isEnabled = true
		} else {
			nextButton.isEnabled = false
		}
	}
}
