//
//  SplitsComponentOptions.swift
//  Splitter
//
//  Created by Michael Berk on 7/5/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa
import LiveSplitKit
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
	
	//MARK: - Main Options View
	var optionsView: NSView! {
		let d = defaultComponentOptions() as! ComponentOptionsVstack
		let showHeaderButton = ComponentOptionsButton(checkboxWithTitle: "Show Header") {_ in
			self.showHeader.toggle()
		}
		showHeaderButton.state = .init(bool: showHeader)
		d.addArrangedSubview(showHeaderButton)
		let hasVScrollButton = ComponentOptionsButton(checkboxWithTitle: "Vertical Scroll Bar", clickAction: { _ in
			self.hasVerticalScroller.toggle()
		})
		hasVScrollButton.state = .init(bool: hasVerticalScroller)
		
		let hasHScrollButton = ComponentOptionsButton(checkboxWithTitle: "Horizontal Scroll Bar", clickAction: { _ in
			self.hasHorizontalScroller.toggle()
		})
		hasHScrollButton.state = .init(bool: hasHorizontalScroller)

		let hideScrollStack = NSStackView()
		hideScrollStack.orientation = .horizontal
		hideScrollStack.addArrangedSubview(hasVScrollButton)
		hideScrollStack.addArrangedSubview(hasHScrollButton)
		d.addArrangedSubview(hideScrollStack)
		
		let separatorView = NSView()
		separatorView.wantsLayer = true
		separatorView.layer?.backgroundColor = NSColor.separatorColor.cgColor
		d.addArrangedSubview(separatorView)
		NSLayoutConstraint.activate([
			separatorView.heightAnchor.constraint(equalToConstant: 1)
		])
		
		colorOptions(stack: d)
		
		let scrollView = NSScrollView(frame: d.frame)
		scrollView.hasVerticalScroller = true
		scrollView.documentView = d
		scrollView.drawsBackground = false
		advancedVC = SplitsComponentAdvancedOptions(splitsComp: self)
		let co = advancedVC.view
		let superStack = SplitsOptionsView.makeView(tabs: [(scrollView, "Options"), (co, "Columns")])
		NSLayoutConstraint.activate([
			d.widthAnchor.constraint(equalTo: scrollView.contentView.widthAnchor),
			superStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
		])
		scrollView.automaticallyAdjustsContentInsets = false
		scrollView.contentInsets.bottom = 20
		return superStack
	}
	
	//MARK: - Color Options
	func colorOptions(stack: ComponentOptionsVstack) {
		
		let tableColor = colorStack(title: "Background Color", runProperty: \.tableColor, defaultColor: .splitterTableViewColor)
		stack.addArrangedSubview(tableColor.stack)
		
		let selectedColor = colorStack(title: "Selected Color", runProperty: \.selectedColor, defaultColor: .splitterRowSelected)
		stack.addArrangedSubview(selectedColor.stack)
		
		let diffsLabel = NSTextField(labelWithString: "Diffs")
		diffsLabel.font = .headingFont
		stack.addArrangedSubview(diffsLabel)
		
		
		let longerColor = colorStack(title: "Longer Color", allowsOpacity: false, runProperty: \.longerColor, defaultColor: .defaultLongerColor)
		stack.addArrangedSubview(longerColor.stack)
		
		let shorterColor = colorStack(title: "Shorter Color", allowsOpacity: false, runProperty: \.shorterColor, defaultColor: .defaultShorterColor)
		stack.addArrangedSubview(shorterColor.stack)
		
		let bestColor = colorStack(title: "Best Color", allowsOpacity: false, runProperty: \.bestColor, defaultColor: .defaultBestColor)
		stack.addArrangedSubview(bestColor.stack)
		
		NSLayoutConstraint.activate([
			tableColor.stack.heightAnchor.constraint(equalToConstant: 30),
			tableColor.stack.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
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
	}
	
	func colorStack(title: String, allowsOpacity: Bool = true, runProperty: WritableKeyPath<SplitterRun, NSColor>, defaultColor: NSColor) -> (stack: NSStackView, well: SplitterColorWell) {
		let label = NSTextField(labelWithString: title)
		let well = SplitterColorWell(action: { well in
			self.run[keyPath: runProperty] = well.color
		})
		well.allowsOpacity = allowsOpacity
		if #available(macOS 13.0, *) {
			well.colorWellStyle = .expanded
		}
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
		//Ensure that the color well grows, but the reset button does not
		stack.distribution = .fill
		well.setContentHuggingPriority(.defaultLow, for: .horizontal)
		resetButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		return (stack, well)
	}
	
	//Generates the constraints for a view on the leading edge of the stack, whether it's a spacer or disclosure button
	func leadingConstraints(view: NSView) {
		NSLayoutConstraint.activate([
			view.widthAnchor.constraint(equalToConstant: 15),
			view.heightAnchor.constraint(equalToConstant: 15)
		])
	}
	
	var spacerView: NSView {
		let spacer = NSView(frame: NSRect(x: 0, y: 0, width: 15, height: 15))
		leadingConstraints(view: spacer)
		return spacer
	}
	
}
