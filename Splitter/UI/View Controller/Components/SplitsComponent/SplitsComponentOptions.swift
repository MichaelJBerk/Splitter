//
//  SplitsComponentOptions.swift
//  Splitter
//
//  Created by Michael Berk on 7/5/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa
extension SplitsComponent {
	class SplitsOptionsView: ComponentOptionsVstack {
		typealias OptionsTab =  (view: NSView, title: String)
		var viewIndex: Int = 0 {
			didSet {
				for s in 1..<views.count {
					if s - 1 != viewIndex {
						views[s].isHidden = true
					} else {
						views[s].isHidden = false
					}
				}
			}
		}
		
		var tabs: [OptionsTab] = []
		
		var segmentedControl: NSSegmentedControl!
		
		var mainView: NSView! {
			tabs[viewIndex].view
		}
		
		@objc func tabChanged(sender: Any) {
			let sender = sender as! NSSegmentedControl
			viewIndex = sender.selectedSegment
		}
		
		static func makeView(tabs: [OptionsTab]) -> SplitsOptionsView {
			let seg = NSSegmentedControl(labels: tabs.map({$0.title}), trackingMode: .selectOne, target: nil, action: nil)
			seg.selectedSegment = 0
			let newView = SplitsOptionsView(views: [seg])
			newView.tabs = tabs
			newView.segmentedControl = seg
			newView.alignment = .centerX
			seg.target = newView
			seg.action = #selector(newView.tabChanged(sender:))
			for view in tabs.map({$0.view}) {
				newView.addArrangedSubview(view)
			}
			newView.viewIndex = 0
			return newView
		}
	
	}
	func options(for column: NSTableColumn) -> NSView {
		var views = [NSView]()
		let nameLabel = NSTextField(labelWithString: "Name")
		let nameField = NSTextField(string: column.title)
		let nameStack = NSStackView(views: [nameLabel, nameField])
		var fallback: Bool = false
		views.append(nameStack)
		
		let fallbackCheck = ComponentOptionsButton(checkboxWithTitle: "Fallback", clickAction: { _ in
			fallback.toggle()
		})
		fallbackCheck.state = .init(bool: fallback)
		fallbackCheck.isHidden = true
		
		
		let timeOptionMenu = NSMenu()
		let splitTimeOption = NSMenuItem(title: "Split Time", action: nil, keyEquivalent: "")
		let segmentTimeOption = NSMenuItem(title: "Segment Time", action: nil, keyEquivalent: "")
		let deltaOption = NSMenuItem(title: "Delta (Split Time)", action: nil, keyEquivalent: "")
		let segmentDeltaOption = NSMenuItem(title: "Delta (Segment Time)", action: nil, keyEquivalent: "")
		let emptyOption = NSMenuItem(title: "Nothing", action: nil, keyEquivalent: "")
		timeOptionMenu.addItem(splitTimeOption)
		timeOptionMenu.addItem(segmentTimeOption)
		timeOptionMenu.addItem(deltaOption)
		timeOptionMenu.addItem(segmentDeltaOption)
		timeOptionMenu.addItem(emptyOption)
		let timeOptionButton = ComponentPopUpButton(title: "", selectAction: { button in
			let h = button.indexOfSelectedItem
			if let menuItem = button.menu?.items[h] {
				if menuItem == deltaOption || menuItem == segmentDeltaOption {
					fallbackCheck.isHidden = false
				} else {
					fallbackCheck.isHidden = true
				}
			}
		})
		
		timeOptionButton.menu = timeOptionMenu
		let startLabel = NSTextField(labelWithString: "Value")
		let startStack = NSStackView(views: [startLabel, timeOptionButton])
		startStack.orientation = .horizontal
		let startVStack = NSStackView(views: [startStack, fallbackCheck])
		startVStack.orientation = .vertical
		startVStack.alignment = .leading
		views.append(startVStack)
		
		let deleteButton = ComponentOptionsButton(title: "Delete Column", clickAction: { _ in
			
		})
		if #available(macOS 11.0, *) {
			deleteButton.hasDestructiveAction = true
		}
		views.append(deleteButton)
		
		
		let stack = NSStackView(views: views)
		stack.orientation = .vertical
		stack.alignment = .leading
		return stack
	}
	
	enum TimeOption {
		
		case splitTime
		case segmentTime
		case delta(fallback: Bool)
		case segmentDelta(fallback: Bool)
		case empty
		
		var displayTitle: String {
			switch self {
			case .splitTime:
				return "Split Time"
			case .segmentTime:
				return "Segment Time"
			case .delta(fallback: _):
				return "Delta (Split Time)"
			case .segmentDelta(fallback: _):
				return "Delta (Segment Time)"
			case .empty:
				return "Nothing"
			}
		}
	}
	
	var columnOptionsView: NSView {
		let stack = ComponentOptionsVstack(views: [])
		stack.wantsLayer = true
		stack.alignment = .leading
		for c in splitsTableView.tableColumns {
			let cName = colIds.first(where: {$1 == c.identifier})?.key ?? "nil"
			let checkButton = ComponentOptionsButton(checkboxWithTitle: cName, clickAction: {_ in
				let colID = self.splitsTableView.column(withIdentifier: c.identifier)
				let col = self.splitsTableView.tableColumns[colID]
				col.isHidden.toggle()
				self.splitsTableView.setHeaderColor(textColor: self.run.textColor, bgColor: self.run.backgroundColor)
			})
			///Options for the current column
			let columnOptions = options(for: c)
			columnOptions.isHidden = true
			columnOptions.wantsLayer = true
			
			let columnStack  = NSStackView(views: [])
			var discloseView: NSView
			if c.identifier != STVColumnID.imageColumn && c.identifier != STVColumnID.splitTitleColumn {
				let discloseButton = ComponentOptionsButton(title: "", clickAction: { button in
					NSAnimationContext.runAnimationGroup({ context in
						context.duration = 0.25
						context.allowsImplicitAnimation = true
						columnOptions.isHidden.toggle()
						columnStack.layoutSubtreeIfNeeded()
					})
				})
				discloseButton.state = .off
				discloseButton.bezelStyle = .disclosure
				discloseButton.setButtonType(.pushOnPushOff)
				discloseView = discloseButton
			} else {
				let spacerView = NSView(frame: NSRect(x: 0, y: 0, width: 15, height: 15))
				discloseView = spacerView
			}
			NSLayoutConstraint.activate([
				discloseView.widthAnchor.constraint(equalToConstant: 15),
				discloseView.heightAnchor.constraint(equalToConstant: 15)
			])
			let checkButtonStack = NSStackView(views: [discloseView, checkButton])
			columnStack.addArrangedSubview(checkButtonStack)
			columnStack.addArrangedSubview(columnOptions)
			columnStack.orientation = .vertical
			columnStack.alignment = .leading
			checkButton.state = .init(bool: !c.isHidden)
			stack.addArrangedSubview(columnStack)
			NSLayoutConstraint.activate([
				columnStack.widthAnchor.constraint(equalTo: stack.widthAnchor),
				columnOptions.leadingAnchor.constraint(equalTo: checkButton.leadingAnchor)
			])
		}
		let plusButton = ComponentOptionsButton(image: NSImage(named: NSImage.addTemplateName)!, clickAction: {_ in})
		plusButton.setButtonType(.momentaryPushIn)
		plusButton.bezelStyle = .regularSquare
		plusButton.isBordered = false
		let minusButton = ComponentOptionsButton(image: NSImage(named: NSImage.removeTemplateName)!, clickAction: {_ in})
		minusButton.setButtonType(.momentaryPushIn)
		minusButton.bezelStyle = .regularSquare
		minusButton.isBordered = false
		let ph = plusButton.frame.height
		minusButton.frame.size.height = ph
		NSLayoutConstraint.activate([
			minusButton.heightAnchor.constraint(equalToConstant: 15),
			minusButton.widthAnchor.constraint(equalToConstant: 15),
			plusButton.heightAnchor.constraint(equalToConstant: 15),
			plusButton.widthAnchor.constraint(equalToConstant: 15)
		])
		
		let helpButton = ComponentOptionsButton(title: "", clickAction: {_ in})
		helpButton.bezelStyle = .helpButton
		
		
		let pmStack = NSStackView(views: [plusButton, minusButton, helpButton])
		stack.addArrangedSubview(pmStack)
		NSLayoutConstraint.activate([pmStack.widthAnchor.constraint(equalTo: stack.widthAnchor),
									 helpButton.trailingAnchor.constraint(equalTo: pmStack.trailingAnchor)])
		pmStack.orientation = .horizontal
		
		return stack
	}
	
	var optionsView: NSView! {
		let d = defaultComponentOptions() as! ComponentOptionsVstack
		let showHeaderButton = ComponentOptionsButton(checkboxWithTitle: "Show Header") {_ in
			self.showHeader.toggle()
		}
		showHeaderButton.state = .init(bool: showHeader)
		d.addArrangedSubview(showHeaderButton)

		let co = columnOptionsView
		let superStack = SplitsOptionsView.makeView(tabs: [(d, "Options"), (co, "Columns")])
		NSLayoutConstraint.activate([
			superStack.widthAnchor.constraint(equalTo: d.widthAnchor),
			co.widthAnchor.constraint(equalTo: superStack.widthAnchor),
		])
		return superStack
	}
}
