//
//  Font.swift
//  LiveSplitKit
//
//  Created by Michael Berk on 3/24/22.
//

import Foundation

public struct LiveSplitFont: Codable {
	//TODO: Add a way to get general settings, and get the font from that
	/**
	 The family name of the font to use.
	 
	 This corresponds with the Typographic Family Name (Name ID 16) in the name table of the font. If no such entry exists, the Font Family Name (Name ID 1) is to be used instead. If there are multiple entries for the name, the english entry is the one to choose. The subfamily is not specified at all, and instead a suitable subfamily is chosen based on the style, weight and stretch values.

	 [name — Naming Table on Microsoft Docs](https://docs.microsoft.com/en-us/typography/opentype/spec/name)

	 This is to ensure the highest portability across various platforms. Platforms often select fonts very differently, so if necessary it is also fine to store a different font identifier here at the cost of sacrificing portability.
	 */
	public var family: String
	///The style of the font to prefer selecting.
	public var style: Style
	///The weight of the font to prefer selecting.
	public var weight: Weight
	///The stretch of the font to prefer selecting.
	public var stretch: Stretch
	
	public enum Style: String, Codable {
		case normal
		case italic
		
		var displayName: String {
			switch self {
			case .normal:
				return "Normal"
			case .italic:
				return "Italics"
			}
		}
	}
	
	public enum Weight: String, Codable {
		case normal
		case thin
		case extraLight = "extra-light"
		case light
		case semiLight = "semi-light"
		case medium
		case semiBold = "semi-bold"
		case bold
		case extraBold = "extra-bold"
		case black
		case extraBlack = "extra-black"
		
		var displayName: String {
			switch self {
			case .thin:
				return "Thin"
			case .extraLight:
				return "Extra Light"
			case .light:
				return "Light"
			case .semiLight:
				return "Semi Light"
			case .normal:
				return "Normal"
			case .medium:
				return "Medium"
			case .semiBold:
				return "Semi Bold"
			case .bold:
				return "Bold"
			case .extraBold:
				return "Extra Bold"
			case .black:
				return "Black"
			case .extraBlack:
				return "Extra Black"
			}
		}
	}
	
	public enum Stretch: String, Codable {
		case normal
		case ultraCondensed = "ultra-condensed"
		case extraCondesned = "extra-condensed"
		case condensed
		case semiCondensed = "semi-condensed"
		case semiExpanded = "semi-expanded"
		case expanded
		case extraExpanded = "extra-expanded"
		case ultraExpanded = "ultra-expanded"
		
		var displayName: String {
			switch self {
			case .ultraCondensed:
				return "Ultra Condensed"
			case .extraCondesned:
				return "Extra Condensed"
			case .condensed:
				return "Condensed"
			case .semiCondensed:
				return "Semi Condensed"
			case .normal:
				return "Normal"
			case .semiExpanded:
				return "Semi Expanded"
			case .expanded:
				return "Expanded"
			case .extraExpanded:
				return "ExtraExpanded"
			case .ultraExpanded:
				return "Ultra Expanded"
			}
		}
	}
}

public extension SettingValue {
	static func fromFont(_ value: LiveSplitFont) -> SettingValue? {
		let style = value.style.rawValue
		let wieght = value.weight.rawValue
		let stretch = value.stretch.rawValue
		return .fromFont(value.family, style, wieght, stretch)
	}
}
