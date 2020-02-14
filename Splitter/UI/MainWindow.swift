//
//  MainWindow.swift
//  Splitter
//
//  Created by Michael Berk on 1/13/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

///This class is needed for the Hotkeys to work. I don't remeber why at the moment.
class MainWindow: NSWindow {
	
	override func setTitleWithRepresentedFilename(_ filename: String) {
		super.setTitleWithRepresentedFilename(filename)
		
	}
}


