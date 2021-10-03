//
//  NumberFormatter+Degree.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Foundation

extension NumberFormatter {
    static var percentageFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        formatter.multiplier = 1
        return formatter
    }
}
