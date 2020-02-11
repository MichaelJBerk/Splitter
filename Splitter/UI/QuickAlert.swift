//
//  QuickAlert.swift
//  Splitter
//
//  Created by Michael Berk on 1/31/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

class QuickAlert {
	
	
	
	init(message: String, image: NSImage?) {
		let alert = NSAlert()
		alert.messageText = message
		if let img = image {
			alert.icon = img
		}
		alert.alertStyle = .informational
		alert.addButton(withTitle: "OK")
		alert.runModal()
	}
}
