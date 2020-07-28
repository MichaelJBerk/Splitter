//
//  NSViewExtensions.swift
//  Splitter
//
//  Created by Michael Berk on 7/28/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

extension NSView {
    /// Returns the first constraint with the given identifier, if available.
    ///
    /// - Parameter identifier: The constraint identifier.
    func constraintWithIdentifier(_ identifier: String) -> NSLayoutConstraint? {
		
        return self.constraints.first { $0.identifier == identifier }
    }
}
