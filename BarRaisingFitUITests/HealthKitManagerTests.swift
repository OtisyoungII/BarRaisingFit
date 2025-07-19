//
//  HealthKitManagerTests.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/18/25.
//

import XCTest
@testable import BarRaisingFit

final class HealthKitManagerTests: XCTestCase {

    func testFetchStepCountReturnsPositive() {
        let expectation = self.expectation(description: "Fetch steps")

        HealthKitManager.shared.fetchStepCount { value in
            XCTAssertNotNil(value)
            XCTAssertGreaterThanOrEqual(value ?? -1, 0)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
