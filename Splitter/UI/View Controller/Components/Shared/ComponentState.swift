//
//  ComponentState.swift
//  Splitter
//
//  Created by Michael Berk on 7/5/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation
protocol SplitterComponentState: Codable {
	var afterSpacing: Float { get set }
	var isHidden: Bool { get set }
	var componentType: SplitterComponentType {get}
}

extension SplitterComponentState {
	
	static func decode<T: SplitterComponentState>(data: Data) throws -> T {
		return try JSONDecoder().decode(T.self, from: data)
	}
	func encode() throws -> Data {
		return try JSONEncoder().encode(self)
	}
	
}

struct BasicComponentState: SplitterComponentState {
	var componentType: SplitterComponentType
	var afterSpacing: Float
	var isHidden: Bool
	
}
typealias ComponentStateDict = [String: JSONAny]
