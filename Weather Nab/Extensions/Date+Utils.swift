//
//  Date+Utils.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/5/21.
//

import Foundation

extension Date {
    static var startOfToday: Date {
        let calendar = Calendar.current
        
        var dateComponents = calendar.dateComponents(
            [.day, .month, .year, .hour, .minute, .second],
            from: Date()
        )
        dateComponents.hour = calendar.minimumRange(of: .hour)?.lowerBound ?? 0
        dateComponents.minute = calendar.minimumRange(of: .minute)?.lowerBound ?? 0
        dateComponents.second = calendar.minimumRange(of: .second)?.lowerBound ?? 0
        
        guard let date = calendar.date(from: dateComponents) else {
            fatalError("Invalid date")
        }
        
        return date
    }
}
