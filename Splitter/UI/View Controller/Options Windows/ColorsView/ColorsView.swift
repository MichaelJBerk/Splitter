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
		if let d = delegate {
			if run.undoManager?.isUndoing ?? false {
				run.undoManager?.disableUndoRegistration()
			}
			d.run.backgroundColor = bgColorWell.color
			d.run.tableColor = tableViewBGColorWell.color
			d.run.textColor = textColorWell.color
			d.selectedColor = selectedColorWell.color
			
			d.run.longerColor = longerDiffColorWell.color
			d.run.shorterColor = shorterDiffColorWell.color
			//TODO: PB Color

//			d.setColorForControls()
			d.updateTextFields()
			d.run.updateLayoutState()
			if run.undoManager?.isUndoing ?? false {
				run.undoManager?.enableUndoRegistration()
			}
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
//		run.undoManager?.beginUndoGrouping()
//		undoManager?.registerUndo(withTarget: self, selector: #selector(settingsSender(_:)), object: sender)
		sendSettings(sender)
//		run.undoManager?.endUndoGrouping()
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
		NotificationCenter.default.addObserver(forName: .runColorChanged, object: nil, queue: nil, using: { _ in
			if self.run.undoManager?.isUndoing ?? false {
				self.loadFromDelegate()
			}
		})
	}
    
}
