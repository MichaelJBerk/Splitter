//
//  commonPaths.swift
//  Splitter
//
//  Created by Michael Berk on 2/12/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

enum commonPaths {
	static let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("/Splitter")
	static let keybinds = appSupport.appendingPathComponent("/splitter.splitkeys")
}

