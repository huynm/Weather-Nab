//
//  SceneCoordinator.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Foundation
import UIKit

enum AppRoute {
    case dailyForecast
}

class SceneCoordinator: Coordinator {
    typealias Route = AppRoute
    
    private weak var window: UIWindow?
    private let environment: AppEnvironment
    
    init(window: UIWindow, environment: AppEnvironment) {
        self.window = window
        self.environment = environment
    }
    
    func trigger(_ route: Route) {
        switch route {
        case .dailyForecast:
            let weatherViewModel = DailyForecastViewModel(
                initialQuery: "Saigon",
                repository: environment.weatherRepository
            )
            let weatherViewController = DailyForecastViewController(viewModel: weatherViewModel)
            let weatherNavigationController = UINavigationController(rootViewController: weatherViewController)
            window?.rootViewController = weatherNavigationController
            window?.makeKeyAndVisible()
        }
    }
}
