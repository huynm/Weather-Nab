//
//  DailyForecastUITests.swift
//  Weather NabUITests
//
//  Created by Huy Nguyen on 10/2/21.
//

import XCTest

class DailyForecastUITests: XCTestCase {
    private var app: XCUIApplication!
    private var searchBar: XCUIElement!
    private var messageLabel: XCUIElement!
    private var tableView: XCUIElement!
    private var spinner: XCUIElement!
    private var language: String!
    private var weatherRepositoryDelay: TimeInterval!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        weatherRepositoryDelay = 1
        language = "en"
        app = XCUIApplication()
        app.launchArguments += ["-WeatherRepositoryDelay", "\(weatherRepositoryDelay!)"]
        app.launchArguments += ["-AppleLanguages", "(\(language!))"]
        
        searchBar = app.searchFields.firstMatch
        messageLabel = app.staticTexts[AccessibilityIdentifier.dailyForecastMessageLabel]
        tableView = app.tables[AccessibilityIdentifier.dailyForecastTableView]
        spinner = app.activityIndicators[AccessibilityIdentifier.dailyForecastSpinner]
    }
    
    func testInitialState() throws {
        app.launch()
        
        XCTAssertFalse(tableView.exists)
        XCTAssertFalse(spinner.exists)
        XCTAssertEqual(
            messageLabel.label,
            localizedString("dailyForecast.initialMessage", language: language)
        )
    }
    
    func testSubmitQuerySuccess() throws {
        app.launch()
        
        searchBar.tap()
        searchBar.typeText("melbourne")
        app.keyboards.buttons["search"].tap()
        
        XCTAssertTrue(spinner.exists)
        XCTAssertFalse(messageLabel.exists)
        XCTAssertFalse(tableView.exists)
        
        XCTAssertTrue(tableView.waitForExistence(timeout: weatherRepositoryDelay))
        XCTAssertFalse(spinner.exists)
        XCTAssertFalse(messageLabel.exists)
        
        let cells = tableView.children(matching: .cell).allElementsBoundByIndex
        XCTAssertEqual(cells.count, 2)
        assertForecast(
            cells[0],
            date: "Mon, 04 Oct 2021",
            averageTemperature: "25°C",
            humidity: "90%",
            pressure: "1000",
            description: "Good weather"
        )
        assertForecast(
            cells[1],
            date: "Tue, 05 Oct 2021",
            averageTemperature: "30°C",
            humidity: "95%",
            pressure: "1100",
            description: "Still good weather"
        )
    }
    
    func testSubmitQueryFailureCityNotFound() throws {
        app.launch()
        
        searchBar.tap()
        searchBar.typeText("atlantis")
        app.keyboards.buttons["search"].tap()
        
        XCTAssertTrue(spinner.exists)
        XCTAssertFalse(messageLabel.exists)
        XCTAssertFalse(tableView.exists)
        
        XCTAssertTrue(messageLabel.waitForExistence(timeout: weatherRepositoryDelay))
        XCTAssertEqual(messageLabel.label, localizedString("dailyForecast.error.cityNotFound", language: language))
        XCTAssertFalse(spinner.exists)
        XCTAssertFalse(tableView.exists)
    }
    
    func testSubmitQueryFailureUnknowError() throws {
        app.launch()
        
        searchBar.tap()
        searchBar.typeText("loremipsum")
        app.keyboards.buttons["search"].tap()
        
        XCTAssertTrue(spinner.exists)
        XCTAssertFalse(messageLabel.exists)
        XCTAssertFalse(tableView.exists)
        
        XCTAssertTrue(messageLabel.waitForExistence(timeout: weatherRepositoryDelay))
        XCTAssertEqual(messageLabel.label, localizedString("dailyForecast.error.unknown", language: language))
        XCTAssertFalse(spinner.exists)
        XCTAssertFalse(tableView.exists)
    }
    
    func testSubmitQueryLength1() throws {
        app.launch()
        
        searchBar.tap()
        searchBar.typeText("a")
        app.keyboards.buttons["search"].tap()
        
        let title = localizedString("alert.minimumQueryLength.title", language: language)
        let message = String.localizedStringWithFormat(
            localizedString("alert.minimumQueryLength.message", language: language),
            3
        )
        let buttonOK = localizedString("button.ok", language: language)
        XCTAssertTrue(app.alerts.staticTexts[title].exists)
        XCTAssertTrue(app.alerts.staticTexts[message].exists)
        XCTAssertEqual(app.alerts.buttons.count, 1)
        XCTAssertTrue(app.alerts.buttons[buttonOK].exists)
        XCTAssertFalse(tableView.exists)
        XCTAssertFalse(spinner.exists)
        XCTAssertEqual(
            messageLabel.label,
            localizedString("dailyForecast.initialMessage", language: language)
        )
    }
    
    func testSubmitQueryLength2() throws {
        app.launch()
        
        searchBar.tap()
        searchBar.typeText("aa")
        app.keyboards.buttons["search"].tap()
        
        let title = localizedString("alert.minimumQueryLength.title", language: language)
        let message = String.localizedStringWithFormat(
            localizedString("alert.minimumQueryLength.message", language: language),
            3
        )
        let buttonOK = localizedString("button.ok", language: language)
        XCTAssertTrue(app.alerts.staticTexts[title].exists)
        XCTAssertTrue(app.alerts.staticTexts[message].exists)
        XCTAssertEqual(app.alerts.buttons.count, 1)
        XCTAssertTrue(app.alerts.buttons[buttonOK].exists)
        XCTAssertFalse(tableView.exists)
        XCTAssertFalse(spinner.exists)
        XCTAssertEqual(
            messageLabel.label,
            localizedString("dailyForecast.initialMessage", language: language)
        )
    }
    
    func testSubmitQueryLength3() throws {
        app.launch()
        
        searchBar.tap()
        searchBar.typeText("aaa")
        app.keyboards.buttons["search"].tap()
        
        XCTAssertTrue(spinner.exists)
        XCTAssertFalse(messageLabel.exists)
        XCTAssertFalse(tableView.exists)
        
        XCTAssertTrue(messageLabel.waitForExistence(timeout: weatherRepositoryDelay))
        XCTAssertEqual(messageLabel.label, localizedString("dailyForecast.error.unknown", language: language))
        XCTAssertFalse(spinner.exists)
        XCTAssertFalse(tableView.exists)
    }
    
    func testSubmitQueryAllSpaces() throws {
        app.launch()
        
        searchBar.tap()
        searchBar.typeText("   ")
        app.keyboards.buttons["search"].tap()
        
        let title = localizedString("alert.minimumQueryLength.title", language: language)
        let message = String.localizedStringWithFormat(
            localizedString("alert.minimumQueryLength.message", language: language),
            3
        )
        let buttonOK = localizedString("button.ok", language: language)
        XCTAssertTrue(app.alerts.staticTexts[title].exists)
        XCTAssertTrue(app.alerts.staticTexts[message].exists)
        XCTAssertEqual(app.alerts.buttons.count, 1)
        XCTAssertTrue(app.alerts.buttons[buttonOK].exists)
        XCTAssertFalse(tableView.exists)
        XCTAssertFalse(spinner.exists)
        XCTAssertEqual(
            messageLabel.label,
            localizedString("dailyForecast.initialMessage", language: language)
        )
    }
    
    func testSubmitQueryLeadingTrailingSpace() throws {
        app.launch()
        
        searchBar.tap()
        searchBar.typeText("   melbourne   ")
        app.keyboards.buttons["search"].tap()
        
        XCTAssertTrue(spinner.exists)
        XCTAssertFalse(messageLabel.exists)
        XCTAssertFalse(tableView.exists)
        
        XCTAssertTrue(tableView.waitForExistence(timeout: weatherRepositoryDelay))
        XCTAssertFalse(spinner.exists)
        XCTAssertFalse(messageLabel.exists)
        
        let cells = tableView.children(matching: .cell).allElementsBoundByIndex
        XCTAssertEqual(cells.count, 2)
        assertForecast(
            cells[0],
            date: "Mon, 04 Oct 2021",
            averageTemperature: "25°C",
            humidity: "90%",
            pressure: "1000",
            description: "Good weather"
        )
        assertForecast(
            cells[1],
            date: "Tue, 05 Oct 2021",
            averageTemperature: "30°C",
            humidity: "95%",
            pressure: "1100",
            description: "Still good weather"
        )
    }
    
    private func assertForecast(
        _ cell: XCUIElement,
        date: String,
        averageTemperature: String,
        humidity: String,
        pressure: String,
        description: String
    ) {
        XCTAssertEqual(
            cell.staticTexts[AccessibilityIdentifier.dailyForecastDateLabel].label,
            String.localizedStringWithFormat(
                localizedString("dailyForecast.date", language: language),
                date
            )
        )
        XCTAssertEqual(
            cell.staticTexts[AccessibilityIdentifier.dailyForecastAverageTemperatureLabel].label,
            String.localizedStringWithFormat(
                localizedString("dailyForecast.averageTemperature", language: language),
                averageTemperature
            )
        )
        XCTAssertEqual(
            cell.staticTexts[AccessibilityIdentifier.dailyForecastHumidityLabel].label,
            String.localizedStringWithFormat(
                localizedString("dailyForecast.humidity", language: language),
                humidity
            )
        )
        XCTAssertEqual(
            cell.staticTexts[AccessibilityIdentifier.dailyForecastPressureLabel].label,
            String.localizedStringWithFormat(
                localizedString("dailyForecast.pressure", language: language),
                pressure
            )
        )
        XCTAssertEqual(
            cell.staticTexts[AccessibilityIdentifier.dailyForecastDescriptionLabel].label,
            String.localizedStringWithFormat(
                localizedString("dailyForecast.description", language: language),
                description
            )
        )
    }
}
