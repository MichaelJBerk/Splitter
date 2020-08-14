import Alamofire
import SwiftyJSON
import Fuzzy
import Foundation
import Files

public enum SplitsIOError: Error, LocalizedError {
	case cantGetRunID
	case noAuthManager
	case unauthorized
	
	public var errorDescription: String? {
		switch self {
		case .cantGetRunID:
			return NSLocalizedString("Cannot get run ID", comment: "")
		case .noAuthManager:
			return NSLocalizedString("SplitsIOKit has not been provided with an authManager", comment: "")
		case .unauthorized:
			return NSLocalizedString("The user has not been authorized to perform this action", comment: "")
		}
	}
}


public class SplitsIOKit {
	var searchRequest: DataRequest?
	var authManager: SplitsIOAuth?
	
	public static var shared = SplitsIOKit()
	
	
	convenience init() {
		self.init(auth: nil, url: URL(string:"https://splits.io")!)
	}
	/**
	Initalizes a SplitsIOKit object
	
	Use this method if you set authorization or use a custom instance of Splits.io.
	
	If you need to use feature that require authorization, you'll need to pass in a `SplitsIOAuth` object. Should you call a method that requires \
	authorization (such as `getCurrentUser(completion:)`) without this, it will throw a `SplitsIOError.noAuthManager ` error.
	See the documentation for `SplitsIOAuth` for more information.
	
	To use a custom fork/clone/instance of Splits.io, pass the URL leading to it in the URL parameter.
	For example, to lead it to your local development version:
	
		guard let url = URL(string: "http://localhost:3000")! else {return}
		let splitsio = SplitsIOKit(url: url)
	You can change the URL later by setting the `SplitsIOURL` property.
	
	- Parameter url: URL for Splits.io. By default, it's "https://splits.io".
	- Parameter auth: Class to be used for managing authorization
	*/
	public init(auth: SplitsIOAuth?, url: URL = URL(string:"https://splits.io")!) {
		splitsIOURL = url
		authManager = auth
	}
	/// URL to be used for Splits.io
	public var splitsIOURL: URL
	
	public func searchSplitsIO(for game: String, completion: @escaping ([SplitsIOGame]?) -> ()) {
		searchRequest?.cancel()
		if game.count == 0 {return}
		let gamesURL = splitsIOURL.appendingPathComponent("/api/v4/games")
		searchRequest = AF.request(gamesURL, method: .get, parameters: ["search":"\(game)"], encoding: URLEncoding.default).responseDecodable(of: SplitsIOGameSearch.self) { response in
			let v = response.value
			completion(v?.games)
		}
	}
	
	///Indicates whether or not this instance of SplitsIOKit has an authManager
	public var hasAuth: Bool {
		return authManager != nil
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
	
	public func getLatestSRLRaces(completion: @escaping(SRLRun) -> ()) {
		let url = URL(string: "https://api.speedrunslive.com/races")!
		AF.request(url, method: .get).responseData { response in
			
			if let data = response.data {
				do {
					let str = String(data: data, encoding: .utf8)
					print(str)
					let runs = try JSONDecoder().decode(SRLRun.self, from: data)
					completion(runs)
					
				} catch {
					print("Decode Error: ", error)
					
				}
				
			} else {
				print(response.error)
				
			}
			
		}
	}
	
	public func getCurrentUser(completion: @escaping (SplitsIORunner?) -> ()) throws {
		guard let authManager = authManager else {throw SplitsIOError.noAuthManager}
		let runnerURL = splitsIOURL.appendingPathComponent("/api/v4/runner")
		let authRequest = authManager.oAuth2.request(forURL: runnerURL)
		getRunner(url: authRequest, completion: completion)
	}
	public func getRunner(name: String, completion: @escaping(SplitsIORunner?) -> ()) {
		let runnerURL = splitsIOURL.appendingPathComponent("/api/v4/runners/\(name)")
		getRunner(url: URLRequest(url: runnerURL), completion: completion)
	}
	
	private func getRunner(url: URLRequest, completion: @escaping(SplitsIORunner?) -> ()) {
		AF.request(url).validate().responseData { response in
			if let error = response.error {
				print("Error Getting Runner: ", error)
				return
			} else {
				if let data = response.data {
					completion(self.getRunnerFromDict(runnerData: data))
				}
			}
		}
	}
	
	private func getRunnerFromDict(runnerData: Data) -> SplitsIORunner? {
		if let runnerDict = try? JSONDecoder().decode([String:SplitsIORunner].self, from: runnerData),
			let runner = runnerDict["runner"] {
			return runner
		}
		return nil
	}
	
	public func login(completion: @escaping () -> ()) throws {
		guard let authManager = authManager else {throw SplitsIOError.noAuthManager}
		try authManager.authenticate {
			completion()
		}
	}
	public func logout(completion: @escaping () -> ()) throws {
		guard let authManager = authManager else {throw SplitsIOError.noAuthManager}
		authManager.logout() {
			completion()
		}
	}
	public func handleRedirectURL(url: URL) throws {
		guard let authManager = authManager else {throw SplitsIOError.noAuthManager}
		authManager.oAuth2.handleRedirectURL(url)
	}
	
	public func getGamesFromRunner(runnerName: String, completion: @escaping([SplitsIOGame]?) -> ()) {
		let gamesURL = splitsIOURL.appendingPathComponent("api/v4/runners/\(runnerName)/games")
		searchRequest = AF.request(gamesURL, method: .get).responseData { response in
			if let error = response.error {
				print(error)
			} else {
				if let data = response.value {
					do {
						let games = try JSONDecoder().decode(SplitsIOGameSearch.self, from: data)
						completion(games.games)
						return
					} catch {
						print("Decode Error: ", error)
					}
					
				}
			}
			completion(nil)
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
	public let createdAt, id, name: String
	public let srdcID,shortname: String?
	public let updatedAt: String

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
	
	public func getRun(completion: @escaping(String?) -> ()) {
		getRun(splitsIOKit: SplitsIOKit(), completion: completion)
	}
	
	///Completion - the path to the temporary lss file
	public func getRun(splitsIOKit: SplitsIOKit, completion: @escaping(String?) -> ()) {
		return splitsIOKit.getRunFromCat(categoryID: self.id, completion: { run in
			completion(run)
		})
	}
}
// MARK: - SplitsIORunner
public struct SplitsIORunner: Codable {
    public let avatar: String
    public let createdAt, displayName, id, name: String
    public let twitchID, twitchName, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case avatar
        case createdAt = "created_at"
        case displayName = "display_name"
        case id, name
        case twitchID = "twitch_id"
        case twitchName = "twitch_name"
        case updatedAt = "updated_at"
    }
	public func getGames(splitsIOKit: SplitsIOKit, completion: @escaping([SplitsIOGame]?) -> ()) {
		splitsIOKit.getGamesFromRunner(runnerName: name, completion: completion)
	}
	
}
