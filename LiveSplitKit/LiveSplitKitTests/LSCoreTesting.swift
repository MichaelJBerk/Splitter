//
//  LSCoreTesting.swift
//  SplitterTests
//
//  Created by Michael Berk on 3/24/22.
//  Copyright © 2022 Michael Berk. All rights reserved.
//

import XCTest
@testable import LiveSplitKit

class LSCoreTesting: XCTestCase {
	
	var run: Run!
	var layout: Layout!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
		run = Run()
		let segment = Segment("")
		run.pushSegment(segment)
		layout = Layout.defaultLayout()
		
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	///Test that the methods for getting/setting timing method work
	func testTimingMethod() {
		guard let le = LayoutEditor(layout) else {return}
		le.select(1)
		let method1 = le.getTimingMethod(for: 0)
		XCTAssert(method1 == nil)
		le.setColumn(0, timingMethod: .realTime)
		let method2 = le.getTimingMethod(for: 0)
		XCTAssert(method2 == .realTime)
		le.setColumn(0, timingMethod: .gameTime)
		let method3 = le.getTimingMethod(for: 0)
		XCTAssert(method3 == .gameTime)
	}
	
	func testGetFont() {
		guard let le = LayoutEditor(layout) else {return}
		let font = LiveSplitFont(family: "times", style: .normal, weight: .normal, stretch: .normal)
		guard let setVal = SettingValue.fromFont(font) else {return}
		le.setGeneralSettingsValue(3, setVal)
		layout = le.close()
		
		let timer = LSTimer(run)
		let jState = layout.stateAsJson(timer!)
		
		let pasteboard = NSPasteboard.general
		pasteboard.declareTypes([.string], owner: nil)
		pasteboard.setString(jState, forType: .string)
		
		/*
		 1: Custom Timer Font
		 2: Custom Times Font
		 3: Custom Text Font
		 */
//		SettingValue.fromFont(<#T##String#>, <#T##String#>, <#T##String#>, <#T##String#>)
//		let font = le.state().fieldValue(false, 3)
//		let json = font.asJson()
//		print(json)
//		print("hey")
//		le.setGeneralSettingsValue(<#T##size_t#>, T##SettingValue)
	}

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
