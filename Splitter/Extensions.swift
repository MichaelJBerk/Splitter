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
	open override var isFlipped: Bool {
		return true
	}
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
