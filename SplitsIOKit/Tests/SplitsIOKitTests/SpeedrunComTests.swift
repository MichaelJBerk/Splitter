//
//  SpeedrunComTests.swift
//  
//
//  Created by Michael Berk on 11/16/21.
//

import XCTest
import Files

@testable import SplitsIOKit

final class SpeedrunComTests: XCTestCase {
	
	func testSearch() {
		let expectation = XCTestExpectation(description: "Complete Search")
		Speedruncom().searchSpeedruncom(for: "Super Mario Odyssey", completion: { games, error in
			XCTAssertFalse(games == nil)
			print(games?.compactMap({$0.names.international}))
			expectation.fulfill()
		})
		wait(for: [expectation], timeout: 10.0)
	}
	
	func testGetRuns() {
		let smsGameID = "v1pxjz68"
		let expectation = XCTestExpectation(description: "Get Game")
		Speedruncom().getRuns(query: .init(game: smsGameID, max: 1, offset: 0), completion: {runs, error in
			if let error = error {
				print("Error\n\(error)")
				XCTFail("GetRuns Failed")
				return
			}
			XCTAssertFalse(runs == nil)
			print(runs!.compactMap {$0.category})
			expectation.fulfill()
		})
		wait(for: [expectation], timeout: 10.0)
	}
}
