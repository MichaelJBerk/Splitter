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
