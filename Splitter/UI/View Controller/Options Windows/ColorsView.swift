//
//  ColorsView.swift
//  Splitter
//
//  Created by Michael Berk on 5/28/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

protocol LoadableNib {
    var contentView: NSView! { get }
}

extension LoadableNib where Self: NSView {
	func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = NSNib(nibNamed: .init(String(describing: type(of: self))), bundle: bundle)!
        _ = nib.instantiate(withOwner: self, topLevelObjects: nil)

        let contentConstraints = contentView.constraints
        contentView.subviews.forEach({ addSubview($0) })

        for constraint in contentConstraints {
            let firstItem = (constraint.firstItem as? NSView == contentView) ? self : constraint.firstItem
            let secondItem = (constraint.secondItem as? NSView == contentView) ? self : constraint.secondItem
            addConstraint(NSLayoutConstraint(item: firstItem as Any, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
        }
    }
}

class ColorsView: NSView, LoadableNib, advancedTabDelegate {
	var delegate: ViewController?
	
	@IBOutlet weak var bgColorWell: NSColorWell!
	@IBOutlet weak var tableViewBGColorWell: NSColorWell!
	@IBOutlet weak var textColorWell: NSColorWell!
	@IBOutlet weak var selectedColorWell: NSColorWell!
	@IBOutlet weak var longerDiffColorWell: NSColorWell!
	@IBOutlet weak var shorterDiffColorWell: NSColorWell!
	
	var height: CGFloat = 325
	
	func setupDelegate() {
	}
	
	@objc func sendSettings( _ sender: Any) {
		if let d = delegate {
			d.bgColor = bgColorWell.color
			d.tableBGColor = tableViewBGColorWell.color
			d.textColor = textColorWell.color
			d.selectedColor = selectedColorWell.color
			d.diffsLongerColor = longerDiffColorWell.color
			d.diffsShorterColor = shorterDiffColorWell.color
			d.setColorForControls()
		}
	}
	
	@IBAction func resetBGColorButton(_ sender: Any) {
		bgColorWell.color = .splitterDefaultColor
		sendSettings(sender)
	}
	@IBAction func resetTableViewBGColorButton(_ sender: Any) {
		tableViewBGColorWell.color = .splitterTableViewColor
		sendSettings(sender)
	}
	
	@IBAction func resetLongerDiffColorButton(_ sender: Any) {
		longerDiffColorWell.color = .red
		sendSettings(sender)
	}
	@IBAction func resetShorterDiffColorButton(_ sender: Any) {
		shorterDiffColorWell.color = .green
		sendSettings(sender)
	}
	
	
	@IBAction func resetTextColorButton(_ sender: Any) {
		textColorWell.color = .textColor
		sendSettings(sender)
	}
	
	@IBAction func resetSelectedColorButton(_ sender: Any) {
		selectedColorWell.color = .splitterRowSelected
		sendSettings(sender)
	}
	@IBAction func settingsSender(_ sender: Any) {
		sendSettings(sender)
	}
	
	override func viewDidMoveToSuperview() {
		loadFromDelegate()
	}
	
	func loadFromDelegate() {
		if let d = delegate {
			bgColorWell.color = d.view.window!.backgroundColor
			tableViewBGColorWell.color = d.splitsTableView.backgroundColor
			textColorWell.color = d.textColor
			selectedColorWell.color = d.selectedColor
			longerDiffColorWell.color = d.diffsLongerColor
			shorterDiffColorWell.color = d.diffsShorterColor
			
			
		}
	}
	
	
	let nibName = "ColorsView"
	
	@IBOutlet var contentView: NSView!
	
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		loadViewFromNib()
		loadFromDelegate()
	}
    
}
