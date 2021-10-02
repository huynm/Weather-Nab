//
//  Forecast.swift
//  DailyForecast Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Foundation

enum MeasurementUnit {
    case standard
    case metric
    case imperial
}

struct DailyForecast {
    let date: Date
    let avgTemperature: Float
    let measurementUnit: MeasurementUnit
    let pressure: Int
    let humidity: Int
    let description: String
}

struct DailyForecastReport {
    let city: String
    let forecasts: [DailyForecast]
}