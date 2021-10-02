//
//  SceneCoordinator.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Foundation
import UIKit

enum AppRoute {
    case weather
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
        case .weather:
            let weatherViewModel = WeatherViewModel(repository: environment.weatherRepository)
            window?.rootViewController = WeatherViewController(viewModel: weatherViewModel)
            window?.makeKeyAndVisible()
        }
    }
}
