//
//  Button Actions.swift
//  Splitter
//
//  Created by Michael Berk on 2/4/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController {
	//MARK: - Button Actions
	
	@IBAction func timerButtonClick(_ sender: Any?) {
		toggleTimer()
	}
	
	@IBAction func stopButtonClick(_ sender: Any) {
		cancelRun()
	}
	//TODO: See if name should be changed
	@IBAction func trashStCanClick(_ sender: Any) {
		askToClearTimer()
	}
	@IBAction func trashCanPopupClick(_ sender: Any) {
		if let popup = sender as? NSPopUpButton {
			if let id = popup.selectedItem?.identifier {
				if id == buttonIdentifiers.TrashCanClearAllSplits {
					askToClearTimer()
				} else if id == buttonIdentifiers.TrashCanClearCurrentTime {
					//TODO: Something...
				}
			}
		}
	}
	
	
	@IBAction func pauseButtonPressed(_ sender: Any) {
		pauseResumeTimer()
	}
}
