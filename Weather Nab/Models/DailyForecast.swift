//
//  Forecast.swift
//  DailyForecast Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Foundation

enum MeasurementUnit {
    case metric
}

struct DailyForecast: Equatable {
    let date: Date
    let avgTemperature: Double
    let measurementUnit: MeasurementUnit
    let pressure: Int
    let humidity: Int
    let description: String
}

struct DailyForecastReport: Equatable {
    let city: String
    let forecasts: [DailyForecast]
}
