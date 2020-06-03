//
//  Colors.swift
//  Splitter
//
//  Created by Michael Berk on 5/31/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//


import Cocoa

extension NSButton {
	var baseTitle: String {
		set {
			let attributes = self.attributedTitle
			
			var att: [NSAttributedString.Key: Any] = [:]
			for i in attributes.attributes(at: 0, effectiveRange: nil) {
				att[i.key] = i.value
			}
			self.attributedTitle = NSAttributedString(string: newValue, attributes: att)
		} get {
			return self.title
		}
		
		
	}
	
	//I'm overriding the property observer so that the appearance will be dark when enabled, thus making it transparent
	open override var isEnabled: Bool {
		didSet {
			if !oldValue && self.isEnabled {
				appearance = NSAppearance(named: .darkAqua)
			}
		}
	}
	

}

class bCell: NSButtonCell {
	override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {

    if !self.isEnabled {
        return super.drawTitle(self.attributedTitle, withFrame: frame, in: controlView)
    }

    return super.drawTitle(title, withFrame: frame, in: controlView)
    }
}


extension NSImage {
    func image(with tintColor: NSColor) -> NSImage {
		if self.isTemplate == false {
			return self
		}
		
		let image = self.copy() as! NSImage
		image.lockFocus()
		
		tintColor.set()
		
		let imageRect = NSRect(origin: .zero, size: image.size)
		imageRect.fill(using: .sourceIn)
		
		image.unlockFocus()
		image.isTemplate = false
		
		return image
	}
}

extension NSColor {
	static let splitterDefaultColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
	static let splitterTableViewColor = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
	static let splitterRowSelected = NSColor(named: "CurrentSplitColor")!

    // Check if the color is light or dark, as defined by the injected lightness threshold.
    // Some people report that 0.7 is best. I suggest to find out for yourself.
    // A nil value is returned if the lightness couldn't be determined.
    func isLight(threshold: Float = 0.5) -> Bool? {
        let originalCGColor = self.cgColor

        // Now we need to convert it to the RGB colorspace. UIColor.white / UIColor.black are greyscale and not RGB.
        // If you don't do this then you will crash when accessing components index 2 below when evaluating greyscale colors.
        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return nil
        }
        guard components.count >= 3 else {
            return nil
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
}
