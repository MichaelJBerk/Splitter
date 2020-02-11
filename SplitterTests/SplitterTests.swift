//
//  SplitterTests.swift
//  SplitterTests
//
//  Created by Michael Berk on 2/5/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import XCTest
@testable import Splitter

class SplitterTests: XCTestCase {
	
	//Path to the SplitterTests folder
	fileprivate let testPath = URL(fileURLWithPath: #file).pathComponents.dropLast().joined(separator: "/").dropFirst() //.pathComponents
		//.prefix(while: { $0 != "Tests" }).joined(separator: "/").dropFirst()


	var viewController: ViewController?
	
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
		self.viewController = ViewController()
    }
	func testGlobalHotkeysSetup() {
		let globalHotkeySetting = Settings.enableGlobalHotkeys
		if let app = NSApp.delegate as? AppDelegate {
			let hotkey1Paused =  app.keybinds[0].hotkey?.isPaused
			XCTAssert((hotkey1Paused != globalHotkeySetting))
		}
	}
	
	
	func testOpenSplit() {
		let path = String(testPath + "/Odyssey.split")
		let url = URL(fileURLWithPath: path)
		let doc = try? Document(contentsOf: url, ofType: "Split file")
		let dc = NSDocumentController.shared
		dc.addDocument(doc!)
	}
	
	func testImportSplitsIO() {
		let path = String("/robobot.json")
	}
	

	func testImportLiveSplit() {
		let ls = LiveSplit()

		ls.path = String(testPath + "/KIU.lss")
		ls.parseLivesplit()
	}
	
	
	
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
