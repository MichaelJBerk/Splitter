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
		
        let diffColumnIndex = self.splitsTableView.column(withIdentifier: STVColumnID.differenceColumn)
		let sumOfBestMenuItem = NSMenuItem(title: "Sum of Best Time", action: nil, keyEquivalent: "")
		let prevMenuItem = NSMenuItem(title: "Previous Attempt", action: nil, keyEquivalent: "")
		let pbMenuItem = NSMenuItem(title:"Personal Best Time", action: nil, keyEquivalent: "")
		
		let popupButton = ComponentPopUpButton(title: "", selectAction: { button in
			switch button.indexOfSelectedItem {
			case button.index(of: sumOfBestMenuItem):
				self.run.setColumnComparison(.bestSegments, for: .diff)
			case button.index(of: prevMenuItem):
				self.run.setColumnComparison(.latest, for: .diff)
			case button.index(of: pbMenuItem):
				self.run.setColumnComparison(.personalBest, for: .diff)
			default:
				break
			}
			self.run.updateLayoutState()
			
			self.splitsTableView.reloadData(forRowIndexes: .init(0...self.splitsTableView.numberOfRows), columnIndexes: .init(integer: diffColumnIndex))
		})
		
		let menu = NSMenu()
		menu.addItem(pbMenuItem)
		menu.addItem(sumOfBestMenuItem)
		menu.addItem(prevMenuItem)
		popupButton.menu = menu
		
		switch run.getColumnComparison(for: .diff) {
		case .bestSegments:
			popupButton.select(sumOfBestMenuItem)
		case .latest:
			popupButton.select(prevMenuItem)
		case .personalBest:
			popupButton.select(pbMenuItem)
		default:
			break
		}
    
		let compareLabel = NSTextField(labelWithString: "Compare To")
		let compareStack = NSStackView(views: [compareLabel, popupButton])
        compareStack.orientation = .horizontal
        let timeOptions = segmentSplitOptions(for: splitsTableView.tableColumns[diffColumnIndex]) as! NSStackView
        let stack = NSStackView(views: [compareStack, timeOptions])
        NSLayoutConstraint.activate([
            timeOptions.views[1].leadingAnchor.constraint(equalTo: popupButton.leadingAnchor)
        ])
        stack.orientation = .vertical
        stack.alignment = .leading
        
		return stack
		
	}
    func segmentSplitOptions(for column: NSTableColumn) -> NSView {
        let timeOptionMenu = NSMenu()
        let segmentTimeOption = NSMenuItem(title: "Segment Time", action: nil, keyEquivalent: "")
        let splitTimeOption = NSMenuItem(title: "Split Time", action: nil, keyEquivalent: "")
        timeOptionMenu.addItem(segmentTimeOption)
        timeOptionMenu.addItem(splitTimeOption)
        var runColumn: SplitterRun.TimeColumn?
        switch column.identifier {
        case STVColumnID.differenceColumn:
            runColumn = .diff
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
                    } else if runColumn == .diff {
                        self.run.setUpdateWith(.segmentDelta, for: runColumn)
                    } else {
                        self.run.setStartWith(.comparsionSegmentTime, for: runColumn)
                    }
                case splitTimeOption:
                    if runColumn == .time {
                        self.run.undoManager?.beginUndoGrouping()
                        self.run.setUpdateWith(.splitTime, for: runColumn)
                        self.run.setStartWith(.comparisonTime, for: runColumn)
                        self.run.undoManager?.endUndoGrouping()
                    } else if runColumn == .diff {
                        self.run.setUpdateWith(.delta, for: runColumn)
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
            if runColumn == .time || runColumn == .diff {
                let currentOption = run.getUpdateWith(for: runColumn)
                switch currentOption {
                case .segmentTime, .segmentDelta, .segmentDeltaWithFallback:
                    timeOptionButton.select(segmentTimeOption)
                case .splitTime, .delta, .deltaWithFallback:
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
	
	func options(for column: NSTableColumn) -> NSView {
		if column.identifier == STVColumnID.differenceColumn {
			return differenceOptions()
		}
		return segmentSplitOptions(for: column)
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
	
	func colorStack(title: String, allowsOpacity: Bool = true, runProperty: WritableKeyPath<SplitterRun, NSColor>, defaultColor: NSColor) -> (stack: NSStackView, well: SplitterColorWell) {
		let label = NSTextField(labelWithString: title)
		let well = SplitterColorWell(action: { well in
			self.run[keyPath: runProperty] = well.color
		})
		well.allowsOpacity = allowsOpacity
		well.color = self.run[keyPath: runProperty]
		let resetButton = ComponentOptionsButton(title: "Reset", clickAction: { _ in
			well.color = defaultColor
			well.colorWellAction(well)
		})
		let stack = NSStackView(views: [label, well, resetButton])
		stack.orientation = .horizontal
		NotificationCenter.default.addObserver(forName: .runColorChanged, object: run, queue: nil, using: { notification in
			let run = notification.object as! SplitterRun
			let color = run[keyPath: runProperty]
			well.color = color
		})
		return (stack, well)
	}
	
	var optionsView: NSView! {
		let d = defaultComponentOptions() as! ComponentOptionsVstack
		let showHeaderButton = ComponentOptionsButton(checkboxWithTitle: "Show Header") {_ in
			self.showHeader.toggle()
		}
		showHeaderButton.state = .init(bool: showHeader)
		d.addArrangedSubview(showHeaderButton)
		
		let separatorView = NSView()
		separatorView.wantsLayer = true
		separatorView.layer?.backgroundColor = NSColor.separatorColor.cgColor
		d.addArrangedSubview(separatorView)
		NSLayoutConstraint.activate([
			separatorView.heightAnchor.constraint(equalToConstant: 1)
		])
		
		let tableColor = colorStack(title: "Background Color", runProperty: \.tableColor, defaultColor: .splitterTableViewColor)
		d.addArrangedSubview(tableColor.stack)
		
		let selectedColor = colorStack(title: "Selected Color", runProperty: \.selectedColor, defaultColor: .splitterRowSelected)
		d.addArrangedSubview(selectedColor.stack)
		
		let diffsLabel = NSTextField(labelWithString: "Diffs")
		d.addArrangedSubview(diffsLabel)
		
		
		let longerColor = colorStack(title: "Longer Color", allowsOpacity: false, runProperty: \.longerColor, defaultColor: .defaultLongerColor)
		d.addArrangedSubview(longerColor.stack)
		
		let shorterColor = colorStack(title: "Shorter Color", allowsOpacity: false, runProperty: \.shorterColor, defaultColor: .defaultShorterColor)
		d.addArrangedSubview(shorterColor.stack)
		
		let bestColor = colorStack(title: "Best Color", allowsOpacity: false, runProperty: \.bestColor, defaultColor: .defaultBestColor)
		d.addArrangedSubview(bestColor.stack)

		let co = columnOptionsView
		let superStack = SplitsOptionsView.makeView(tabs: [(d, "Options"), (co, "Columns")])
		NSLayoutConstraint.activate([
			superStack.widthAnchor.constraint(equalTo: d.widthAnchor),
			co.widthAnchor.constraint(equalTo: superStack.widthAnchor),
			tableColor.stack.heightAnchor.constraint(equalToConstant: 30),
			selectedColor.stack.heightAnchor.constraint(equalToConstant: 30),
			selectedColor.well.widthAnchor.constraint(equalTo: tableColor.well.widthAnchor),
			selectedColor.well.leadingAnchor.constraint(equalTo: tableColor.well.leadingAnchor),
			longerColor.stack.heightAnchor.constraint(equalToConstant: 30),
			longerColor.well.widthAnchor.constraint(equalTo: tableColor.well.widthAnchor),
			longerColor.well.leadingAnchor.constraint(equalTo: tableColor.well.leadingAnchor),
			shorterColor.stack.heightAnchor.constraint(equalToConstant: 30),
			shorterColor.well.widthAnchor.constraint(equalTo: tableColor.well.widthAnchor),
			shorterColor.well.leadingAnchor.constraint(equalTo: tableColor.well.leadingAnchor),
			bestColor.stack.heightAnchor.constraint(equalToConstant: 30),
			bestColor.well.widthAnchor.constraint(equalTo: tableColor.well.widthAnchor),
			bestColor.well.leadingAnchor.constraint(equalTo: tableColor.well.leadingAnchor)
		])
		return superStack
	}
}
