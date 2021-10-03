//
//  MeasurementFormatter+Degree.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/3/21.
//

import Foundation

extension MeasurementFormatter {
    static var `default`: MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.unitOptions = .providedUnit
        return formatter
    }
    
    func string(from value: Double, measurementUnit: MeasurementUnit) -> String {
        let unit: Unit
        switch measurementUnit {
        case .metric:
            unit = UnitTemperature.celsius
        }
        return string(from: Measurement(value: value, unit: unit))
    }
}
