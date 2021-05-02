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
