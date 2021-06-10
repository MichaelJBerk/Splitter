//
//  FileTests.swift
//  SplitterUITests
//
//  Created by Michael Berk on 6/10/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import XCTest

class FileTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
		let app = XCUIApplication()
			app.launchArguments = ["-newFile"]
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
		app.launch()
//        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
	
	func testSegTitle() {
		
		let untitled20Window = XCUIApplication().windows["Untitled 20"]
		let splittitlecellTextField = untitled20Window/*@START_MENU_TOKEN@*/.tables.textFields["SplitTitleCell"]/*[[".scrollViews.tables",".tableRows",".cells.textFields[\"SplitTitleCell\"]",".textFields[\"SplitTitleCell\"]",".tables"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/
		splittitlecellTextField.click()
		splittitlecellTextField.doubleClick()
		
		let gameControllerCell = untitled20Window/*@START_MENU_TOKEN@*/.tables.cells.containing(.image, identifier:"Game Controller").element/*[[".scrollViews.tables",".tableRows.cells.containing(.image, identifier:\"Game Controller\").element",".cells.containing(.image, identifier:\"Game Controller\").element",".tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
		gameControllerCell.typeKey(.delete, modifierFlags:[])
		gameControllerCell.typeText("hkhkjh")
		
	}

}
