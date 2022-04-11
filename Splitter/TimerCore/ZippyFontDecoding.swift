//
//  ZippyFontDecoding.swift
//  Splitter
//
//  Created by Michael Berk on 4/11/22.
//  Copyright © 2022 Michael Berk. All rights reserved.
//

import Foundation
import LiveSplitKit
import ZippyJSON

fileprivate struct FontWrapper: Codable {
	var Font: LiveSplitFont
}

public extension SettingValueRef {
	func toFont() -> LiveSplitFont {
		let value = self.asJson()
		let data = value.data(using: .utf8)!
		let decoded = try! ZippyJSONDecoder().decode(FontWrapper.self, from: data)
		return decoded.Font
		
	}
	
}
