//
//  NSColorExtension.swift
//  LiveSplitKit
//
//  Created by Michael Berk on 1/21/22.
//

import AppKit

extension NSColor {
	convenience init(_ color: [Double]) {
		let floats = color.map({CGFloat($0)})
		self.init(red: floats[0], green: floats[1], blue: floats[2], alpha: floats[3])
	}
	func toDouble() -> [Double] {
		let converted = self.usingColorSpace(.sRGB)
		let floats = [converted!.redComponent, converted!.greenComponent, converted!.blueComponent, converted!.alphaComponent]
		return floats.map({Double($0)})
	}
	convenience init(_ color: [Float]) {
		let floats = color.map({CGFloat($0)})
		self.init(red: floats[0], green: floats[1], blue: floats[2], alpha: floats[3])
	}
	func toFloat() -> [Float] {
		let converted = self.usingColorSpace(.sRGB)
		let floats = [converted!.redComponent, converted!.greenComponent, converted!.blueComponent, converted!.alphaComponent]
		return floats.map({Float($0)})
	}
}

extension NSColor {
	static func from(hex: String) -> NSColor {
		let hexVal = hex.replacingOccurrences(of: "#", with: "")
		let hex = UInt32(hexVal, radix: 16)!
		let a = CGFloat((hex >> 24) & 0xFF) / 255.0
		let r = CGFloat((hex >> 16) & 0xFF) / 255.0
		let g = CGFloat((hex >> 8)  & 0xFF) / 255.0
		let b = CGFloat((hex)       & 0xFF) / 255.0
		
		let color = NSColor(red: r, green: g, blue: b, alpha: a)
		
		return color
	}
}

extension SettingValue {
	public static func fromNSColor(_ color: NSColor) -> SettingValue {
		let floats = color.toFloat()
		return .fromColor(floats[0], floats[1], floats[2], floats[3])
	}
	public static func fromAlternatingNSColor(_ color1: NSColor, _ color2: NSColor) -> SettingValue {
		let floats1 = color1.toFloat()
		let floats2 = color2.toFloat()
		return .fromAlternatingGradient(floats1[0], floats1[1], floats1[2], floats1[3], floats2[0], floats2[1], floats2[2], floats2[3])
	}
}
