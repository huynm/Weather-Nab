//
//  MockWeatherRepository.swift
//  Weather NabTests
//
//  Created by Huy Nguyen on 10/3/21.
//

import Foundation
import RxSwift
@testable import Weather_Nab
import RxTest

class MockWeatherRepository: WeatherRepository {
    let scheduler: TestScheduler
    
    var delay: RxTimeInterval = .never
    var dailyForecasts: [DailyForecast] = []
    var queryToErrorMap: [String?: ForecastError] = [:]
    
    init(scheduler: TestScheduler) {
        self.scheduler = scheduler
    }
    
    func dailyForecastReport(with params: ForecastParams) -> Observable<DailyForecastReport> {
        if queryToErrorMap.keys.contains(params.query) {
            return Observable
                .just(())
                .delay(delay, scheduler: scheduler)
                .flatMapLatest { Observable.error(self.queryToErrorMap[params.query]!) }
        }
        return Observable
            .just(DailyForecastReport(city: params.query, forecasts: dailyForecasts))
            .delay(delay, scheduler: scheduler)
    }
}
