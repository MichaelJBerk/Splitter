//
//  SplitsEditorViewController.swift
//  Splitter
//
//  Created by Michael Berk on 6/25/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class SplitsEditorViewController: NSViewController, NibLoadable {
	
	var run: SplitterRun!
	var editor: RunEditor!
	var editorState: RunEditorState {
		editor.getState()
	}
	@IBOutlet weak var outlineView: NSOutlineView!
	@IBOutlet var addButton: NSButton!
	
	
	@IBAction func addButtonAction(_ sender: NSButton?) {
		editor.selectOnly(0)
	}
	
	static func instantiateView(with run: SplitterRun) -> SplitsEditorViewController {
		let vc: SplitsEditorViewController = SplitsEditorViewController(nibName: self.nibName, bundle: nil)
		vc.run = run
		vc.editor = RunEditor(run.timer.lsTimer.getRun().clone())
		return vc
	}
	
	var imageColumnIdentifier = NSUserInterfaceItemIdentifier("imageColumn")
	var nameColumnIdentifier = NSUserInterfaceItemIdentifier("nameColumn")
	var splitTimeColumnIdentifier = NSUserInterfaceItemIdentifier("splitTimeColumn")
	var segmentTimeColumnIdentifier = NSUserInterfaceItemIdentifier("segmentTimeColumn")
	var bestSegmentTimeColumnIdentifier = NSUserInterfaceItemIdentifier("bestSegmentTimeColumn")
	
	func columnIdentifierFor(comparison: String) -> NSUserInterfaceItemIdentifier {
		return NSUserInterfaceItemIdentifier(comparison + "Column")
	}
	
	func getSegment(_ index: Int) -> RunEditorSegmentState {
		let segments = editorState.segments!
		return segments[index]
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		var tableColumnsToAdd = [
			(column: NSTableColumn(identifier: self.splitTimeColumnIdentifier), name: "Split Time"),
			(column: NSTableColumn(identifier: segmentTimeColumnIdentifier), name: "Segment Time"),
			(column: NSTableColumn(identifier: bestSegmentTimeColumnIdentifier), name: "Best Segment Time")
		]
		editorState.comparisonNames?.forEach({ name in
			tableColumnsToAdd.append((column: NSTableColumn(identifier: columnIdentifierFor(comparison: name)), name: name))
		})
		for column in tableColumnsToAdd {
			column.column.title = column.name
			outlineView.addTableColumn(column.column)
		}
		
        // Do view setup here.
    }
	
	override func viewWillDisappear() {
		let newRun = editor.close()
		run.setRun(newRun)
		super.viewWillDisappear()
	}
	let dataValues = [
		["V1", "V2"],
		["V1", "V2"],
		["V1", "V2"]
	]
	let dataKeys = [
		"Key1",
		"Key2",
		"Key3",
	]
}

extension NSTableColumn {
	convenience init(rawIdentifier: String) {
		self.init(identifier: NSUserInterfaceItemIdentifier(rawIdentifier))
	}
}

extension SplitsEditorViewController: NSOutlineViewDataSource {
	
	
	// You must give each row a unique identifier, referred to as `item` by the outline view
	// item == nil means it's the "root" row of the outline view, which is not visible
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			let segment = getSegment(index)
			return segment
//			return dataKeys[index]
//		} else if let item = item as? String {
//			let i = dataKeys.firstIndex(of: item)!
//			return dataValues[i][index]
		} else {
			return -1
		}
	}
	// Tell how many children each row has:
	//    * The root row has 5 children: name, age, birthPlace, birthDate, hobbies
	//    * The hobbies row has how ever many hobbies there are
	//    * The other rows have no children
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return editorState.segments?.count ?? 0
//		} else if let item = item as? String {
//			let i = dataKeys.firstIndex(of: item)!
//			return dataValues[i].count
		} else {
			return 0
		}
	}
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
//		if let s = item as? String, let i = dataKeys.firstIndex(of: s), dataValues[i].count > 0{
//			return true
//		}
		return false
	}
}
extension SplitsEditorViewController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		if let item = item as? RunEditorSegmentState {
			if tableColumn?.identifier == self.imageColumnIdentifier {
				let cellIdentifier = NSUserInterfaceItemIdentifier("outlineViewImageCell")
				let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
				let index = editorState.segments!.firstIndex(of: item)!
				if let segIcon = run.icon(for: index) {
					cell.imageView?.image = segIcon
				} else {
					cell.imageView?.image = .gameControllerIcon
				}
				return cell
			}
			
			let cellIdentifier = NSUserInterfaceItemIdentifier("outlineViewTextCell")
			let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
			var cellText: String
			switch tableColumn?.identifier {
			case self.nameColumnIdentifier:
				cellText = item.name
			case self.splitTimeColumnIdentifier:
				cellText = item.splitTime
			case self.segmentTimeColumnIdentifier:
				cellText = item.segmentTime
			case self.bestSegmentTimeColumnIdentifier:
				cellText = item.bestSegmentTime
			default:
				return nil
			}
			cell.textField?.stringValue = cellText
			return cell
		} else {
			return nil
		}
	}
}
