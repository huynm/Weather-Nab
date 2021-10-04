//
//  Forecast.swift
//  DailyForecast Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Foundation

enum MeasurementUnit: String, Decodable {
    case metric
}

struct DailyForecast: Decodable, Equatable {
    let date: Date
    let averageTemperature: Double
    let measurementUnit: MeasurementUnit
    let pressure: Int
    let humidity: Int
    let description: String
}

struct DailyForecastReport: Decodable, Equatable {
    let city: String
    let forecasts: [DailyForecast]
}
