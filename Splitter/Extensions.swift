//
//  Extensions.swift
//  Splitter
//
//  Created by Michael Berk on 4/28/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

extension NSImage {
	
	static func isDiff(_ lhs: NSImage?, _ rhs: NSImage?) -> Bool {
		if lhs?.tiffRepresentation != rhs?.tiffRepresentation || (lhs != nil && rhs == nil) || (lhs == nil && rhs != nil) {
			return true
		}
		return false
	}
}

extension NSGridView {
//	open override var isFlipped: Bool {
//		return true
//	}
}
extension NSVisualEffectView {
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
extension NSView {
	///Toggles whether the view is hidden`
	func hide() {
		self.isHidden.toggle()
	}
}
extension NSAppearance {
	var isDark: Bool {
		if name.rawValue.contains("Dark") {
			return true
		}
		return false
	}
}
extension NSImage {
	static var gameControllerIcon: NSImage {
		let icon = #imageLiteral(resourceName: "Game Controller")
		icon.isTemplate = true
		return icon
	}
}

extension NSControl.StateValue {
	
	func toBool() -> Bool {
		if self == .on {
			return true
		} else if self == .off {
			return false
		}
		return false
	}
	
	init (bool: Bool) {
		if bool {
			self = .on
		} else {
			self = .off
		}
	}
	
}
