//
//  WeatherRepository.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Alamofire
import Foundation
import RxSwift

enum ForecastError: Error {
    case cityNotFound
    case unknown
}

struct ForecastParams {
    let forecaseType: ForecastType
    let query: String
    let numberOfDays: Int
    let measurementUnit: MeasurementUnit
}

protocol WeatherRepository {
    /**
     Will emit ``ForecastError`` on error
     */
    func forecast(with params: ForecastParams) -> Observable<[Weather]>
}
