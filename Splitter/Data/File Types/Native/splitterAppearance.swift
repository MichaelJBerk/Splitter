//
//  splitterAppearance.swift
//  Splitter
//
//  Created by Michael Berk on 2/12/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

struct splitterAppearance: Codable {
	var hideTitlebar: Bool?
	var hideButtons: Bool?
	var keepOnTop: Bool?
	var showBestSplits: Bool?
	
	
	init(viewController: ViewController) {
		self.hideTitlebar = viewController.titleBarHidden
		self.hideButtons = viewController.UIHidden
		self.keepOnTop = viewController.windowFloat
		self.showBestSplits = viewController.showBestSplits
	}
	
	func decodeSplitterAppearance(viewController: ViewController) {
		viewController.titleBarHidden = self.hideTitlebar ?? Settings.hideTitleBar
		viewController.UIHidden = self.hideButtons ?? Settings.hideUIButtons
		viewController.windowFloat = self.keepOnTop ?? Settings.floatWindow
		viewController.showBestSplits = self.showBestSplits ?? Settings.showBestSplits
	}
}

enum SplitterAppearanceError: Error {
	case encodeError
}

extension ViewController {
	///Sets the appearance of the VC to the contents of a SplitterAppearance object
	func setSplitterAppearance(appearance: splitterAppearance) {
		titleBarHidden = appearance.hideTitlebar ?? Settings.hideTitleBar
		UIHidden = appearance.hideButtons ?? Settings.hideUIButtons
		windowFloat = appearance.keepOnTop ?? Settings.floatWindow
		showBestSplits = appearance.showBestSplits ?? Settings.showBestSplits
		
		showHideTitleBar()
		showHideUI()
		setFloatingWindow()
		showHideBestSplits()
	}
}
