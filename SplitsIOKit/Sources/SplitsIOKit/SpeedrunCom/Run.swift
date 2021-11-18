// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let speedrunComRun = try? newJSONDecoder().decode(SpeedrunComRun.self, from: jsonData)

import Foundation

// MARK: - SpeedrunComRun
public struct SpeedrunComRun: Codable {
	public let id: String
	public let weblink: String
	public let game: String
	public let level: String?
	public let category: String
	public let videos: SpeedrunComVideos?
	public let comment: String?
	public let status: SpeedrunComStatus
	public let players: [SpeedrunComPlayer]
	public let date: String?
	public let submitted: Date?
	public let times: SpeedrunComTimes
	public let system: SpeedrunComSystem
	public let splits: SpeedrunComSplits?
	public let values: [String: String]
	public let links: [SpeedrunComSplits]

	public init(id: String, weblink: String, game: String, level: String?, category: String, videos: SpeedrunComVideos, comment: String, status: SpeedrunComStatus, players: [SpeedrunComPlayer], date: String, submitted: Date?, times: SpeedrunComTimes, system: SpeedrunComSystem, splits: SpeedrunComSplits?, values: [String: String], links: [SpeedrunComSplits]) {
		self.id = id
		self.weblink = weblink
		self.game = game
		self.level = level
		self.category = category
		self.videos = videos
		self.comment = comment
		self.status = status
		self.players = players
		self.date = date
		self.submitted = submitted
		self.times = times
		self.system = system
		self.splits = splits
		self.values = values
		self.links = links
	}
}

// MARK: - SpeedrunComSplits
public struct SpeedrunComSplits: Codable {
	public let rel: String?
	public let uri: String?

	public init(rel: String?, uri: String?) {
		self.rel = rel
		self.uri = uri
	}
}

// MARK: - SpeedrunComPlayer
public struct SpeedrunComPlayer: Codable {
	public let rel: String
	public let id: String?
	public let uri: String
	public let name: String?

	public init(rel: String, id: String?, uri: String, name: String?) {
		self.rel = rel
		self.id = id
		self.uri = uri
		self.name = name
	}
}

// MARK: - SpeedrunComStatus
public struct SpeedrunComStatus: Codable {
	public let status: String
	public let examiner: String?
	public let verifyDate: String?

	enum CodingKeys: String, CodingKey {
		case status, examiner
		case verifyDate = "verify-date"
	}

	public init(status: String, examiner: String?, verifyDate: String?) {
		self.status = status
		self.examiner = examiner
		self.verifyDate = verifyDate
	}
}

// MARK: - SpeedrunComSystem
public struct SpeedrunComSystem: Codable {
	public let platform: String?
	public let emulated: Bool?
	public let region: String?

	public init(platform: String?, emulated: Bool?, region: String?) {
		self.platform = platform
		self.emulated = emulated
		self.region = region
	}
}

// MARK: - SpeedrunComTimes
public struct SpeedrunComTimes: Codable {
	public let primary: String?
	public let primaryT: Int?
	public let realtime: String?
	public let realtimeT: Int?
	public let realtimeNoloads: String?
	public let realtimeNoloadsT: Int?
	public let ingame: JSONNull?
	public let ingameT: Int?

	enum CodingKeys: String, CodingKey {
		case primary
		case primaryT = "primary_t"
		case realtime
		case realtimeT = "realtime_t"
		case realtimeNoloads = "realtime_noloads"
		case realtimeNoloadsT = "realtime_noloads_t"
		case ingame
		case ingameT = "ingame_t"
	}

	public init(primary: String?, primaryT: Int?, realtime: String?, realtimeT: Int?, realtimeNoloads: String?, realtimeNoloadsT: Int?, ingame: JSONNull?, ingameT: Int?) {
		self.primary = primary
		self.primaryT = primaryT
		self.realtime = realtime
		self.realtimeT = realtimeT
		self.realtimeNoloads = realtimeNoloads
		self.realtimeNoloadsT = realtimeNoloadsT
		self.ingame = ingame
		self.ingameT = ingameT
	}
}

// MARK: - SpeedrunComVideos
public struct SpeedrunComVideos: Codable {
	public let text: String?
	public let links: [SpeedrunComLink]?

	public init(text: String?, links: [SpeedrunComLink]?) {
		self.text = text
		self.links = links
	}
}
