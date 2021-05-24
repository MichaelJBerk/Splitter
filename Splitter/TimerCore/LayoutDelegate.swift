//
//  LayoutDelegate.swift
//  Splitter
//
//  Created by Michael Berk on 5/24/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation

protocol LayoutDelegate {
	
	func runBackgroundColorWasUpdated()
	func runTableColorWasUpdated()
}

extension ViewController: LayoutDelegate {
	func runBackgroundColorWasUpdated() {
		self.setColorForControls()
	}
	func runTableColorWasUpdated() {
		self.setColorForControls()
	}
}
