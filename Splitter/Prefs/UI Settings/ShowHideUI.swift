//
//  ShowHideUI.swift
//  Splitter
//
//  Created by Michael Berk on 1/26/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController {
	func showHideUI() {
			if UIHidden {
				StartButton.isHidden = true
				trashCanPopupButton.isHidden = true
				stopButton.isHidden = true
				
				plusButton.isHidden = true
				minusButton.isHidden = true
				nextButton.isHidden = true
				prevButton.isHidden = true
				
	//			UIHidden = true
			} else {
				StartButton.isHidden = false
				if shouldStopButtonBeHidden == true {
					stopButton.isHidden = true
				} else {
					stopButton.isHidden = false
				}
				if shouldTrashCanBeHidden == true {
					trashCanPopupButton.isHidden = true
				} else {
					trashCanPopupButton.isHidden = false
				}
				
				
				plusButton.isHidden = false
				minusButton.isHidden = false
				nextButton.isHidden = false
				prevButton.isHidden = false
				
	//			UIHidden = false
			}
		let mi = NSApp.mainMenu?.item(withIdentifier: menuIdentifiers.appearanceMenu.hideButtons)
		mi?.title = showHideButtonsText
		}
	
	var showHideButtonsText: String {
		get {
			if UIHidden {
				return "Show Timer/Splits Buttons"
			} else {
				return "Hide Timer/Splits Buttons"
			}
		}
	}
}
