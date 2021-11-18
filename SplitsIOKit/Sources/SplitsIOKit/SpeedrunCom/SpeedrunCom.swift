//
//  File.swift
//  
//
//  Created by Michael Berk on 8/16/20.
//

import Foundation
import Alamofire
import URLQueryItemEncoder

///Class for handing data from Speedrun.com
public class Speedruncom {
	let speedrunURL = URL(string:"https://www.speedrun.com/api/v1")!
	public func searchSpeedruncom(for game: String, completion: @escaping([SRCBulkGame]?, Error?)->()) {
		if game.count == 0 {return}
		let gamesURL = speedrunURL.appendingPathComponent("games")
		let params = ["name": game, "_bulk":"yes"]
		AF.request(gamesURL, method: .get, parameters: params, encoding:URLEncoding.default).responseData { response in
			if let error = response.error {
				completion(nil, error)
			} else {
				do {
					let bulkSearch = try JSONDecoder().decode(SRCBulkSearch.self, from: try response.result.get())
					completion(bulkSearch.data, nil)
				} catch {
					completion(nil, error)
				}
			}
		}
	}
	
	public func getRuns(query: AdvancedRunQuery, completion: @escaping([SpeedrunComRun]?, Error?) -> ()) {
		var runsURL = URLComponents(url: speedrunURL.appendingPathComponent("runs"), resolvingAgainstBaseURL: false)!
		var params: [URLQueryItem]
		do {
			params = try URLQueryItemEncoder().encode(query)
		} catch {
			completion(nil, error)
			return
		}
		runsURL.queryItems = params
		
		AF.request(runsURL.url!, encoding: URLEncoding.default).responseData(completionHandler: { response in
			if let error = response.error {
				completion(nil, error)
			} else {
				do {
					let runs = try JSONDecoder().decode(SRCRunData.self, from: try response.result.get())
					let hey = try! String(data: try response.result.get(), encoding: .utf8)
					print(hey!.description)
					completion(runs.data, nil)
				} catch {
					
					completion(nil, error)
				}
			}
		})
	}
}

public struct AdvancedRunQuery: Codable {
	public init(user: String? = nil, guest: String? = nil, examiner: String? = nil, game: String? = nil, level: String? = nil, category: String? = nil, platform: String? = nil, region: String? = nil, emulated: Bool? = nil, status: AdvancedRunQuery.Status? = nil, orderBy: AdvancedRunQuery.OrderBy? = nil, direction: AdvancedRunQuery.Direction? = nil, max: Int? = nil, offset: Int? = nil) {
		self.user = user
		self.guest = guest
		self.examiner = examiner
		self.game = game
		self.level = level
		self.category = category
		self.platform = platform
		self.region = region
		self.emulated = emulated
		self.status = status
		self.orderBy = orderBy
		self.direction = direction
		self.max = max
		self.offset = offset
	}
	

	///game ID; when given, restricts to that game
	public let user: String?
	///Only return runs done by that guest
	public let guest: String?
	///user ID; only returns runs examined by that user
	public let examiner: String?
	///game ID; when given, restricts to that game
	public let game: String?
	//level ID; when given, restricts to that level
	public let level: String?
	///category ID; when given, restricts to that category
	public let category: String?
	///platform ID; when given, restricts to that platform
	public let platform: String?
	///region ID; when given, restricts to that region
	public let region: String?
	///When `true`, only games run on emulator will be returned
	public let emulated: Bool?
	///filters by run status
	public let status: Status?
	
	public let orderBy: OrderBy?
	
	public let direction: Direction?
	
	public let max: Int?
	public let offset: Int?
	
	public enum Status: String, Codable {
		case new
		case verified
		case rejected
	}
	
	public enum Direction: String, Codable {
		case ascending = "asc"
		case descending = "desc"
	}
	
	public enum OrderBy: String, Codable {
		///sorts by the game the run was done in
		case game
		///sorts by the category the run was done in
		case category
		///sorts by the level the run was done in
		case level
		///sorts by the console used for the run
		case platform
		///sorts by the console region the run was done in
		case region
		///sorts by whether or not a run is done via emulator
		case emulated
		///sorts by the date the run happened on
		case date
		///sorts by the date when the run was submitted to speedrun.com
		case submitted
		///sorts by verification status
		case status
		///sorts by the date the run was verified on
		case verifyDate = "verify-date"
		
	}
	
	
	
}


// MARK: - SRCBulkGame


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

struct SRCRunData: Codable {
	let data: [SpeedrunComRun]
}
