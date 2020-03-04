//
//  SplitTableViewColumnIdentifiers.swift
//  Splitter
//
//  Created by Michael Berk on 1/26/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

public enum STVColumnID {
	static let imageColumn = NSUserInterfaceItemIdentifier("ImageColumn")
	static let splitTitleColumn = NSUserInterfaceItemIdentifier("SplitTitle")
	static let differenceColumn = NSUserInterfaceItemIdentifier("Difference")
	static let currentSplitColumn = NSUserInterfaceItemIdentifier("CurrentSplit")
	static let bestSplitColumn = NSUserInterfaceItemIdentifier("B")
	static let previousSplitColumn = NSUserInterfaceItemIdentifier("PreviousSplit")
}

public var colIds: [String: NSUserInterfaceItemIdentifier] = [
	"Icon": STVColumnID.imageColumn,
	"Title": STVColumnID.splitTitleColumn,
	"Difference": STVColumnID.differenceColumn,
	"Current Split": STVColumnID.currentSplitColumn,
	"Personal Best": STVColumnID.bestSplitColumn,
	"Previous Split": STVColumnID.previousSplitColumn
]
