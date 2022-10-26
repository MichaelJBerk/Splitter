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
	
	func testAddRemoveColumns() {
		let app = XCUIApplication()
		let untitledWindow = app.windows["LongList.split"]
		untitledWindow.buttons["Edit Components"].click()
		let popoversQuery = untitledWindow.popovers
		popoversQuery.outlines["Component List"].staticTexts["Splits Settings"].click()
		
		popoversQuery/*@START_MENU_TOKEN@*/.radioButtons["Columns"]/*[[".radioGroups.radioButtons[\"Columns\"]",".radioButtons[\"Columns\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
		popoversQuery.buttons["add"].click()
		popoversQuery.buttons["remove"].click()
	}
	
	func testEditColumns() {
		
		let longlistSplitWindow = XCUIApplication().windows["LongList.split"]
		longlistSplitWindow.buttons["Edit Components"].click()
		
		let popoversQuery = longlistSplitWindow.popovers
		popoversQuery/*@START_MENU_TOKEN@*/.outlines["Component List"].staticTexts["Splits Settings"]/*[[".scrollViews.outlines[\"Component List\"]",".outlineRows",".cells",".staticTexts[\"Splits\"]",".staticTexts[\"Splits Settings\"]",".outlines[\"Component List\"]"],[[[-1,5,1],[-1,0,1]],[[-1,4],[-1,3],[-1,2,3],[-1,1,2]],[[-1,4],[-1,3],[-1,2,3]],[[-1,4],[-1,3]]],[0,0]]@END_MENU_TOKEN@*/.click()
		popoversQuery/*@START_MENU_TOKEN@*/.radioButtons["Columns"]/*[[".radioGroups.radioButtons[\"Columns\"]",".radioButtons[\"Columns\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
		popoversQuery.children(matching: .scrollView).element(boundBy: 1).outlines.children(matching: .outlineRow).element(boundBy: 3)/*@START_MENU_TOKEN@*/.disclosureTriangles["NSOutlineViewDisclosureButtonKey"]/*[[".cells.disclosureTriangles[\"NSOutlineViewDisclosureButtonKey\"]",".disclosureTriangles[\"NSOutlineViewDisclosureButtonKey\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
		popoversQuery/*@START_MENU_TOKEN@*/.outlines.popUpButtons["Empty"]/*[[".scrollViews.outlines",".outlineRows",".cells.popUpButtons[\"Empty\"]",".popUpButtons[\"Empty\"]",".outlines"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
		popoversQuery/*@START_MENU_TOKEN@*/.outlines.menuItems["Comparison Segment Time"]/*[[".scrollViews.outlines",".outlineRows",".cells",".popUpButtons[\"Empty\"]",".menus.menuItems[\"Comparison Segment Time\"]",".menuItems[\"Comparison Segment Time\"]",".outlines"],[[[-1,6,1],[-1,0,1]],[[-1,5],[-1,4],[-1,3,4],[-1,2,3],[-1,1,2]],[[-1,5],[-1,4],[-1,3,4],[-1,2,3]],[[-1,5],[-1,4],[-1,3,4]],[[-1,5],[-1,4]]],[0,0]]@END_MENU_TOKEN@*/.click()
		popoversQuery.outlines.popUpButtons["Delta"].click()
		popoversQuery/*@START_MENU_TOKEN@*/.outlines.menuItems["Segment Time"]/*[[".scrollViews.outlines",".outlineRows",".cells",".popUpButtons[\"Delta\"]",".menus.menuItems[\"Segment Time\"]",".menuItems[\"Segment Time\"]",".outlines"],[[[-1,6,1],[-1,0,1]],[[-1,5],[-1,4],[-1,3,4],[-1,2,3],[-1,1,2]],[[-1,5],[-1,4],[-1,3,4],[-1,2,3]],[[-1,5],[-1,4],[-1,3,4]],[[-1,5],[-1,4]]],[0,0]]@END_MENU_TOKEN@*/.click()
		popoversQuery/*@START_MENU_TOKEN@*/.outlines.popUpButtons["Contextual"]/*[[".scrollViews.outlines",".outlineRows",".cells.popUpButtons[\"Contextual\"]",".popUpButtons[\"Contextual\"]",".outlines"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
		popoversQuery/*@START_MENU_TOKEN@*/.outlines.menuItems["On Ending Segment"]/*[[".scrollViews.outlines",".outlineRows",".cells",".popUpButtons[\"Contextual\"]",".menus.menuItems[\"On Ending Segment\"]",".menuItems[\"On Ending Segment\"]",".outlines"],[[[-1,6,1],[-1,0,1]],[[-1,5],[-1,4],[-1,3,4],[-1,2,3],[-1,1,2]],[[-1,5],[-1,4],[-1,3,4],[-1,2,3]],[[-1,5],[-1,4],[-1,3,4]],[[-1,5],[-1,4]]],[0,0]]@END_MENU_TOKEN@*/.click()
		popoversQuery/*@START_MENU_TOKEN@*/.outlines.popUpButtons["Default (Personal Best)"]/*[[".scrollViews.outlines",".outlineRows",".cells.popUpButtons[\"Default (Personal Best)\"]",".popUpButtons[\"Default (Personal Best)\"]",".outlines"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
		popoversQuery/*@START_MENU_TOKEN@*/.outlines.menuItems["Balanced PB"]/*[[".scrollViews.outlines",".outlineRows",".cells",".popUpButtons[\"Default (Personal Best)\"]",".menus.menuItems[\"Balanced PB\"]",".menuItems[\"Balanced PB\"]",".outlines"],[[[-1,6,1],[-1,0,1]],[[-1,5],[-1,4],[-1,3,4],[-1,2,3],[-1,1,2]],[[-1,5],[-1,4],[-1,3,4],[-1,2,3]],[[-1,5],[-1,4],[-1,3,4]],[[-1,5],[-1,4]]],[0,0]]@END_MENU_TOKEN@*/.click()
		
		longlistSplitWindow.click()
		longlistSplitWindow.buttons["Start"].click()
		sleep(3)
	}
	
	
}
