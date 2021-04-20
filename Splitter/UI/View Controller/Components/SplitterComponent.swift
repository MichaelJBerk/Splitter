//
//  SplitterComponent.swift
//  Splitter
//
//  Created by Michael Berk on 3/22/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation

protocol SplitterComponent: NSView {
	var viewController: ViewController? {get set}
	var displayTitle: String { get }
	var displayDescription: String { get }
	var optionsView: NSView! { get }
	var isSelected: Bool {get set}
}

extension SplitterComponent {
	
	
	func didSetSelected() {
		
		
		if isSelected {
			self.wantsLayer = true
			self.layer?.borderWidth = 2
			self.layer?.borderColor = NSColor.selectedControlColor.cgColor
			self.layer?.cornerRadius = 10
		} else {
			self.wantsLayer = false
			self.layer?.borderWidth = 0
		}
	}
	func defaultComponentOptions() -> [[NSView]] {
		let visibleCheck = NSButton(checkboxWithTitle: "Hidden", target: self, action: #selector(hide(_:)))
		visibleCheck.state = .init(bool: isHidden)
		return [[visibleCheck]]
	}
	
	
}
private extension NSView {
	@objc func hide(_ sender: Any?) {
		self.isHidden.toggle()
	}
}
