//
//  SplitterTableView.swift
//  Splitter
//
//  Created by Michael Berk on 4/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

class SplitterScroller: NSScroller {
	
	var bgColor: NSColor?
	
	override func drawKnobSlot(in slotRect: NSRect, highlight flag: Bool) {
		
	}
}

class SplitterScrollView: NSScrollView {

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

        if hasVerticalScroller && hasHorizontalScroller {
            guard verticalScroller != nil && horizontalScroller != nil else { return }

            let vFrame = verticalScroller!.frame
            let hFrame = horizontalScroller!.frame
            let square = NSRect(origin: CGPoint(x: hFrame.maxX, y: vFrame.maxY), size: CGSize(width: vFrame.width, height: hFrame.height))

            let path = NSBezierPath(rect: square)
			let fillColor = NSApplication.appDelegate.headColor
            fillColor.set()
            path.fill()
        }
    }
}

class SplitterTableView: NSTableView {
	var parentViewController: ViewController!
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
	
	
	/// Sets the background color for the view under the scroll bar
	/// - Parameter cornerColor: Background color for the view under the scroll bar
	func setCornerColor(cornerColor: NSColor) {
		let vSize = self.headerView!.frame.size.height
		let hSize = self.enclosingScrollView!.verticalScroller!.frame.size.height
		let cRect = NSRect(x: 0, y: 0, width: hSize, height: vSize)
		
		let cornerV = NSView(frame: cRect)
		cornerV.wantsLayer = true
		cornerV.layer?.backgroundColor = cornerColor.cgColor
		
		enclosingScrollView?.verticalScroller?.wantsLayer = true
		enclosingScrollView?.verticalScroller?.layer?.isOpaque = true
		enclosingScrollView?.horizontalScroller?.wantsLayer = true
		enclosingScrollView?.horizontalScroller?.layer?.isOpaque = true
		
		
		enclosingScrollView?.verticalScroller?.layer?.backgroundColor = cornerColor.cgColor
		enclosingScrollView?.horizontalScroller?.layer?.backgroundColor = cornerColor.cgColor
		
		self.cornerView = cornerV
		
		
	}
	
	/// Sets the background color of the table header to the specified color
	///
	/// In addition to setting the backrgound and text for the header, it also makes the header opaque.
	/// - Parameters:
	///   - textColor: Color for the header's text
	///   - bgColor: Background color for the header
	func setHeaderColor(textColor: NSColor, bgColor: NSColor) {
//		let appDel = NSApp.delegate as! AppDelegate
//		appDel.headColor = bgColor
		for c in self.tableColumns {
			if !c.isHidden {
//				print(c.title)
				let headerStr = c.headerCell.stringValue
				let head = SplitterTableHeaderCell(color: parentViewController.tableBGColor, textCell: headerStr)
//				head.parentTableView = self
				
				head.drawsBackground = true
				head.textColor = textColor
				head.headColor = parentViewController.tableBGColor//.copy() as! NSColor
				head.backgroundColor = parentViewController.tableBGColor
				head.attributedStringValue = NSAttributedString(string: headerStr, attributes: [.foregroundColor: textColor])
				head.isBordered = true
				c.headerCell = head
			}
		}
	}
    
	//Overriding keyDown so that typing a letter for a hotkey doesn't select that segment
	override func keyDown(with event: NSEvent) {
		superview?.keyDown(with: event)
	}
	
	
}

class SplitterTableHeader : NSTableHeaderView
{
    required init?(coder: NSCoder)
    {

        super.init(coder: coder)
		self.wantsLayer = true
				

		
    }
//
	override func draw(_ dirtyRect: NSRect) {

		NSColor.blue.set()
		dirtyRect.fill()
		super.draw(dirtyRect)

	}
}


///The header cell for the Splitter Table View.
///
///Automatically draws the background with the current `headColor` of the `AppDelegate`
class SplitterTableHeaderCell: NSTableHeaderCell {
	
	var headColor: NSColor!
	var parentTableView: SplitterTableView!
	required init(coder: NSCoder) {
		super.init(coder: coder)
	}

    override init(textCell: String) {
        super.init(textCell: textCell)
    }
	init (color: NSColor, textCell: String) {
		super.init(textCell: textCell)
		self.headColor = color
	}
	
	override func draw(withFrame cellFrame: NSRect, in controlView: NSView)
	   {
		//I have to store this in the AppDelagate, becuase if I just had a class variable for it, the app would crash for some bizarre reason
//		let hc = NSApplication.appDelegate.headColor
//		let hc = parentTableView.parentViewController.tableBGColor
		self.drawsBackground = true
//		hc.set()
//		headColor?.set()
		self.backgroundColor?.set()
		cellFrame.fill()

		super.draw(withFrame: cellFrame, in: controlView)//, since that is what draws borders
		
	   }
	
	override func highlight(_ flag: Bool, withFrame cellFrame: NSRect, in controlView: NSView) {
//		(NSApp.delegate as! AppDelegate).headColor.set()
//		parentTableView.parentViewController.tableBGColor.set()
//		headColor?.set()
		self.backgroundColor?.set()
		cellFrame.fill()
		
		
		
		super.highlight(flag, withFrame: cellFrame, in: controlView)
		
	}
}
