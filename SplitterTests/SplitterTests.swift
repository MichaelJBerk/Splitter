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

	func testImportLiveSplit() {
		let ls = LiveSplit()
////		ls.displayImportDialog()
//		ls.path = "/Users/michaelberk/Documents/KIU.lss"
		ls.path = "/Users/michaelberk/Documents/mario.timesplittracker"
//		ls.parseLivesplit()
		
//		vc.current
		if let vc = viewController {
			
			vc.loadLS(ls: ls)
		}
		
//		var i = 0
//		viewController!.iconArray = []
//		while i < viewController!.currentSplits.count {
//			if ls.iconArray[i] != nil {
//			viewController!.iconArray.append(ls.iconArray[i])
//			}
//			i = i + 1
//		}
//		
//		XCTAssert(ls.img != nil)
	}
	
	func testCompImport() {
//		let path = "/Users/michaelberk/Documents/Mario64.lfs"
		let comp = CompositeImport()
//		comp.path = "/Users/michaelberk/Documents/KIU.lss"
//		comp.cImport()
//		let path = URL(fileURLWithPath: "/Users/michaelberk/Documents/m2.lfs")
//		do {
//			let hey = try lfs(contentsOf: path, ofType: "Llanfair split")
//		} catch {
//			print("error: ", error)
//		}
		
		
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
