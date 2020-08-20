//
//  File.swift
//  
//
//  Created by Michael Berk on 8/11/20.
//

import Foundation

public struct SRLRun: Decodable {
    let count: String
    let races: [SRLRace]
}

// MARK: - SRLRace
public struct SRLRace: Decodable {
    let id: String
    let game: SRLGame
    let goal: String
    let time, state: Int
    let statetext, filename: String
    let numentrants: Int
	var entrants: [String: SRLEntrant]
	
	private enum CodingKeys: String, CodingKey {
		case id
		case game
		case goal
		case time
		case state
		case statetext
		case filename
		case numentrants
		case entrants
	}
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(String.self, forKey: .id)
		game = try container.decode(SRLGame.self, forKey: .game)
		goal = try container.decode(String.self, forKey: .goal)
		time = try container.decode(Int.self, forKey: .time)
		state = try container.decode(Int.self, forKey: .state)
		statetext = try container.decode(String.self, forKey: .statetext)
		filename = try container.decode(String.self, forKey: .filename)
		numentrants = try container.decode(Int.self, forKey: .numentrants)
		entrants = [String:SRLEntrant]()
		
		let subContainer = try container.nestedContainer(keyedBy: GenericCodingKeys.self, forKey: .entrants)
		for key in subContainer.allKeys {
			entrants[key.stringValue] = try subContainer.decode(SRLEntrant.self, forKey: key)
		}
		
		
	}
}

public struct SRLEntrant: Codable {
	let displayname: String
    let place, time: Int
    let message: String?
    let statetext, twitch, trueskill: String
}

// MARK: - SRLGame
public struct SRLGame: Codable {
    let id: Int
    let name, abbrev: String
    let popularity, popularityrank: Double
}

public struct GenericCodingKeys: CodingKey {
    public var intValue: Int?
    public var stringValue: String
	
	public init?(intValue: Int) { self.intValue = intValue; self.stringValue = "\(intValue)" }
	public init?(stringValue: String) { self.stringValue = stringValue }
	
	public static func makeKey(name: String) -> GenericCodingKeys {
        return GenericCodingKeys(stringValue: name)!
    }
}
