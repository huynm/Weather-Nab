//
//  Forecast.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Foundation

enum ForecastType {
    case daily
}

enum MeasurementUnit {
    case standard
    case metric
    case imperial
}

struct Weather {
    let date: Date
    let avgTemperature: Float
    let measurementUnit: MeasurementUnit
    let pressure: Int
    let humidity: Int
    let description: String
}
