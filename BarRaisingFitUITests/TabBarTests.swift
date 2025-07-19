//
//  TabBarTests.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/18/25.
//

import XCTest


final class TabBarTests: XCTestCase {
    
    func testTabBarNavigation() {
        let app = XCUIApplication()
        app.launch()
        
        // Tap on "Activity" tab
        app.tabBars.buttons["Activity"].tap()
        XCTAssertTrue(app.navigationBars["Activity"].exists)
        
        // Tap on "Settings" tab
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].exists)
    }
}
