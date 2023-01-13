//
//  FileTests.swift
//  SplitterUITests
//
//  Created by Michael Berk on 6/10/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import XCTest
import Files

class FileTests: XCTestCase {
	
	func setupEditableFile() throws -> File {
		let testBundle = Bundle(for: type(of: self))
		guard let resourcePath = testBundle.resourcePath else { fatalError("Could not set up FileTests" )}
		let resourceFolder = try Folder(path: resourcePath)
		let omoriFile = try resourceFolder.file(named: "lssTestFile.lss")
		let tempPath = FileManager.default.temporaryDirectory.path
		let tempFolder = try Folder(path: tempPath)
		if let existingFile = try? tempFolder.file(named: "lssTestFile.lss") {
			try existingFile.delete()
		}
		return try omoriFile.copy(to: tempFolder)
	}

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
//        continueAfterFailure = false
		let app = XCUIApplication()
//        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
		app.launch()
		for i in 0..<app.windows.count {
			let window = app.windows.element(boundBy: i)
			window.typeKey("w", modifierFlags:.command)
			//untitledWindow.buttons[XCUIIdentifierCloseWindow].click() should work too
			if window.buttons["Save"].exists{
				window.buttons["Save"].click()
			}
			if window.buttons["Replace"].exists {
				window.buttons["Replace"].click()
			}
		}

        // In UI tests it’s important to set the initial state required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	func timeString(for row: Int, table: XCUIElement) -> String {
		let string = table.tableRows.element(boundBy: row).cells.element(boundBy: 2).staticTexts.firstMatch.value as! String
		return string
	}
	
	private func saveLSS(window omoriLssWindow: XCUIElement, waitTime: TimeInterval = 5) -> [String] {
		let table = omoriLssWindow.tables.firstMatch
		
		var timeStrings = [String]()
		
		omoriLssWindow/*@START_MENU_TOKEN@*/.buttons["StartTimer"]/*[[".buttons[\"Start\"]",".buttons[\"Start Time\"]",".buttons[\"StartTimer\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
		let splitButton = omoriLssWindow.children(matching: .button)["Split"]
		waitInTest(for: waitTime)
		
		splitButton.click()
		waitInTest(for: waitTime)
		timeStrings.append(timeString(for: 0, table: table))
		splitButton.click()
		waitInTest(for: waitTime)
		timeStrings.append(timeString(for: 1, table: table))
		splitButton.click()
		waitInTest(for: waitTime)
		timeStrings.append(timeString(for: 2, table: table))
		splitButton.click()
		waitInTest(for: waitTime)
		timeStrings.append(timeString(for: 3, table: table))
		omoriLssWindow.buttons["Finish"].click()
		timeStrings.append(timeString(for: 4, table: table))
		
		let menuBarsQuery = XCUIApplication().menuBars
		menuBarsQuery.menuBarItems["File"].click()
		menuBarsQuery/*@START_MENU_TOKEN@*/.menuItems["Save…"]/*[[".menuBarItems[\"File\"]",".menus.menuItems[\"Save…\"]",".menuItems[\"Save…\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		menuBarsQuery.menuBarItems["Splitter"].click()
		return timeStrings
	}
	
	private func checkLoadLSS(window omoriLssWindow: XCUIElement, timeStrings: [String]) {
		let table = omoriLssWindow.tables.firstMatch
		let rows = table.tableRows
		
		for i in 0..<rows.count {
			XCTAssert(timeStrings[i] == timeString(for: i, table: table))
		}
	}

	func testSaveLoadLSS() throws {
		let editableFile = try setupEditableFile()
		
		for i in (1...5).reversed() {
			let app = XCUIApplication()
			app.launchEnvironment = ["openFile": editableFile.path]
			app.launch()
			
			var omoriLssWindow = app.windows["lssTestFile.lss"].firstMatch
			let timeStrings = saveLSS(window: omoriLssWindow, waitTime: TimeInterval(i))
			
			app.terminate()
			
			let app2 = XCUIApplication()
			app2.launchEnvironment = ["openFile": editableFile.path]
			app2.launch()
			omoriLssWindow = XCUIApplication().windows["lssTestFile.lss"]
			checkLoadLSS(window: omoriLssWindow, timeStrings: timeStrings)
			app2.terminate()
		}
		
		
		
	}
	
	func waitInTest(for timeout: TimeInterval) {
		let _ = XCTWaiter.wait(for: [.init(description: "Waiting Expectation...")], timeout: timeout)
	}

}
