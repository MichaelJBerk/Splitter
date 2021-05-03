//
//  LayoutEditorViewController.swift
//  Splitter
//
//  Created by Michael Berk on 3/22/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa
extension NSGridView {
	open override var isFlipped: Bool {
		return true
	}
}
extension NSMenuItem {
	convenience init(title: String, action: Selector, keyEquivalent: String, representedObject: Any?) {
		self.init(title: title, action: action, keyEquivalent: keyEquivalent)
		self.representedObject = representedObject
	}
}

class LayoutEditorViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
	@IBOutlet var tableView: NSTableView!
	@IBOutlet var scrollView: NSScrollView!
	@IBOutlet var optionsView: NSView!
	@IBOutlet var plusButton: NSButton!
	@IBOutlet var minusButton: NSButton!
	var rows = ["Row 1", "Row 2", "Row 3"]
	var dropType: NSPasteboard.PasteboardType = .init("public.data")
	var runController: ViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
		self.preferredContentSize = view.frame.size
		tableView.delegate = self
		tableView.dataSource = self
		tableView.registerForDraggedTypes([dropType])
		minusButton.isEnabled = false
    }
	
	var componentsPopUpMenu: NSMenu {
		var items = [NSMenuItem]()
		let existingTypes = runController.mainStackView.views.map({ SplitterComponentType.FromType(($0 as! SplitterComponent))})
		for type in SplitterComponentType.allCases {
			if !existingTypes.contains(type) {
				let t = type.componentType.init()
				items.append(.init(title: t.displayTitle, action: #selector(addComponent(sender:)), keyEquivalent: "", representedObject: type))
			}
		}
		let menu = NSMenu(title: "")
		for item in items {
			menu.addItem(item)
		}
		return menu
	}
	@objc func addComponent(sender: Any?) {
		if let sender = sender as? NSMenuItem,
		   let type = sender.representedObject as? SplitterComponentType {
			runController.addComponent(type)
		}
	}
	
	@IBAction func minusButtonClick(sender: Any?) {
		let sr = tableView.selectedRow
		if sr >= 0 {
			let viewToRemove = runController.mainStackView.views[sr]
			runController.mainStackView.removeView(viewToRemove)
		}
	}
	
	@objc func addSumOfBestComponent(sender: Any?) {
		runController.setupSumOfBestRow()
	}
	
	@IBAction func plusButtonClick(sender: Any?) {
		if let event = NSApplication.shared.currentEvent {
			NSMenu.popUpContextMenu(componentsPopUpMenu, with: event, for: plusButton)
		}
	}
	func numberOfRows(in tableView: NSTableView) -> Int {
		return runController.mainStackView.views.count
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
		if let component = runController.mainStackView.views[row] as? SplitterComponent {
			cell.textField?.stringValue = component.displayTitle
		}
		return cell
	}
	func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
		let pastboard = info.draggingPasteboard
		if let data = pastboard.string(forType: dropType), let oldRow = Int(data) {
			var views = runController.mainStackView.views
			views.move(fromOffsets: IndexSet([oldRow]), toOffset: row)
			runController.mainStackView.update(runController.mainStackView, views)
			tableView.reloadData()
			return true
		}
		return false
		// Dont' forget to update model
		
	}
	func tableViewSelectionDidChange(_ notification: Notification) {
		let selected = tableView.selectedRow
		if selected >= 0 {
			minusButton.isEnabled = true
		} else {
			minusButton.isEnabled = false
		}
		for i in 0..<runController.mainStackView.views.count {
			if let selectedComponent = runController.mainStackView.views[i] as? SplitterComponent {
				if i == selected {
					selectedComponent.isSelected = true
					let ov = selectedComponent.optionsView!
					scrollView.documentView = ov
					ov.translatesAutoresizingMaskIntoConstraints = false
					NSLayoutConstraint.activate([
						ov.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
						ov.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: -5),
						ov.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -5)
					])
				} else {
					selectedComponent.isSelected = false
				}
			}
		}
	}
	override func viewWillDisappear() {
		for v in runController.mainStackView.views {
			if let comp = v as? SplitterComponent {
				comp.isSelected = false
			}
		}
		
		super.viewWillDisappear()
	}
	func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
		
		let pasteBoard = NSPasteboardItem()
			
		pasteBoard.setString(String(row), forType: dropType)
		return pasteBoard
	}
	func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
		if dropOperation == .above {
			return .move
		}
		return []
	}
}

extension Array {
	func rearrange(fromIndex: Int, toIndex: Int) -> Array{
		var arr = self
		let element = arr.remove(at: fromIndex)
		arr.insert(element, at: toIndex)

		return arr
	}
}


//
//  DraggingStackView.swift
//  Analysis
//
//  Created by Mark Onyschuk on 2017-02-02.
//  Copyright © 2017 Mark Onyschuk. All rights reserved.
//
import Cocoa

