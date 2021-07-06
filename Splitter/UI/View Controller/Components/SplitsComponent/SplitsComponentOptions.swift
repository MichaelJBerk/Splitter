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
	func differenceOptions() -> NSView {
		
		let pbMenuItem = NSMenuItem(title: "Personal Best", action: nil, keyEquivalent: "")
		let prevMenuItem = NSMenuItem(title: "Previous Attempt", action: nil, keyEquivalent: "")
		
		let popupButton = ComponentPopUpButton(title: "", selectAction: { button in
			switch button.indexOfSelectedItem {
			case button.index(of: pbMenuItem):
				self.run.setComparison(to: .personalBest)
			case button.index(of: prevMenuItem):
				self.run.setComparison(to: .latest)
			default:
				break
			}
		})
		let menu = NSMenu()
		menu.addItem(pbMenuItem)
		menu.addItem(prevMenuItem)
		popupButton.menu = menu
		
		switch run.getComparision() {
		case .personalBest:
			popupButton.select(pbMenuItem)
		case .latest:
			popupButton.select(prevMenuItem)
		default:
			break
		}
		let compareLabel = NSTextField(labelWithString: "Compare To:")
		let stack = NSStackView(views: [compareLabel, popupButton])
		stack.orientation = .horizontal
		return stack
		
	}
	
	func options(for column: NSTableColumn) -> NSView {
		if column.identifier == STVColumnID.differenceColumn {
			return differenceOptions()
		}
		let timeOptionMenu = NSMenu()
		let segmentTimeOption = NSMenuItem(title: "Segment Time", action: nil, keyEquivalent: "")
		let splitTimeOption = NSMenuItem(title: "Split Time", action: nil, keyEquivalent: "")
		timeOptionMenu.addItem(segmentTimeOption)
		timeOptionMenu.addItem(splitTimeOption)
		var runColumn: SplitterRun.TimeColumn?
		switch column.identifier {
		case STVColumnID.currentSplitColumn:
			runColumn = .time
		case STVColumnID.bestSplitColumn:
			runColumn = .pb
		case STVColumnID.previousSplitColumn:
			runColumn = .previous
		default:
			break
		}
		
		let timeOptionButton = ComponentPopUpButton(title: "", selectAction: { button in
			let h = button.indexOfSelectedItem
			if let menuItem = button.menu?.items[h], let runColumn = runColumn {
				switch menuItem {
				case segmentTimeOption:
					if runColumn == .time {
						self.run.undoManager?.beginUndoGrouping()
						self.run.setUpdateWith(.segmentTime, for: runColumn)
						self.run.setStartWith(.comparsionSegmentTime, for: runColumn)
						self.run.undoManager?.endUndoGrouping()
					} else {
						self.run.setStartWith(.comparsionSegmentTime, for: runColumn)
					}
				case splitTimeOption:
					if runColumn == .time {
						self.run.undoManager?.beginUndoGrouping()
						self.run.setUpdateWith(.splitTime, for: runColumn)
						self.run.setStartWith(.comparisonTime, for: runColumn)
						self.run.undoManager?.endUndoGrouping()
					} else {
						self.run.setStartWith(.comparisonTime, for: runColumn)
					}
				default:
					break
				}
			}
		})
		timeOptionButton.menu = timeOptionMenu
		if let runColumn = runColumn {
			if runColumn == .time {
				let currentOption = run.getUpdateWith(for: runColumn)
				switch currentOption {
				case .segmentTime:
					timeOptionButton.select(segmentTimeOption)
				case .splitTime:
					timeOptionButton.select(splitTimeOption)
				default:
					break
				}
			} else {
				let currentOption = run.getStartWith(for: runColumn)
				switch currentOption {
				case .comparsionSegmentTime:
					timeOptionButton.select(segmentTimeOption)
				case .comparisonTime:
					timeOptionButton.select(splitTimeOption)
				default:
					break
				}
			}
		}
		
		let valueLabel = NSTextField(labelWithString: "Value")
		let valueStack = NSStackView(views: [valueLabel, timeOptionButton])
		
		let helpButton = helpButton()
		let helpText = """
		Split Time: Total time since the beginning of the run, at the time of the split
		
		Segment Time: The duration of the segment
		"""
		helpButton.helpString = helpText
		valueStack.addArrangedSubview(helpButton)
		
		valueStack.orientation = .horizontal
		return valueStack
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
