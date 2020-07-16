import XCTest
@testable import SplitsIOKit

final class SplitsIOKitTests: XCTestCase {
	
	func testSearch() {
		let expectation = XCTestExpectation(description: "Complete Search")
		SplitsIOKit().searchSplitsIO(for: "Psychonauts", completion: { games in
			XCTAssertFalse(games == nil)
			expectation.fulfill()
		})
		wait(for: [expectation], timeout: 10.0)
	}
	
	func testGetRun() {
		let expectation = XCTestExpectation(description: "Find run")
		SplitsIOKit().getRun(runID: "5yj6", completion: { run in
			expectation.fulfill()
		})
		wait(for: [expectation], timeout: 10.0)
	}
	
}