class DraggingStackView: NSStackView {

	var isEnabled = true

	// MARK: -
	// MARK: Update Function
	var update: (NSStackView, Array<NSView>)->Void = { stack, views in
		var viewConstraints = [NSView: [NSLayoutConstraint]]()
		stack.views.forEach {
			viewConstraints[$0] = $0.constraints
			stack.removeView($0)
		}

		views.forEach {
			stack.addView($0, in: .leading)
			let comp = $0 as! SplitterComponent
			stack.setCustomSpacing(comp.afterSpacing, after: $0)

			switch stack.orientation {
			case .horizontal:
				$0.topAnchor.constraint(equalTo: stack.topAnchor).isActive = true
				$0.bottomAnchor.constraint(equalTo: stack.bottomAnchor).isActive = true

			case .vertical:
					NSLayoutConstraint.activate([
						comp.leadingConstraint,
						comp.trailingConstraint
					])
			@unknown default:
				break
			}
		}
	}


	// MARK: -
	// MARK: Event Handling
	override func mouseDragged(with event: NSEvent) {
//		if isEnabled {
//			let location = convert(event.locationInWindow, from: nil)
//			if let dragged = views.first(where: { $0.hitTest(location) != nil }) {
//				reorder(view: dragged, event: event)
//			}
//		} else {
//			super.mouseDragged(with: event)
//		}

	}

	private func reorder(view: NSView, event: NSEvent) {
		guard let layer = self.layer else { return }
		guard let cached = try? self.cacheViews() else { return }

		let container = CALayer()
		container.frame = layer.bounds
		container.zPosition = 1
		container.backgroundColor = NSColor.underPageBackgroundColor.cgColor

		cached
			.filter  { $0.view !== view }
			.forEach { container.addSublayer($0) }

		layer.addSublayer(container)
		defer { container.removeFromSuperlayer() }

		let dragged = cached.first(where: { $0.view === view })!

		dragged.zPosition = 2
		layer.addSublayer(dragged)
		defer { dragged.removeFromSuperlayer() }

		let d0 = view.frame.origin
		let p0 = convert(event.locationInWindow, from: nil)

		window!.trackEvents(matching: [.leftMouseDragged, .leftMouseUp], timeout: 1e6, mode: RunLoop.Mode.eventTracking) { event, stop in
			if let event = event {
				if event.type == .leftMouseDragged {
					let p1 = self.convert(event.locationInWindow, from: nil)
					
					let dx = (self.orientation == .horizontal) ? p1.x - p0.x : 0
					let dy = (self.orientation == .vertical)   ? p1.y - p0.y : 0
					
					CATransaction.begin()
					CATransaction.setDisableActions(true)
					dragged.frame.origin.x = d0.x + dx
					dragged.frame.origin.y = d0.y + dy
					CATransaction.commit()
					
					let reordered = self.views.map {
						(view: $0,
						 position: $0 !== view
							? NSPoint(x: $0.frame.midX, y: $0.frame.midY)
							: NSPoint(x: dragged.frame.midX, y: dragged.frame.midY))
					}
					.sorted {
						switch self.orientation {
						case .vertical: return $0.position.y < $1.position.y
						case .horizontal: return $0.position.x < $1.position.x
						@unknown default:
							return false
						}
					}
					.map { $0.view }
					
					let nextIndex = reordered.firstIndex(of: view)!
					let prevIndex = self.views.firstIndex(of: view)!
					
					if nextIndex != prevIndex {
						self.update(self, reordered)
						self.layoutSubtreeIfNeeded()
						
						CATransaction.begin()
						CATransaction.setAnimationDuration(0.15)
						CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
						
						for layer in cached {
							layer.position = NSPoint(x: layer.view.frame.midX, y: layer.view.frame.midY)
						}
						
						CATransaction.commit()
					}
					
				} else {
					view.mouseUp(with: event)
					stop.pointee = true
				}
			}
		}
	}

	// MARK: -
	// MARK: View Caching
	private class CachedViewLayer: CALayer {
		let view: NSView!

		enum CacheError: Error {
			case bitmapCreationFailed
		}

		override init(layer: Any) {
			self.view = (layer as! CachedViewLayer).view
			super.init(layer: layer)
		}

		init(view: NSView) throws {
			self.view = view

			super.init()

			guard let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { throw CacheError.bitmapCreationFailed }
			view.cacheDisplay(in: view.bounds, to: bitmap)

			frame = view.frame
			contents = bitmap.cgImage
		}

		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
	}

	private func cacheViews() throws -> [CachedViewLayer] {
		return try views.map { try cacheView(view: $0) }
	}

	private func cacheView(view: NSView) throws -> CachedViewLayer {
		return try CachedViewLayer(view: view)
	}
}