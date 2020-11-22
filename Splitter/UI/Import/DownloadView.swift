//
//  DownloadView.swift
//  Splitter
//
//  Created by Michael Berk on 8/2/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
import SplitsIOKit

class DarkSpinnerView: NSView {
	var spin: NSProgressIndicator?
	
	convenience init(sourceView: NSView) {
		self.init(sourceView: sourceView, sourceFrame: sourceView.frame)
	}
	init(sourceView: NSView, sourceFrame: NSRect) {
		super.init(frame: sourceFrame)
		let centerX = (sourceFrame.width - 50) / 2
		let centerY = (sourceFrame.height - 50) / 2
		let layer = CALayer()
		layer.backgroundColor = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
		self.wantsLayer = true
		self.layer = layer
		let spinFrame = NSRect(origin: CGPoint(x: centerX, y: centerY), size: CGSize(width: 50, height: 50))
		spin = NSProgressIndicator(frame: spinFrame)
		spin?.style = .spinning
		self.addSubview(spin!)
		spin?.startAnimation(self)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
}

class DownloadViewController: NSViewController, CategoryPickerDelegate  {
	var sField: NSSearchField?
	var darkenView: DarkSpinnerView?
	var game: SplitsIOGame?
	var games: [SplitsIOGame] = []
	var selectedGame: SplitsIOGame?
	var sField2: NSSearchField!
	var splitsIO = SplitsIOKit.shared
	
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var nextButton: NSButton!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView?.delegate = self
		tableView?.dataSource = self
		darkenView = DarkSpinnerView(sourceView: self.view, sourceFrame: NSRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height + 50))
		showGamesOfCurrentRunner()
       
	}
	
	func showSpinner() {
		darkenView?.removeFromSuperview()
		tableView.deselectAll(nil)
		view.addSubview(darkenView!)
		tableView.isEnabled = false
	}
	func hideSpinner() {
		darkenView?.removeFromSuperview()
		tableView.isEnabled = true
	}
	
	var showingCurrentRunnerGames = true
	
	func showGamesOfCurrentRunner() {
		if let account = Settings.splitsIOUser {
			showSpinner()
			account.getGames(splitsIOKit: splitsIO, completion: showGames(games:))
            tableView.headerView = NSTableHeaderView()
            tableView.tableColumns[0].headerCell.title = "My Runs"
            if #available(macOS 11.0, *) {
                tableView.style = .inset
            }
		}
	}
	func showGames(games: [SplitsIOGame]?) {
		if let games = games {
			self.games = games
		} else {
			self.games = []
		}
		self.tableView.reloadData()
		self.hideSpinner()
	}
	
	
	@IBAction func searchAction(_ sender: NSSearchField) {
		if sender.stringValue.count > 0 {
			showingCurrentRunnerGames = true
			showSpinner()
			splitsIO.searchSplitsIO(for: sender.stringValue, completion: showGames(games:))
            tableView.headerView = nil
		} else {
			showingCurrentRunnerGames = false
			showGamesOfCurrentRunner()
		}
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		if segue.identifier == "pickCategorySegue", let destination = segue.destinationController as? CategoryViewController, tableView.selectedRow < games.count {
			destination.delegate = self
		}
	}
	func closeWindow() {
		view.window?.windowController?.close()
		AppDelegate.shared?.searchWindow.close()
	}
	
}

extension DownloadViewController: NSTableViewDelegate, NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return games.count
	}
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "GameSearchCell"), owner: self) as! NSTableCellView
		cell.textField?.stringValue = games[row].name
		
		return cell
	}
	func tableViewSelectionDidChange(_ notification: Notification) {
		if tableView.selectedRow >= 0 {
			game = games[tableView.selectedRow]
		} else {
			game = nil
		}
		
		if tableView.numberOfSelectedRows > 0 {
			
			nextButton.isEnabled = true
		}
		else {
			nextButton.isEnabled = false
		}
	}
}
