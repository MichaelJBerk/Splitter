//
//  ColorsView.swift
//  Splitter
//
//  Created by Michael Berk on 5/28/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

class ColorsView: NSView, LoadableNib, advancedTabDelegate {
	var delegate: ViewController?
	
	@IBOutlet weak var bgColorWell: NSColorWell!
	@IBOutlet weak var tableViewBGColorWell: NSColorWell!
	@IBOutlet weak var textColorWell: NSColorWell!
	@IBOutlet weak var selectedColorWell: NSColorWell!
	@IBOutlet weak var longerDiffColorWell: NSColorWell!
	@IBOutlet weak var shorterDiffColorWell: NSColorWell!
	@IBOutlet weak var noteLabel: NSTextField!
	
	var height: CGFloat = 370
	
	func setupDelegate() {
	}
	
	@objc func sendSettings( _ sender: Any) {
		if let d = delegate {
			d.run.backgroundColor = bgColorWell.color
			d.run.tableColor = tableViewBGColorWell.color
			d.run.textColor = textColorWell.color
			d.selectedColor = selectedColorWell.color
			
			d.run.longerColor = longerDiffColorWell.color
			d.run.shorterColor = shorterDiffColorWell.color
			//TODO: PB Color

			d.setColorForControls()
			d.updateTextFields()
			d.run.updateLayoutState()
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
		textColorWell.color = .white
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
			bgColorWell.color = d.run.backgroundColor//d.view.window!.backgroundColor
			tableViewBGColorWell.color = d.run.tableColor
			textColorWell.color = d.run.textColor
			selectedColorWell.color = d.selectedColor
			longerDiffColorWell.color = d.run.longerColor
			shorterDiffColorWell.color = d.run.shorterColor
			
			if let doc = delegate?.view.window?.windowController?.document as? NSDocument {
				if doc.fileType != "Split File" {
					noteLabel.stringValue = notSplitNoteText
				} else {
					noteLabel.stringValue = splitNoteText
				}
			}
			
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
