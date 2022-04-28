//
//  SplitterUITests.swift
//  SplitterUITests
//
//  Created by Michael Berk on 3/23/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import XCTest
@testable import Splitter
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

class SplitterUITests: XCTestCase {
	
	var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

		app = XCUIApplication()
		app.launch()
		
		
		
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
	
	func onlyOneWindow() {
		let app = XCUIApplication()
		let windowQuery = app.windows
		for i in windowQuery.allElementsBoundByIndex {
			i.typeKey("w", modifierFlags: .command)
		}
		
		newWindow()
	}
	func newWindow() {
		let menuBarsQuery = app.menuBars
		menuBarsQuery.menuBarItems["File"].click()
		menuBarsQuery/*@START_MENU_TOKEN@*/.menuItems["New"]/*[[".menuBarItems[\"File\"]",".menus.menuItems[\"New\"]",".menuItems[\"New\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
	}
	var windows: [XCUIElement] {
		return app.windows.allElementsBoundByIndex
	}
	var windowCount: Int {
		return windows.count
	}
	
	var mainWindow: XCUIElement? {
		let app = XCUIApplication()
		let windowQuery = app.windows
		let i = windowQuery.allElementsBoundByIndex
		return i.first
	}

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	
	func testChangeTextColor() {
		
		let app = XCUIApplication()
		let untitledWindow = app.windows["Untitled"]
		untitledWindow.buttons["Edit Components"].click()
		
		let popoversQuery = untitledWindow.popovers
		popoversQuery/*@START_MENU_TOKEN@*/.outlines.children(matching: .outlineRow).element(boundBy: 1).staticTexts["General"]/*[[".scrollViews.outlines.children(matching: .outlineRow).element(boundBy: 1)",".cells.staticTexts[\"General\"]",".staticTexts[\"General\"]",".outlines.children(matching: .outlineRow).element(boundBy: 1)"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.click()
		popoversQuery.children(matching: .button).matching(identifier: "Reset").element(boundBy: 1).click()
		popoversQuery.colorWells["rgb 1 1 1 1"].click()
		let colorsWindow = app.windows["Colors"]
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Orchid"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Orchid\"]",".radioButtons[\"Orchid\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Teal"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Teal\"]",".radioButtons[\"Teal\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Turquoise"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Turquoise\"]",".radioButtons[\"Turquoise\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Ice"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Ice\"]",".radioButtons[\"Ice\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Bubblegum"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Bubblegum\"]",".radioButtons[\"Bubblegum\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Magenta"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Magenta\"]",".radioButtons[\"Magenta\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Clover"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Clover\"]",".radioButtons[\"Clover\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()

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

