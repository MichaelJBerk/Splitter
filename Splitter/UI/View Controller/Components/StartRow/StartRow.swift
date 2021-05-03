//
//  StartRow.swift
//  Splitter
//
//  Created by Michael Berk on 3/22/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa
@IBDesignable
class StartRow: NSStackView, NibLoadable, SplitterComponent {
	var run: SplitterRun!
	var state: SplitterComponentState!
	
	
	var customSpacing: CGFloat? = nil
	
	internal override func awakeAfter(using coder: NSCoder) -> Any? {
		return instantiateView() // You need to add this line to load view
	}
	
	internal override func awakeFromNib() {
		super.awakeFromNib()
		initialization()
	}
	func initialization() {
		stopButton.image = nil
		let tsItem = trashCanPopupButton.menu?.items[0]
		tsItem?.image = nil
		if #available(macOS 11.0, *) {
			stopButton.image = NSImage(systemSymbolName: "stop.circle.fill", accessibilityDescription: nil)
			tsItem?.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
		} else {
			stopButton.image = NSImage(named: "stop")
			tsItem?.image = NSImage(named: "trash")
		}
		
		if startButton.acceptsFirstResponder {
			startButton.window?.makeFirstResponder(startButton)
		}
		NotificationCenter.default.addObserver(forName: .timerStateChanged, object: nil, queue: nil, using: { notification in
			guard let timerState = notification.userInfo?["timerState"] as? TimerState else {return}
			switch timerState {
			case .paused:
				self.startButton.baseTitle = "Resume"
			case .running:
				self.startButton.baseTitle = "Pause"
			case .stopped:
				self.startButton.baseTitle = "Start"
			}
			self.setVisibleButtons()
		})
//		setVisibleButtons()
	}
	
	func setVisibleButtons() {
		trashCanPopupButton.isHidden = shouldTrashCanBeHidden
		stopButton.isHidden = shouldStopButtonBeHidden
	}
	
	var displayTitle: String = "Start Row"
	var displayDescription: String = ""
	
	
	@IBOutlet var trashCanPopupButton: ThemedPopUpButton!
	@IBOutlet var startButton: ThemedButton!
	@IBOutlet var stopButton: ThemedButton!
	
	var viewController: ViewController!
	
	
	var isSelected = false {
		didSet {
			self.didSetSelected()
		}
	}
	
	@IBAction func trashCanPopupClick(_ sender: Any) {
		viewController?.trashCanPopupClick(sender)
	}
	@IBAction func startButtonClick(_ sender: Any) {
		viewController?.timerButtonClick(sender)
	}
	@IBAction func stopButtonClick(_ sender: Any) {
		viewController?.stopButtonClick(sender)
	}
	
	var shouldTrashCanBeHidden: Bool {
		switch run.timer.timerState {
			case .stopped:
				return false
			default:
				return true
		}
	}
	
	var shouldStopButtonBeHidden: Bool {
		stopButton.isEnabled = true
		switch run.timer.timerState {
			case .stopped:
				return true
			default:
				return false
		}
	}
	
	
}
