//
//  TouchBarDelegate.swift
//  Splitter
//
//  Created by Michael Berk on 8/26/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation

///Touch bar delegate for the
class RunTouchBarDelegate: NSObject, NSTouchBarDelegate {
	
	init(splitFunc: @escaping () -> (), pauseFunc: @escaping () -> (),
		 prevFunc: @escaping () -> (), stopFunc: @escaping () -> (),
		 sourceVC: ViewController) {
		self.splitFunc = splitFunc
		self.sourceVC = sourceVC
		self.pauseFunc = pauseFunc
		self.prevFunc = prevFunc
		self.stopFunc = stopFunc
		super.init()
		
		self.startSplitButton = TBButton(title: startSplitTitle, image: NSImage(named: NSImage.touchBarPlayTemplateName)!, target: self, action: #selector(startSplitButtonTapped))
		self.startSplitButton.imageScaling = .scaleProportionallyDown
		NSLayoutConstraint(item: startSplitButton!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 175).isActive = true
		startSplitButton.bezelColor = sourceVC.selectedColor
		
		self.pauseButton =  TBButton(title: "", image: NSImage(named: NSImage.touchBarPauseTemplateName)!, target: self, action: #selector(pauseButtonTapped))
		self.prevButton = TBButton(title: "", image: NSImage(named: NSImage.touchBarSkipBackTemplateName)!, target: self, action: #selector(prevButtonTapped))
		self.stopButton = TBButton(title: "", image: NSImage(named: NSImage.touchBarRecordStopTemplateName)!, target: self, action: #selector(stopButtonTapped))
	}
	var sourceVC: ViewController
	var startSplitTitle = "Start" {
		didSet {
			startSplitButton.title = startSplitTitle
		}
	}
	
	var timerState: ViewController.TimerState {
		get {
			return sourceVC.timerState
		}
	}
	
	///Method that starts/splits the run
	var splitFunc: ()-> ()
	var pauseFunc: () -> ()
	var prevFunc: () -> ()
	var stopFunc: () -> ()
	
	///Label displaying the current time for the Touch Bar
	var totalTimeLabel: NSTextField {
		return sourceVC.touchBarTotalTimeLabel
	}
	
	func enableDisableButtons() {
		switch timerState {
		case .stopped:
			startSplitButton.isEnabled = true
			pauseButton.isEnabled = false
			startSplitTitle = "Start"
			startSplitButton.image = NSImage(named: NSImage.touchBarPlayTemplateName)
			pauseButton.image = NSImage(named: NSImage.touchBarPauseTemplateName)
		case .running:
			startSplitButton.isEnabled = true
			pauseButton.isEnabled = true
			pauseButton.image = NSImage(named: NSImage.touchBarPauseTemplateName)
			if sourceVC.run.currentSplit == sourceVC.run.segmentCount - 1 {
				startSplitButton.image = #imageLiteral(resourceName: "flag")
			} else {
				startSplitButton.image = NSImage(named: NSImage.touchBarSkipAheadTemplateName)
			}
		case .paused:
			startSplitButton.isEnabled = false
			pauseButton.isEnabled = true
			pauseButton.image = NSImage(named: NSImage.touchBarPlayTemplateName)
			
		}
		stopButton.isEnabled = !(timerState == .stopped)
		prevButton.isEnabled = (timerState == .running &&  (sourceVC.run.currentSplit ?? 0) > 0)
	}
	
	var pauseButton: TBButton!
	var startSplitButton: TBButton!
	var prevButton: TBButton!
	var stopButton: TBButton!
	
	@objc func startSplitButtonTapped() {
		splitFunc()
	}
	@objc func pauseButtonTapped() {
		pauseFunc()
	}
	@objc func prevButtonTapped() {
		prevFunc()
	}
	@objc func stopButtonTapped() {
		stopFunc()
	}
	
	func makeTBStartSplitItem() -> NSTouchBarItem {
		let item = NSCustomTouchBarItem(identifier: .startSplitButton)
		item.view = startSplitButton
		item.customizationLabel = "Start/Split Button"
		return item
	}
	func makeTBCurrentTimeItem() -> NSTouchBarItem {
		let item = NSCustomTouchBarItem(identifier: .currentTimeLabel)
		item.view = totalTimeLabel
		item.customizationLabel = "Current Time"
		return item
	}
	func makeTBPauseItem() -> NSTouchBarItem {
		let item = NSCustomTouchBarItem(identifier: .pauseButton)
		pauseButton.isEnabled = !(sourceVC.timerState == .stopped)
		item.view = pauseButton
		item.customizationLabel = "Pause/Resume Run"
		return item
	}
	func makePrevItem() -> NSTouchBarItem {
		let item = NSCustomTouchBarItem(identifier: .prevButton)
		prevButton.isEnabled = (sourceVC.timerState == .running)
		item.view = prevButton
		item.customizationLabel = "Previous Split"
		return item
	}
	func makeStopItem() -> NSTouchBarItem {
		let item = NSCustomTouchBarItem(identifier: .stopButton)
		stopButton.isEnabled = !(sourceVC.timerState == .stopped)
		item.view = stopButton
		item.customizationLabel = "Stop Run"
		return item
	}
	@objc func pauseButtonAction (_ sender: Any?) {
		pauseFunc()
	}
	
	
	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		var item: NSTouchBarItem?
		switch identifier {
		case .startSplitButton:
			item = makeTBStartSplitItem()
		case .currentTimeLabel:
			item = makeTBCurrentTimeItem()
		case .pauseButton:
			item = makeTBPauseItem()
		case .prevButton:
			item = makePrevItem()
		case .stopButton:
			item = makeStopItem()
		default:
			if !touchBar.customizationAllowedItemIdentifiers.contains(identifier) {
				item = nil
			} else {
				let n = NSTouchBarItem(identifier: identifier)
				if n.view == nil {
					item = NSTouchBarItem(identifier: .fixedSpaceSmall)
				} else {
					item = n
				}
			}
		}
		enableDisableButtons()
		return item
	}
	
}

extension NSTouchBarItem.Identifier {
	static let startSplitButton = NSTouchBarItem.Identifier("startSplitButton")
	static let currentTimeLabel = NSTouchBarItem.Identifier("currentTimeLabel")
	static let pauseButton = NSTouchBarItem.Identifier("pauseButton")
	static let prevButton = NSTouchBarItem.Identifier("prevButton")
	static let stopButton = NSTouchBarItem.Identifier("stopButton")
}

extension NSTouchBar.CustomizationIdentifier {
	static let runTouchBar = "com.mibe.splitter.touchbar"
}

class TBButton: NSButton {
}

extension ViewController {
	//MARK: - Touch Bar
	override func makeTouchBar() -> NSTouchBar? {
		let touchBar = NSTouchBar()
		touchBar.delegate = touchBarDelegate
		touchBar.customizationIdentifier = .runTouchBar
		let items: [NSTouchBarItem.Identifier] =  [.prevButton, .startSplitButton, .pauseButton, .stopButton, .flexibleSpace, .currentTimeLabel]
		touchBar.defaultItemIdentifiers = items
		touchBar.customizationAllowedItemIdentifiers = items //+ [.fixedSpaceLarge, .fixedSpaceSmall]
		let i = touchBar.itemIdentifiers
		print(i)
		return touchBar
	}
	
	@IBAction func editTB(_ sender: Any?) {
		NSApp.toggleTouchBarCustomizationPalette(sender)
	}
}
