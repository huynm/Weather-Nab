//
//  DateFormatter+Default.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/3/21.
//

import Foundation

extension DateFormatter {
    static var `default`: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy"
        return formatter
    }
}
