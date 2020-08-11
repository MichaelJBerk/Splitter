import XCTest
import Files

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
	func testGetLivesplitRun() {
		let expectation = XCTestExpectation(description: "Find run")
		SplitsIOKit().getRunAsLivesplit(runID: "5yj6", completion: { run in
			let rFile = try? File(path: run!)
			try? rFile?.delete()
			expectation.fulfill()
		})
		wait(for: [expectation], timeout: 10.0)
	}
	func testGetRunsFromCat() {
		let expectation = XCTestExpectation(description: "get runs from cat")
		SplitsIOKit().getRunFromCat(categoryID: "4075", completion: { runs in
			expectation.fulfill()
			
		})
		wait(for: [expectation], timeout: 10.0)
	}
	func testGetCategories() {
		let expectation = XCTestExpectation(description: "Get categories")
		SplitsIOKit().getCategories(for: "yi", completion: { cats in
			expectation.fulfill()
			
		})
		wait(for: [expectation], timeout: 10.0)
	}
	func testSRL() {
		let expectation = XCTestExpectation(description: "get runs from SRL")
		SplitsIOKit().getLatestSRLRaces(completion: { SRL in
			expectation.fulfill()
			print(SRL.count)
			
		})
		wait(for: [expectation], timeout: 10.0)
	}
	
	
	
}
