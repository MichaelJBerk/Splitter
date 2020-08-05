import Alamofire
import SwiftyJSON
import Fuzzy
import Foundation
import Files


public class SplitsIOKit {
	var searchRequest: DataRequest?
	public init(url: URL = URL(string:"https://splits.io")!) {
		splitsIOURL = url
	}
	var splitsIOURL: URL
	
	enum SplitsIOError: Error {
		case cantGetRunID
	}
	
	public func searchSplitsIO(for game: String, completion: @escaping ([SplitsIOGame]?) -> ()) {
		searchRequest?.cancel()
		if game.count == 0 {return}
		let gamesURL = splitsIOURL.appendingPathComponent("/api/v4/games")
		searchRequest = AF.request(gamesURL, method: .get, parameters: ["search":"\(game)"], encoding: URLEncoding.default).responseDecodable(of: SplitsIOGameSearch.self) { response in
			
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
		let runsURL = splitsIOURL.appendingPathComponent("/api/v4/runs/\(runID)")
		AF.request(runsURL, headers: .init(["Accept":"application/splitsio"])).responseString { response in

			if let data = response.data {
				let str = String(data: data, encoding: .utf8)
				let run = try? JSONDecoder().decode(SplitsIOExchangeFormat.self, from: data)
				print(run!.game?.longname)
				completion(run)
			}
		}
	}
	
	
	/// - Parameters:
	///   - completion: returns path to temp `.lss` file
	public func getRunFromCat(categoryID: String, completion: @escaping(String?)-> ()) {
		let catURL = splitsIOURL.appendingPathComponent("/api/v4/categories/\(categoryID)/runs")
		AF.request(catURL).responseString { response in
			if let data = response.data {
				let json = JSON(data)
				guard let id = json["runs"][0].dictionary?["id"]?.string else {completion(nil)
					return
				}
				self.getRunAsLivesplit(runID: id, completion: { run in
					completion(run)
					
				})
			}
		}
	}
	
	///Downloads a LiveSplit file and saves it to the caches directory
	public func getRunAsLivesplit(runID: String, asTemplate: Bool = false, completion: @escaping (_ path: String?) -> ()) {
		let runsURL = splitsIOURL.appendingPathComponent("/api/v4/runs/\(runID)")
		AF.request(runsURL, headers: .init(["Accept":"application/livesplit"])).responseData { response in

			if let data = response.data {
				if let tempURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
					let fileName = "\(ProcessInfo().globallyUniqueString).lss"
					
					let cachesFolder = try! Folder(path: tempURL.path).createSubfolderIfNeeded(withName: "\(Bundle.main.bundleIdentifier ?? "com.mibe.splitsiokit")")
					let tempFile = try! cachesFolder.createFileIfNeeded(withName: fileName, contents: data)
					completion(tempFile.path)
				}

			}
		}
	}
	
	public func getCategories (for gameShortname: String, completion: @escaping([SplitsIOCat]) -> ()) {
		let catsURL = splitsIOURL.appendingPathComponent("/api/v4/games/\(gameShortname)/categories")
		AF.request(catsURL, parameters: .init(["filter":"nonempty"])).responseJSON { response in
			if let data = response.data {
				let json = JSON(data)
				let catJSON = json["categories"]
				if let cats = try? JSONDecoder().decode([SplitsIOCat].self, from: catJSON.rawData()) {
//					if let cat = try? JSONDecoder().decode(SplitsIOCat.self, from: catJSON.rawData()) {
					completion(cats)
					
				}
				
				
			}
		}
	}
	
	public func getCategory(for gameShortname: String, categoryName: String, completion: @escaping(SplitsIOCat) -> ()) {
		let catsURL = splitsIOURL.appendingPathComponent("/api/v4/games/\(gameShortname)/categories")
		AF.request(catsURL, headers: .init(["filter":"nonempty"])).responseJSON { response in
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
public struct SplitsIOGame: Codable, Hashable, Identifiable {
	
	public static func == (lhs: SplitsIOGame, rhs: SplitsIOGame) -> Bool {
		return lhs.id == rhs.id
	}
	
	public let categories: [SplitsIOCat]
	public let createdAt, id, name, shortname: String
	public let srdcID, updatedAt: String

	enum CodingKeys: String, CodingKey {
		case categories
		case createdAt = "created_at"
		case id, name, shortname
		case srdcID = "srdc_id"
		case updatedAt = "updated_at"
	}
}

// MARK: - Category
public struct SplitsIOCat: Codable, Hashable {
	public let createdAt, id, name: String
	let srdcID: String?
	let updatedAt: String

	enum CodingKeys: String, CodingKey {
		case createdAt = "created_at"
		case id, name
		case srdcID = "srdc_id"
		case updatedAt = "updated_at"
	}
	///Completion - the path to the temporary lss file
	public func getRun( completion: @escaping(String?) -> ()) {
		
		return SplitsIOKit().getRunFromCat(categoryID: self.id, completion: { run in
			completion(run)
		})
	}
}
