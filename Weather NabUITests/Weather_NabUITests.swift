//
//  Weather_NabUITests.swift
//  Weather NabUITests
//
//  Created by Huy Nguyen on 10/2/21.
//

import XCTest

class Weather_NabUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
        
        let table = app.tables[AccessibilityIdentifier.dailyForecastTableView]
        let spinner = app.activityIndicators[AccessibilityIdentifier.dailyForecastSpinner]
        let searchBar = app.searchFields.firstMatch
        
        // Search field showing initial query
        XCTAssertEqual(searchBar.value as? String, "Saigon")
        // Show loading state
        XCTAssertTrue(spinner.exists)
        
        // Show forecast
        XCTAssertTrue(table.waitForExistence(timeout: 5))
        XCTAssertEqual(table.children(matching: .cell).count, 10)
        
        let dateLabel = table.children(matching: .cell).allElementsBoundByIndex[0].staticTexts[AccessibilityIdentifier.dailyForecastDateLabel]
        XCTAssertEqual(table.children(matching: .cell).count, 10)
        XCTAssertEqual(dateLabel.label, "Date: Sun, 03 Oct 2021")
        XCTAssertFalse(spinner.exists)
    }
}
