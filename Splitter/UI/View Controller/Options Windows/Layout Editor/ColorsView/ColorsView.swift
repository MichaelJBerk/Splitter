//
//  ColorsView.swift
//  Splitter
//
//  Created by Michael Berk on 5/28/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

var splitNoteText = "Note: These settings will be saved to this file, and will take effect whenever the file is opened. "
var notSplitNoteText = "Note: These settings will not be saved to this file unless it is saved in the .split format"

class ColorsView: NSView, LoadableNib {
	var delegate: ViewController?
	var run: SplitterRun!
	
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
		if run.undoManager?.isUndoing ?? false {
			run.undoManager?.disableUndoRegistration()
		}
		run.backgroundColor = bgColorWell.color
		run.tableColor = tableViewBGColorWell.color
		run.textColor = textColorWell.color
		run.selectedColor = selectedColorWell.color
		
		run.longerColor = longerDiffColorWell.color
		run.shorterColor = shorterDiffColorWell.color
		if let d = delegate {
			d.updateTextFields()
			d.run.updateLayoutState()
		}
		if run.undoManager?.isUndoing ?? false {
			run.undoManager?.enableUndoRegistration()
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
		bgColorWell.color = run.backgroundColor
		tableViewBGColorWell.color = run.tableColor
		textColorWell.color = run.textColor
		selectedColorWell.color = run.selectedColor
		longerDiffColorWell.color = run.longerColor
		shorterDiffColorWell.color = run.shorterColor
		if let doc = delegate?.view.window?.windowController?.document as? NSDocument {
			if doc.fileType != "Split File" {
				noteLabel.stringValue = notSplitNoteText
			} else {
				noteLabel.stringValue = splitNoteText
			}
		}
		NSColorPanel.shared.showsToolbarButton = true
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
		NotificationCenter.default.addObserver(forName: .runColorChanged, object: run, queue: nil, using: { _ in
			if self.run.undoManager?.isUndoing ?? false || self.undoManager?.isRedoing ?? false {
				self.loadFromDelegate()
			}
		})
	}
    
}
