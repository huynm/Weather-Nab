//
//  AppEnvironment.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Foundation

class AppEnvironment {
    static private(set) var current: AppEnvironment!
    
    let weatherRepository: WeatherRepository
    
    init(weatherRepository: WeatherRepository) {
        self.weatherRepository = weatherRepository
    }
    
    static func setEnvironment(_ environment: AppEnvironment) {
        current = environment
    }
}
