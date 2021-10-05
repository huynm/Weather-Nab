//
//  WeatherRepository.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Alamofire
import Foundation
import RxSwift

enum ForecastType {
    case daily
}

enum ForecastError: String, Error, Decodable {
    case cityNotFound
    case unknown
}

struct ForecastParams {
    let language: String?
    let forecaseType: ForecastType
    let query: String
    let numberOfDays: Int
    let measurementUnit: MeasurementUnit
}

protocol WeatherRepository {
    /// Will emit ``ForecastError`` on error
    func dailyForecastReport(with params: ForecastParams) -> Observable<DailyForecastReport>
}
