//
//  Weather_NabTests.swift
//  Weather NabTests
//
//  Created by Huy Nguyen on 10/2/21.
//

import XCTest
import RxTest
import RxSwift
@testable import Weather_Nab

class DailyForecastViewModelTests: XCTestCase {
    var viewModel: DailyForecastViewModel!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var repository: MockWeatherRepository!
    
    var isLoading: TestableObserver<Bool>!
    var viewState: TestableObserver<DailyForecastViewState>!
    var showAlert: TestableObserver<DailyForecastAlert>!
    
    override func setUpWithError() throws {
        scheduler = TestScheduler(initialClock: 0)
        repository = MockWeatherRepository(scheduler: scheduler)
        viewModel = DailyForecastViewModel(initialQuery: "Saigon", repository: repository)
        disposeBag = DisposeBag()
        
        isLoading = scheduler.createObserver(Bool.self)
        viewState = scheduler.createObserver(DailyForecastViewState.self)
        showAlert = scheduler.createObserver(DailyForecastAlert.self)
        
        viewModel.outputs.isLoading
            .bind(to: isLoading)
            .disposed(by: disposeBag)
        
        viewModel.outputs.viewState
            .bind(to: viewState)
            .disposed(by: disposeBag)
        
        viewModel.outputs.showAlert
            .bind(to: showAlert)
            .disposed(by: disposeBag)
    }
    
    func testIsLoading() throws {
        repository.delay = .seconds(5)
        repository.queryToErrorMap = [
            "unknown": .unknown,
            "que": .cityNotFound
        ]
        
        scheduler.createColdObservable([
            .next(10, { self.viewModel.inputs.didSubmitQuery("q") }),
            .next(20, { self.viewModel.inputs.didSubmitQuery("qu") }),
            .next(30, { self.viewModel.inputs.didSubmitQuery("que") }),
            .next(40, { self.viewModel.inputs.didSubmitQuery("query") }),
            .next(41, { self.viewModel.inputs.didSubmitQuery("query") }),
            .next(50, { self.viewModel.inputs.didSubmitQuery("unknown") }),
            .next(60, { self.viewModel.inputs.didSubmitQuery(nil) }),
            .next(70, { self.viewModel.inputs.didSubmitQuery("   ") }),
            .next(80, { self.viewModel.inputs.didSubmitQuery(" query ") }),
        ]).bind { $0() }.disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(isLoading.events, [
            .next(0, false),
            .next(30, true),
            .next(35, false),
            .next(40, true),
            .next(46, false),
            .next(50, true),
            .next(55, false),
            .next(80, true),
            .next(85, false)
        ])
    }
    
    func testViewState() throws {
        let forecasts = [
            DailyForecast(
                date: Date(),
                averageTemperature: 30,
                measurementUnit: .metric,
                pressure: 1000,
                humidity: 90,
                description: "good weather"
            )
        ]
        
        repository.delay = .seconds(5)
        repository.dailyForecasts = forecasts
        repository.queryToErrorMap = [
            "unknown": .unknown,
            "que": .cityNotFound
        ]
        
        scheduler.createColdObservable([
            .next(10, { self.viewModel.inputs.didSubmitQuery("q") }),
            .next(20, { self.viewModel.inputs.didSubmitQuery("qu") }),
            .next(30, { self.viewModel.inputs.didSubmitQuery("que") }),
            .next(40, { self.viewModel.inputs.didSubmitQuery("query") }),
            .next(41, { self.viewModel.inputs.didSubmitQuery("query") }),
            .next(50, { self.viewModel.inputs.didSubmitQuery("unknown") }),
            .next(60, { self.viewModel.inputs.didSubmitQuery(nil) }),
            .next(70, { self.viewModel.inputs.didSubmitQuery("   ") }),
            .next(80, { self.viewModel.inputs.didSubmitQuery(" query ") }),
        ]).bind { $0() }.disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(viewState.events, [
            .next(0, .initial),
            .next(35, .error(.cityNotFound)),
            .next(46, .forecastReport(DailyForecastReport(city: "query", forecasts: forecasts))),
            .next(55, .error(.unknown)),
            .next(85, .forecastReport(DailyForecastReport(city: "query", forecasts: forecasts))),
        ])
    }
    
    func testMinimumQueryLengthAlert() throws {
        let showAlert = scheduler.createObserver(DailyForecastAlert.self)
        
        viewModel.outputs.showAlert
            .bind(to: showAlert)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(10, { [unowned self] in self.viewModel.inputs.didSubmitQuery("q") }),
            .next(20, { [unowned self] in self.viewModel.inputs.didSubmitQuery("qu") }),
            .next(30, { [unowned self] in self.viewModel.inputs.didSubmitQuery("que") }),
            .next(40, { [unowned self] in self.viewModel.inputs.didSubmitQuery("query") }),
            .next(50, { [unowned self] in self.viewModel.inputs.didSubmitQuery(" q ") }),
            .next(60, { [unowned self] in self.viewModel.inputs.didSubmitQuery(" qu ") }),
            .next(70, { [unowned self] in self.viewModel.inputs.didSubmitQuery(" query ") }),
            .next(80, { [unowned self] in self.viewModel.inputs.didSubmitQuery("   ") }),
            .next(90, { [unowned self] in self.viewModel.inputs.didSubmitQuery(nil) }),
        ]).bind { $0() }.disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(showAlert.events, [
            .next(10, DailyForecastAlert.minimumQueryLength(3)),
            .next(20, DailyForecastAlert.minimumQueryLength(3)),
            .next(50, DailyForecastAlert.minimumQueryLength(3)),
            .next(60, DailyForecastAlert.minimumQueryLength(3)),
            .next(80, DailyForecastAlert.minimumQueryLength(3)),
            .next(90, DailyForecastAlert.minimumQueryLength(3)),
        ])
    }
}
