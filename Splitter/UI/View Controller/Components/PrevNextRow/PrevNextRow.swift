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
	
	var displayTitle: String = "Previous/Next Buttons"
	var displayDescription: String = ""
	
	internal override func awakeAfter(using coder: NSCoder) -> Any? {
		return instantiateView() // You need to add this line to load view
	}
	
	internal override func awakeFromNib() {
		super.awakeFromNib()
		initialization()
	}
	private func initialization() {
		NotificationCenter.default.addObserver(forName: .timerStateChanged, object: nil, queue: nil, using: { notification in
			guard let timerState = notification.object as? TimerState else {return}
			var buttonsEnabled = false
			if timerState == .running {
				buttonsEnabled = true
			}
			self.prevButton.isEnabled = buttonsEnabled
			self.nextButton.isEnabled = buttonsEnabled
			self.nextButton.title = self.run.nextButtonTitle
		})
		NotificationCenter.default.addObserver(forName: .splitChanged, object: nil, queue: nil, using: { notification in
			self.nextButton.title = self.run.nextButtonTitle
		})
	}
	
	

	@IBOutlet var prevButton: ThemedButton!
	@IBOutlet var nextButton: ThemedButton!
	
	var viewController: ViewController!
	
	@IBAction func prevButtonClick(_ sender: NSButton?) {
		viewController?.goToPrevSplit()
	}
	@IBAction func nextButtonClick(_ sender: NSButton?) {
		viewController?.goToNextSplit()
	}
	var isSelected = false {
		didSet {
			self.didSetSelected()
		}
	}
	
	
}
