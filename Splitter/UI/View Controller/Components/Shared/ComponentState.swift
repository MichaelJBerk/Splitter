//
//  ComponentState.swift
//  Splitter
//
//  Created by Michael Berk on 7/5/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation

///Codable representation of a component's state
///
///This is used mostly for the `appearance.json` file to include the list of components, in order.
///``ComponentState`` can be used to store certain state information that is not supported in LiveSplitCore, or where it's too difficult to.
///To save/load state, see ``ComponentState/properties``
struct ComponentState: Codable {
	var type: SplitterComponentType
	
	//TODO: Finish Docs for this
	///Contains the state information for the component
	///
	///Use this to save component state information to `appearance.json`, or to load component state information from it.
	///
	///Each value has a key and value
	var properties: [String: Codable]
	
	init(type: SplitterComponentType, properties: [String: Codable]) {
		self.type = type
		self.properties = properties
	}
	
	init(from decoder: Decoder) throws {
		self.type = try decoder.decode("type")
		self.properties = try decoder.decode("properties", as: [String: JSONAny].self)
	}
	func encode(to encoder: Encoder) throws {
		try encoder.encode(type, for: "type")
		let propMap: [String: JSONAny] = try properties.mapValues({
			let e = try $0.encoded()
			return try e.decoded(as: JSONAny.self, using: JSONDecoder())
			
		})
		try encoder.encode(propMap, for: "properties")
	}
	
	/// Get the value of a state property
	/// - Parameters:
	///   - key: The key for which to get the value for
	///   - type: The type of value to return
	/// - Returns: If the state contains a property of the given type with the given key, it will return the value of that property. Otherwise, it returns `nil`.
	func getProperty<PropType>(with key: String, of type: PropType.Type) -> PropType? where PropType: Decodable {
		return (properties[key] as? JSONAny)?.value as? PropType
		
	}
	
}
