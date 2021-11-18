// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let speedrunComGame = try? newJSONDecoder().decode(SpeedrunComGame.self, from: jsonData)

import Foundation

// MARK: - SpeedrunComGame
public struct SpeedrunComGame: Codable {
	public let id: String
	public let names: SpeedrunComNames
	public let abbreviation: String
	public let weblink: String
	public let released: Int
	public let releaseDate: String
	public let ruleset: SpeedrunComRuleset
	public let romhack: Bool
	public let gametypes: [String]
	public let platforms, regions: [String]
	public let genres, engines, developers, publishers: [String]
	public let moderators: SpeedrunComModerators
	public let created: Date
	public let assets: [String: SpeedrunComAsset?]
	public let links: [SpeedrunComLink]

	enum CodingKeys: String, CodingKey {
		case id, names, abbreviation, weblink, released
		case releaseDate = "release-date"
		case ruleset, romhack, gametypes, platforms, regions, genres, engines, developers, publishers, moderators, created, assets, links
	}
}

// MARK: - SpeedrunComAsset
public struct SpeedrunComAsset: Codable {
	public let uri: String
	public let width, height: Int
}

// MARK: - SpeedrunComLink
public struct SpeedrunComLink: Codable {
	public let rel: String?
	public let uri: String?
}

public typealias SpeedrunComModerators = [String: String]

// MARK: - SpeedrunComNames
public struct SpeedrunComNames: Codable {
	public let international, japanese, twitch: String?
}

// MARK: - SpeedrunComRuleset
public struct SpeedrunComRuleset: Codable {
	public let showMilliseconds, requireVerification, requireVideo: Bool
	public let runTimes: [String]
	public let defaultTime: String
	public let emulatorsAllowed: Bool

	enum CodingKeys: String, CodingKey {
		case showMilliseconds = "show-milliseconds"
		case requireVerification = "require-verification"
		case requireVideo = "require-video"
		case runTimes = "run-times"
		case defaultTime = "default-time"
		case emulatorsAllowed = "emulators-allowed"
	}
}
///Game from Speedrun.com
public struct SRCBulkGame: Codable {
	public let id: String
	public let names: SpeedrunComNames
	public let abbreviation: String
	public let weblink: String
}


//// MARK: - Encode/decode helpers
//
//class JSONNull: Codable, Hashable {
//
//	public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
//		return true
//	}
//
//	public var hashValue: Int {
//		return 0
//	}
//
//	public init() {}
//
//	public required init(from decoder: Decoder) throws {
//		let container = try decoder.singleValueContainer()
//		if !container.decodeNil() {
//			throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
//		}
//	}
//
//	public func encode(to encoder: Encoder) throws {
//		var container = encoder.singleValueContainer()
//		try container.encodeNil()
//	}
//}
