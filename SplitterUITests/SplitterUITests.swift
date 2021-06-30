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
	
	///Adds a split and starts the timer
//	func testAddSplitStartTimer() {
//		if windowCount < 1 {newWindow()}
//		mainWindow!.buttons["AddSplit"].click()
//		mainWindow!.buttons["Start"].click()
//
//
//	}
	
	
	func testChangeTextColor() {
		
		let app = XCUIApplication()
		let untitledWindow = app.windows["Untitled"]
		untitledWindow.buttons["action"].click()
		
		let popoversQuery = untitledWindow.popovers
		popoversQuery/*@START_MENU_TOKEN@*/.radioButtons["Appearance"]/*[[".radioGroups.radioButtons[\"Appearance\"]",".radioButtons[\"Appearance\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
//		popoversQuery.groups.containing(.button, identifier:"Reset").children(matching: .colorWell).element(boundBy: 2).click()
//		app.windows["Colors"]/*@START_MENU_TOKEN@*/.radioButtons["Moss"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Moss\"]",".radioButtons[\"Moss\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		
	}

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
	func testSearchMK8() {
		XCUIApplication().windows["Untitled"]/*@START_MENU_TOKEN@*/.tables.containing(.tableColumn, identifier:"ImageColumn").element/*[[".scrollViews",".tables.containing(.tableColumn, identifier:\"Difference\").element",".tables.containing(.tableColumn, identifier:\"CurrentSplit\").element",".tables.containing(.tableColumn, identifier:\"SplitTitle\").element",".tables.containing(.tableColumn, identifier:\"ImageColumn\").element"],[[[-1,4],[-1,3],[-1,2],[-1,1],[-1,0,1]],[[-1,4],[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.typeKey("!", modifierFlags:[.command, .shift])
						
	}
	func testSetTextColors() {
		XCUIApplication().activate()
		let untitledWindow = XCUIApplication().windows["Untitled"]
		untitledWindow/*@START_MENU_TOKEN@*/.buttons["Edit Segments"]/*[[".buttons[\"Edit Segments\"]",".buttons[\"AddSplit\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.click()
		
		let untitledWindow2 = untitledWindow
		untitledWindow2/*@START_MENU_TOKEN@*/.tables.cells.containing(.image, identifier:"Game Controller").element/*[[".scrollViews.tables",".tableRows.cells.containing(.image, identifier:\"Game Controller\").element",".cells.containing(.image, identifier:\"Game Controller\").element",".tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.typeKey(.escape, modifierFlags:[])
		untitledWindow.children(matching: .button).element(boundBy: 0).click()
		
		let popoversQuery = untitledWindow2.popovers
		popoversQuery/*@START_MENU_TOKEN@*/.radioButtons["Colors"]/*[[".radioGroups.radioButtons[\"Colors\"]",".radioButtons[\"Colors\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
		popoversQuery/*@START_MENU_TOKEN@*/.scrollViews/*[[".groups.scrollViews",".scrollViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .colorWell).element(boundBy: 2).click()
		
		let colorsWindow = XCUIApplication().windows["Colors"]
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Orchid"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Orchid\"]",".radioButtons[\"Orchid\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Teal"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Teal\"]",".radioButtons[\"Teal\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Turquoise"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Turquoise\"]",".radioButtons[\"Turquoise\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Ice"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Ice\"]",".radioButtons[\"Ice\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Bubblegum"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Bubblegum\"]",".radioButtons[\"Bubblegum\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Magenta"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Magenta\"]",".radioButtons[\"Magenta\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		colorsWindow/*@START_MENU_TOKEN@*/.radioButtons["Clover"]/*[[".splitGroups",".radioGroups[\"Pencils\"].radioButtons[\"Clover\"]",".radioButtons[\"Clover\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
		
	}
	
}

