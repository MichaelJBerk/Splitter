//
//  SumOfBestComponent.swift
//  Splitter
//
//  Created by Michael Berk on 4/20/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class SumOfBestComponent: NSStackView, SplitterComponent, NibLoadable {
	var run: SplitterRun!
	var customSpacing: CGFloat? = nil
	internal override func awakeAfter(using coder: NSCoder) -> Any? {
		return instantiateView() // You need to add this line to load view
	}
	
	internal override func awakeFromNib() {
		super.awakeFromNib()
		initialization()
	}
	private func initialization() {
		
	}
	
	var viewController: ViewController!
	
	var displayTitle: String = "Sum Of Best"
	
	var displayDescription: String = ""
	
	var isSelected: Bool = false {
		didSet {
			didSetSelected()
		}
	}
	
	var sumOfBestText: String = "" {
		didSet {
			textField.stringValue = sumOfBestText
		}
	}
	
	@IBOutlet var textField: ThemedTextField!
	
    
}
