//
//  BarRaisingFitUITests.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/18/25.
//

import XCTest

final class BarRaisingFitUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testTabBarSwitching() throws {
        let activityTab = app.buttons["Activity"]
        XCTAssertTrue(activityTab.exists)
        activityTab.tap()
        XCTAssertTrue(app.staticTexts["Activity"].exists)

        let metricsTab = app.buttons["Metrics"]
        XCTAssertTrue(metricsTab.exists)
        metricsTab.tap()
        XCTAssertTrue(app.staticTexts["BarRaisingFitnessApp"].exists)
    }

    func testPullToRefreshOnActivityView() throws {
        app.buttons["Activity"].tap()

        let firstCell = app.staticTexts["Steps"]
        XCTAssertTrue(firstCell.waitForExistence(timeout: 3))

        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let finish = start.withOffset(CGVector(dx: 0, dy: 300))
        start.press(forDuration: 0.1, thenDragTo: finish)

        // Optional: Wait for data to reload or check console via OSLog
    }
}
