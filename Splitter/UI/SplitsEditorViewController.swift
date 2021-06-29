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
	
	
	var segmentIcons: [NSImage?] = []
	
	var editorSelected: Int? = nil
	@IBOutlet weak var outlineView: SplitsEditorOutlineView!
	@IBOutlet weak var addButton: NSButton!
	@IBOutlet weak var removeButton: NSButton!
	@IBOutlet weak var cancelButton: NSButton!
	@IBOutlet weak var okButton: NSButton!
	
	@IBAction func cancelButtonAction(_ sender: NSButton?) {
		editor.dispose()
		self.dismiss(nil)
	}
	@IBAction func okButtonAction(_ sender: NSButton?) {
		let newRun = editor.close()
		run.setRun(newRun)
		run.updateLayoutState()
		NotificationCenter.default.post(.init(name: .splitsEdited))
		self.dismiss(nil)
	}
	
	@IBAction func removeButtonAction(_ sender: NSButton?) {
		removeSegments()
	}
	
	
	@IBAction func addButtonAction(_ sender: NSButton?) {
		addSegmentBelow()
	}
	
	static func instantiateView(with run: SplitterRun) -> SplitsEditorViewController {
		let vc: SplitsEditorViewController = SplitsEditorViewController(nibName: self.nibName, bundle: nil)
		vc.run = run
		let editor = RunEditor(run.timer.lsTimer.getRun().clone())
		vc.editor = editor
		vc.processIconChanges()
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
	
	@objc func addSegmentBelow() {
		editor.insertSegmentBelow()
		didAddSegment()
	}
	@objc func addSegmentAbove() {
		editor.insertSegmentAbove()
		didAddSegment()
	}
	func removeSegments() {
		editor.removeSegments()
		didAddSegment()
	}
	func didAddSegment() {
		processIconChanges()
			outlineView.reloadData()
	}
	#if DEBUG
	func addDebugMenu() {
		let debugMenu = NSMenu(title: "Debug")
		debugMenu.addItem(withTitle: "Copy Editor State", action: #selector(copyEditorState), keyEquivalent: "")
		debugMenu.addItem(withTitle: "Icon Set", action: #selector(debugIconSet), keyEquivalent: "")
		view.menu = debugMenu
	}
	
	@objc func copyEditorState() {
		let pasteboard = NSPasteboard.general
		pasteboard.declareTypes([.string], owner: nil)
		pasteboard.setString(editor.stateAsJson(), forType: .string)
		let alert = QuickAlert(message: "Copied Editor State", image: nil)
		alert.show()
	}
	
	@objc func debugIconSet() {
		editor.selectOnly(0)
		outlineView.reloadData()
		let image = NSImage(named: NSImage.bluetoothTemplateName)!
		image.toLSImage({ pointer, len in
			editor.setGameIcon(pointer, len)
			
		})
		if let data = editorState.iconChange?.rawValue {
			let image = NSImage(data: data)
			QuickAlert(message: "Set Icon", image: image).show()
		}
		
	}
	#endif
	
	let segmentPasteboardType = NSPasteboard.PasteboardType(rawValue: "splitter.runSegment")

    override func viewDidLoad() {
		#if DEBUG
		addDebugMenu()
		#endif
		outlineView.draggingDestinationFeedbackStyle = .regular
		outlineView.editor = editor
		NotificationCenter.default.addObserver(forName: .splitsEdited, object: self.outlineView, queue: nil, using: { notification in
			self.outlineView.reloadData()
		})
		let plusMenu = NSMenu(title: "")
		plusMenu.addItem(withTitle: "Add Segment Below", action: #selector(addSegmentBelow), keyEquivalent: "")
		plusMenu.addItem(withTitle: "Add Segment Above", action: #selector(addSegmentAbove), keyEquivalent: "")
		addButton.menu = plusMenu
		
        super.viewDidLoad()
		outlineView.registerForDraggedTypes([segmentPasteboardType])
		
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
		let bestIndex = outlineView.column(withIdentifier: bestSegmentTimeColumnIdentifier)
		outlineView.tableColumns[bestIndex].width = 110
		
        // Do view setup here.
    }
	
	override func viewWillDisappear() {
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
		} else {
			return -1
		}
	}
	// Tell how many children each row has
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return editorState.segments?.count ?? 0
		} else {
			return 0
		}
	}
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
		let segment = item as! RunEditorSegmentState
		let segs = editorState.segments!
		guard let index = segs.firstIndex(of: segment) else {return nil}
		let pasteboardItem = NSPasteboardItem()
		pasteboardItem.setString("\(index.description)", forType: segmentPasteboardType)
		return pasteboardItem
	}
	func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
		let point = info.draggingLocation
		guard let item = item else {return []}
		let propSeg = item as! RunEditorSegmentState
		if outlineView.isMousePoint(point, in: outlineView.frame) {
			return .move
		} else {
			return []
		}
	}
	func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
		guard
			let pasteboardItem = info.draggingPasteboard.pasteboardItems?.first,
			let pasteboardString = pasteboardItem.string(forType: segmentPasteboardType),
			let segmentIndexToMove = Int(pasteboardString),
			let segmentAtNewRow = item as? RunEditorSegmentState,
			let newRow = editorState.segments?.firstIndex(of: segmentAtNewRow)
			else {return false}
		
		outlineView.beginUpdates()
		outlineView.moveItem(at: segmentIndexToMove, inParent: nil, to: newRow, inParent: nil)
		processIconChanges()
		outlineView.endUpdates()
		outlineView.reloadData()
		
		return true
		
	}
}
extension SplitsEditorViewController: NSOutlineViewDelegate {
	
