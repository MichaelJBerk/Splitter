//
//  CustomComparisonList.swift
//  Splitter
//
//  Created by Michael Berk on 12/18/23.
//  Copyright © 2023 Michael Berk. All rights reserved.
//

import Cocoa
import LiveSplitKit
class LoadVC: NSViewController, NibLoadable {}

class CustomComparisonList: LoadVC {
	
	static func instantiateView(with run: SplitterRun, editor: RunEditor) -> CustomComparisonList {
		let vc: CustomComparisonList = CustomComparisonList(nibName: self.nibName, bundle: nil)
		vc.run = run
		vc.editor = editor
		return vc
	}
	
	var run: SplitterRun!
	var editor: RunEditor!
	@IBOutlet var tableView: NSTableView!
	@IBOutlet var addButton: NSButton!
	@IBOutlet var removeButton: NSButton!
	@IBOutlet var noContentView: NSView!
	
	override func loadView() {
		super.loadView()
		setupNoContentView(animated: false)
	}
	

    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.delegate = self
		self.tableView.dataSource = self
		loadData()
		self.tableView.selectRowIndexes(.init(integer: 0), byExtendingSelection: false)
        // Do view setup here.
    }
	
	func loadData() {
		self.tableView.reloadData()
		setupNoContentView()
	}
	
	func setupNoContentView(animated: Bool = true) {
		var view: NSView = noContentView
		if animated {view = noContentView.animator()}
		if self.compNames.count == 0 {
			view.isHidden = false
		} else {
			view.isHidden = true
		}
	}
	
	var state: RunEditorState {
		editor.getState()
	}
	
	var compNames: [String] {
		state.comparisonNames ?? []
	}
	
	var splitsEditor: SplitsEditorViewController? {
		presentingViewController as? SplitsEditorViewController
	}
	
	@IBAction func close(_ sender: Any?) {
		splitsEditor?.resetColumns()
		splitsEditor?.dismiss(self)
	}
    
	@IBAction func addButtonClick(_ sender: Any?) {
		addComparison()
	}
	
	@IBAction func removeButtonClick(_ sender: Any?) {
		removeComparison()
	}
	
	func addComparison() {
		let compCount = compNames.count + 1
		var nextComp = compCount
		while compNames.contains("Comparison \(nextComp)") {
			nextComp = nextComp + 1
		}
		_ = editor.addComparison("Comparison \(nextComp)")
		loadData()
	}
	
	func removeComparison() {
		if tableView.selectedRow >= 0 {
			let compName = compNames[tableView.selectedRow]
			editor.removeComparison(compName)
		}
		loadData()
	}
}

extension CustomComparisonList: NSTableViewDelegate, NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return (state.comparisonNames ?? []).count
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let compNames =  state.comparisonNames else {return nil}
		let cell = tableView.makeView(withIdentifier: .init("comparisonListCell"), owner: self) as! NSTableCellView
		let tf = cell.textField as! TableViewTextField
		tf.stringValue = compNames[row]
		tf.delegate = self
		tf.row = row
		tf.column = tableColumn?.identifier
		return cell
		
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		removeButton.isEnabled = (self.tableView.selectedRow >= 0)
	}
}

extension CustomComparisonList: NSTextFieldDelegate {
	
	func controlTextDidEndEditing(_ obj: Notification) {
		guard let compNames = state.comparisonNames,
			  let tf = obj.object as? TableViewTextField,
			  let row = tf.row
		else {return}
		let oldName = compNames[row]
		_ = editor.renameComparison(oldName, tf.stringValue)
	}
}
