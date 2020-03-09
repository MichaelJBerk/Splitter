//
//  SplitterUITests.swift
//  SplitterUITests
//
//  Created by Michael Berk on 3/9/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import XCTest

class SplitterUITests: XCTestCase {
	var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
		app = XCUIApplication()
		app.launchArguments.append("--uitesting")

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	func testStartRun() {
		app.launch()
		
		
	}

    func testExample() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
		
		let untitledWindow = XCUIApplication().windows["Untitled"]
		untitledWindow.buttons["Start"].click()
		untitledWindow.buttons["Finish"].click()
        app.launch()
		

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}

extension XCUIApplication {
	var isDisplayingMainWindow: Bool {
//		var hey = Splitter
		return otherElements["MainViewController"].exists
	}
}
