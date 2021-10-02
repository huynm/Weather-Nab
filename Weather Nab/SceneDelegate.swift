//
//  SceneDelegate.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import UIKit

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
