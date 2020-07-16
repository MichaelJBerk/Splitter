import Alamofire
import SwiftyJSON
import Fuzzy
import Foundation


struct SplitsIOKit {
	
	
	public func searchSplitsIO(for game: String, completion: @escaping ([SplitsIOGame]?) -> ()) {
		AF.request("https://splits.io/api/v4/games", method: .get, parameters: ["search":"\(game)"], encoding: URLEncoding.default).responseDecodable(of: SplitsIOGameSearch.self) { response in
			
			let v = response.value
			completion(v?.games)

		}
		
	}
	
	
	/// Get a run from Splits.io
	/// - Parameters:
	///   - runID: Splits.io canonical ID for the run
	///   - asTemplate: If`true`, all time fields for the run will be blank
	///   - completion: Completion handler for the run
	/// - Returns: Run in splits.ioExchange format
	public func getRun(runID: String, asTemplate: Bool = false, completion: @escaping (SplitsIOExchangeFormat?) -> ()) {
		AF.request("https://httpbin.org/get").responseString { response in

			if let data = response.data {
				let run = try? JSONDecoder().decode(SplitsIOExchangeFormat.self, from: data)
				print(run!.game?.longname)
				completion(run)
			}


		}
	}
	
	public func getCategory(for gameShortname: String, categoryName: String, completion: @escaping(SplitsIOCat) -> ()) {
		AF.request("https://splits.io/api/v4/games/\(gameShortname)/categories").responseJSON { response in
			if let data = response.data {
				let json = JSON(data)
				if let catJSON = json["categories"].array?.first(where: {$0.dictionary?["name"]?.string == categoryName}) {
					if let cat = try? JSONDecoder().decode(SplitsIOCat.self, from: catJSON.rawData()) {
						completion(cat)
					}
					
					
				}
				
				
			}
		}
	}
	

	
}

// MARK: - SplitsIOGameSearch
struct SplitsIOGameSearch: Codable {
	let games: [SplitsIOGame]
}

// MARK: - Game
public struct SplitsIOGame: Codable {
	let categories: [SplitsIOCat]
	let createdAt, id, name, shortname: String
	let srdcID, updatedAt: String

	enum CodingKeys: String, CodingKey {
		case categories
		case createdAt = "created_at"
		case id, name, shortname
		case srdcID = "srdc_id"
		case updatedAt = "updated_at"
	}
}

// MARK: - Category
public struct SplitsIOCat: Codable {
	let createdAt, id, name: String
	let srdcID: String?
	let updatedAt: String

	enum CodingKeys: String, CodingKey {
		case createdAt = "created_at"
		case id, name
		case srdcID = "srdc_id"
		case updatedAt = "updated_at"
	}
	func getRuns() -> String {
		return ""
	}
}
