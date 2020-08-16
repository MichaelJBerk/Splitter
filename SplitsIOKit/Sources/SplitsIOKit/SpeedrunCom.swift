//
//  File.swift
//  
//
//  Created by Michael Berk on 8/16/20.
//

import Foundation
import Alamofire

///Class for handing data from Speedrun.com
public class Speedruncom {
	let speedrunURL = URL(string:"https://www.speedrun.com/api/v1")!
	public func searchSpeedruncom(for game: String, completion: @escaping([SRCBulkGame]?)->()) {
		if game.count == 0 {return}
		let gamesURL = speedrunURL.appendingPathComponent("games")
		let params = ["name": game, "_bulk":"yes"]
		AF.request(gamesURL, method: .get, parameters: params, encoding:URLEncoding.default).responseData { response in
			if let error = response.error {
				print(error)
			} else {
				do {
					let bulkSearch = try JSONDecoder().decode(SRCBulkSearch.self, from: try response.result.get())
					completion(bulkSearch.data)
				} catch {
					print(error)
				}
			}
		}
	}
}


// MARK: - SRCBulkGame


///Game from Speedrun.com
public struct SRCBulkGame: Codable {
    let id: String
    let names: Names
    let abbreviation: String
    let weblink: String
}

// MARK: - Names
public struct Names: Codable {
    let international, japanese: String?
}

// MARK: - SRCPagination
struct SRCPagination: Codable {
    let offset, max, size: Int
    let links: [JSONAny]
}

// MARK: - SRCSearch
struct SRCBulkSearch: Codable {
    let data: [SRCBulkGame]
    let pagination: SRCPagination
}
