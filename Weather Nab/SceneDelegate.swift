//
//  SceneDelegate.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else {
            return
        }
        
        window = UIWindow(windowScene: scene)
        window?.rootViewController = WeatherViewController()
        window?.makeKeyAndVisible()
    }
}
