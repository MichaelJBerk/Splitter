//
//  Font+NSFont.swift
//  LiveSplitKit
//
//  Created by Michael Berk on 6/8/23.
//

import Foundation
#if canImport(Cocoa)
import Cocoa
extension LiveSplitFont.Weight {
	/**
	 Representation of the font's weight that can be used in an NSFontDescriptor
	 
	 This value represents the font's weight using units that can be used with NSFontDescriptor.
	 
	 ```swift
	 let fontAttributes: [NSFontDescriptor.AttributeName: Any] = [
	 .family: fontName,
	 .traits: [NSFontDescriptor.TraitKey.weight: LiveSplitFont.Weight.medium]
	 ]
	 let fontDescriptor = NSFontDescriptor(fontAttributes: fontAttributes)
	 let font = NSFont(descriptor: fontDescriptor, size: NSFont.systemFontSize)!
	 ```
	 */
	public var nsFontWeight: CGFloat {
		let black = NSFont.Weight.black.rawValue
		let light = NSFont.Weight.light.rawValue
		let regular = NSFont.Weight.regular.rawValue
		
		switch cssWeight {
		case 100:
			return NSFont.Weight.ultraLight.rawValue
		case 200:
			return NSFont.Weight.thin.rawValue
		case 300:
			return NSFont.Weight.light.rawValue
		case 350:
			return light + (regular - light)/2
		case 400:
			return NSFont.Weight.regular.rawValue
		case 500:
			return NSFont.Weight.medium.rawValue
		case 600:
			return NSFont.Weight.semibold.rawValue
		case 700:
			return NSFont.Weight.bold.rawValue
		case 800:
			return NSFont.Weight.heavy.rawValue
		case 900:
			return black
		case 950:
			return black + (1 - black)/2
		default:
			return NSFont.Weight.regular.rawValue
		}
	}
}
#endif
