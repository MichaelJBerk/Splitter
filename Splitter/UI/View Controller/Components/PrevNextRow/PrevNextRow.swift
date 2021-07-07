//
//  PrevNextRow.swift
//  Splitter
//
//  Created by Michael Berk on 2/10/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

@IBDesignable
class PrevNextRow: NSStackView, NibLoadable, SplitterComponent {
	var run: SplitterRun!
	var state: SplitterComponentState!
	
	var customSpacing: CGFloat? = nil
	
	static func instantiateView(run: SplitterRun, viewController: ViewController) -> PrevNextRow {
		let row: PrevNextRow = PrevNextRow.instantiateView()
		row.run = run
		row.viewController = viewController
		row.initialization()
		return row
	}
	
	internal override func awakeAfter(using coder: NSCoder) -> Any? {
		return instantiateView() // You need to add this line to load view
	}
	
	internal override func awakeFromNib() {
		super.awakeFromNib()
	}
	private func initialization() {
		self.prevButton.run = self.run
		self.nextButton.run = self.run
		NotificationCenter.default.addObserver(forName: .timerStateChanged, object: run.timer, queue: nil, using: { notification in
			guard let timerState = notification.userInfo?["timerState"] as? TimerState else {return}
			var buttonsEnabled = false
			if timerState == .running {
				buttonsEnabled = true
			}
			self.prevButton.isEnabled = buttonsEnabled
			self.nextButton.isEnabled = buttonsEnabled
			self.nextButton.baseTitle = self.run.nextButtonTitle
		})
		NotificationCenter.default.addObserver(forName: .splitChanged, object: run.timer, queue: nil, using: { notification in
			self.nextButton.baseTitle = self.run.nextButtonTitle
		})
	}
	
	

	@IBOutlet var prevButton: ThemedButton!
	@IBOutlet var nextButton: ThemedButton!
	
	var viewController: ViewController!
	
	@IBAction func prevButtonClick(_ sender: NSButton?) {
		run.timer.previousSplit()
	}
	@IBAction func nextButtonClick(_ sender: NSButton?) {
		run.timer.splitOrStart()
	}
	var isSelected = false {
		didSet {
			self.didSetSelected()
		}
	}
	
	
}
