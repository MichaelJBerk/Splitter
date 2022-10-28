//
//  LayoutEditorTests.swift
//  SplitterUITests
//
//  Created by Michael Berk on 10/25/22.
//  Copyright © 2022 Michael Berk. All rights reserved.
//

import XCTest

final class LayoutEditorTests: XCTestCase {
	
	var app: XCUIApplication!
//
//	override func setUp() {
//
//
//	}

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
		app = XCUIApplication()
		app.launchArguments = ["-uiTesting"]
		let testBundle = Bundle(for: type(of: self))
		if let llFile = testBundle.resourceURL?.appendingPathComponent("LongList.split").path {
			app.launchEnvironment = ["openFile": llFile]
		}
		app.launch()
        continueAfterFailure = false
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func setColors() {
		let colorsWindow = app.windows["Colors"]
		colorsWindow.toolbars.buttons["Pencils"].click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Orchid"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Orchid\"]",".radioButtons[\"Orchid\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Teal"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Teal\"]",".radioButtons[\"Teal\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Turquoise"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Turquoise\"]",".radioButtons[\"Turquoise\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Ice"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Ice\"]",".radioButtons[\"Ice\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Bubblegum"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Bubblegum\"]",".radioButtons[\"Bubblegum\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Magenta"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Magenta\"]",".radioButtons[\"Magenta\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Clover"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Clover\"]",".radioButtons[\"Clover\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
	}
	
	func testChangeGeneralColor() {
		
		let app = XCUIApplication()
		let untitledWindow = app.windows["LongList.split"]
		untitledWindow.buttons["Edit Components"].click()
		let popoversQuery = untitledWindow.popovers
		popoversQuery.outlines["Component List"].staticTexts["General Settings"].click()
		
		//Test Setting Background Colors
		let bgColorWell = popoversQuery.colorWells["Background Color Well"]
		bgColorWell.buttons["color picker"].click()
		setColors()
		
		//Test setting text colors
		let textColorWell = popoversQuery.colorWells["Text Color Well"]
		textColorWell.buttons["color picker"].click()
		setColors()
		
	}
	
}
