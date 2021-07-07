//
//  TextFields.swift
//  Splitter
//
//  Created by Michael Berk on 3/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

extension InfoOptionsViewController {
	
	///Loads the popover with data from the main window
	func getDataFromMain() {
		//If the user types a title on the view controller, then shows the info panel (without pressing enter on the TF first), delegate is nil
		if let delegate = self.delegate {
			iconWell.run = delegate.run
			runTitleField.stringValue = run.title
			categoryField.stringValue = run.subtitle
			attemptField.stringValue = "\(delegate.run.attempts)"
			platformField.stringValue = run.platform
			versionField.stringValue = run.gameVersion
			regionField.stringValue = run.region
			
			if let st = delegate.startTime {
	//			let sDate = dateToRFC339String(date: st)
				let sDate = startEndDateFormatter.string(from: st)
				
				startTimeLabel.stringValue = sDate
			}
			if let et = delegate.endTime {
				let eDate = startEndDateFormatter.string(from: et)
				endTimeLabel.stringValue = eDate
			}
		}
	}
	
	///Sends data from the popover to the main window
	func sendDataToMain() {
		run.title = runTitleField.stringValue
		run.subtitle = categoryField.stringValue
		run.attempts = Int(attemptField.stringValue) ?? 0
		run.platform = platformField.stringValue
		run.gameVersion = versionField.stringValue
		run.region = regionField.stringValue
	}
	func sendImageToMain() {
		delegate?.gameIconButton.image = iconWell.image
	}
	func getImageFromMain() {
		iconWell.allowsUpdate = false
		iconWell.image = delegate?.gameIconButton.image
		iconWell.allowsUpdate = true
	}
}
