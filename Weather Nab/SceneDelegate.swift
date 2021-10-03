//
//  SceneDelegate.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import UIKit
import RxSwift

class MockWeatherRepository: WeatherRepository {
    var dailyForecasts: [DailyForecast] = [
        DailyForecast(
            date: Date(),
            avgTemperature: 30,
            measurementUnit: .metric,
            pressure: 1000,
            humidity: 90,
            description: "good weather"
        ),
        DailyForecast(
            date: Date(),
            avgTemperature: 30,
            measurementUnit: .metric,
            pressure: 1000,
            humidity: 90,
            description: "good weather"
        ),
        DailyForecast(
            date: Date(),
            avgTemperature: 30,
            measurementUnit: .metric,
            pressure: 1000,
            humidity: 90,
            description: "good weather"
        ),
        DailyForecast(
            date: Date(),
            avgTemperature: 30,
            measurementUnit: .metric,
            pressure: 1000,
            humidity: 90,
            description: "good weather"
        ),
        DailyForecast(
            date: Date(),
            avgTemperature: 30,
            measurementUnit: .metric,
            pressure: 1000,
            humidity: 90,
            description: "good weather"
        ),
        DailyForecast(
            date: Date(),
            avgTemperature: 30,
            measurementUnit: .metric,
            pressure: 1000,
            humidity: 90,
            description: "good weather"
        ),
        DailyForecast(
            date: Date(),
            avgTemperature: 30,
            measurementUnit: .metric,
            pressure: 1000,
            humidity: 90,
            description: "good weather"
        ),
        DailyForecast(
            date: Date(),
            avgTemperature: 30,
            measurementUnit: .metric,
            pressure: 1000,
            humidity: 90,
            description: "good weather"
        ),
        DailyForecast(
            date: Date(),
            avgTemperature: 30,
            measurementUnit: .metric,
            pressure: 1000,
            humidity: 90,
            description: "good weather"
        ),
        DailyForecast(
            date: Date(),
            avgTemperature: 30,
            measurementUnit: .metric,
            pressure: 1000,
            humidity: 90,
            description: "good weather"
        )
    ]
    var queryToErrorMap: [String?: ForecastError] = [:]
    
    func dailyForecastReport(with params: ForecastParams) -> Observable<DailyForecastReport> {
        if queryToErrorMap.keys.contains(params.query) {
            return Observable
                .just(())
                .delay(.seconds(5), scheduler: MainScheduler.asyncInstance)
                .flatMapLatest { Observable.error(self.queryToErrorMap[params.query]!) }
        }
        return Observable
            .just(DailyForecastReport(city: params.query, forecasts: dailyForecasts))
            .delay(.seconds(5), scheduler: MainScheduler.asyncInstance)
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private var coordinator: SceneCoordinator?
    
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else {
            return
        }
        
        let window = UIWindow(windowScene: scene)
        let coordinator = SceneCoordinator(window: window, environment: .current)
        coordinator.trigger(.dailyForecast)
        self.window = window
        self.coordinator = coordinator
    }
}
