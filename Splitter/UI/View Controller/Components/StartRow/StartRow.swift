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
	
	static func instantiateView(run: SplitterRun, viewController: ViewController) -> StartRow {
		let startRow: StartRow = StartRow.instantiateView()
		startRow.run = run
		startRow.viewController = viewController
		startRow.initialization()
		return startRow
	}
	
	internal override func awakeAfter(using coder: NSCoder) -> Any? {
		return instantiateView() // You need to add this line to load view
	}
	
	internal override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	func initialization() {
		startButton.run = run
		stopButton.run = run
		stopButton.image = nil
		if #available(macOS 11.0, *) {
			stopButton.image = NSImage(systemSymbolName: "stop.circle.fill", accessibilityDescription: nil)
		} else {
			stopButton.image = NSImage(named: "stop")
		}
		
		if startButton.acceptsFirstResponder {
			startButton.window?.makeFirstResponder(startButton)
		}
		NotificationCenter.default.addObserver(forName: .timerStateChanged, object: run.timer, queue: nil, using: { notification in
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
	}
	
	func setVisibleButtons() {
		stopButton.isHidden = shouldStopButtonBeHidden
	}
	
	
	@IBOutlet var startButton: ThemedButton!
	@IBOutlet var stopButton: ThemedButton!
	
	var viewController: ViewController!
	
	
	var isSelected = false {
		didSet {
			self.didSetSelected()
		}
	}
	
	@IBAction func startButtonClick(_ sender: Any) {
		viewController?.toggleTimer()
	}
	@IBAction func stopButtonClick(_ sender: Any) {
		viewController?.cancelRun()
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
