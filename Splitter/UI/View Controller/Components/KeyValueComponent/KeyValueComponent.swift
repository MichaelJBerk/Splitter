//
//  SumOfBestComponent.swift
//  Splitter
//
//  Created by Michael Berk on 4/20/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class KeyValueComponent: NSStackView, SplitterComponent, NibLoadable {
	var run: SplitterRun!
	var customSpacing: CGFloat? = nil
	var key: KeyValueComponentType!
	private var componentIndex: Int!
	private var refreshUITimer = Timer()
	internal override func awakeAfter(using coder: NSCoder) -> Any? {
		return instantiateView() // You need to add this line to load view
	}
	var component: CKeyValueComponent {
		run.codableLayout.components[componentIndex] as! CKeyValueComponent
	}
	
	static func instantiateView(with run: SplitterRun, _ viewController: ViewController, type: KeyValueComponentType, layoutIndex: Int) -> KeyValueComponent {
		let row: KeyValueComponent = KeyValueComponent.instantiateView()
		row.viewController = viewController
		row.run = run
		row.key = type
		row.componentIndex = layoutIndex
		row.initialization()
		return row
	}
	
	private func initialization() {
		NotificationCenter.default.addObserver(forName: .startTimer, object: nil, queue: nil, using: { _ in
			self.refreshUITimer = Cocoa.Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { timer in
				self.updateFields()
			})
		})
		NotificationCenter.default.addObserver(forName: .stopTimer, object: nil, queue: nil, using: { _ in
			self.refreshUITimer.invalidate()
		})
		self.updateFields()
	}
	
	func updateFields() {
		self.run.updateLayoutState()
		keyField.stringValue = component.key
		textField.stringValue = component.value
	}
	
	var viewController: ViewController!
	
	var displayDescription: String = ""
	
	var isSelected: Bool = false {
		didSet {
			didSetSelected()
		}
	}

	@IBOutlet var textField: ThemedTextField!
	@IBOutlet var keyField: ThemedTextField!
	
    
}