	func processIconChanges(completion: () -> () = {}) {
		let state = editorState
		let segments = state.segments!
		for i in 0..<segments.count {
			while i >= segmentIcons.count {
				segmentIcons.append(nil)
			}
			if let iconChange = segments[i].iconChange {
				let newImage = NSImage(data: iconChange.rawValue)
				segmentIcons[i] = newImage
			}
		}
		completion()
		//gameicon change...
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		if let item = item as? RunEditorSegmentState {
			if tableColumn?.identifier == self.imageColumnIdentifier {
				let cellIdentifier = NSUserInterfaceItemIdentifier("outlineViewImageCell")
				let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
				let index = editorState.segments!.firstIndex(of: item)!
				var image: NSImage = .gameControllerIcon
				let segments = editorState.segments!
				if index < segmentIcons.count {
					if let change = segments[index].iconChange {
						image = NSImage(data: change.rawValue)!
					} else {
						if let segImage = segmentIcons[index] {
							image = segImage
						}
					}
				}
				cell.imageView?.image = image
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
			let tf = cell.textField as! LayoutEditorTextField
			tf.column = tableColumn!.identifier
			tf.delegate = self
			tf.stringValue = cellText
			return cell
		} else {
			return nil
		}
	}
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		let selection = outlineView.selectedRow
		if selection >= 0 {
			editor.selectOnly(selection)
			editorSelected = selection
		}
	}
}

extension SplitsEditorViewController: NSTextFieldDelegate {
	public func controlTextDidEndEditing(_ obj: Notification) {
		if let textfield = obj.object as? LayoutEditorTextField {
			let text = textfield.stringValue
			let id = textfield.column!
			switch id {
			case self.nameColumnIdentifier:
				self.editor.activeSetName(text)
			case self.splitTimeColumnIdentifier:
				_ = self.editor.activeParseAndSetSplitTime(text)
			case self.segmentTimeColumnIdentifier:
				_ = self.editor.activeParseAndSetSegmentTime(text)
			case self.bestSegmentTimeColumnIdentifier:
				_ = self.editor.activeParseAndSetBestSegmentTime(text)
			default:
				break
			}
			NotificationCenter.default.post(name: .splitsEdited, object: outlineView)
		}
	}
}
