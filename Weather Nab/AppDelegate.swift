//
//  AppDelegate.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let weatherRepository = OpenWeatherRepository(appId: "60c6fbeb4b93ac653c492ba806fc346d")
        let environment = AppEnvironment(weatherRepository: weatherRepository)
        AppEnvironment.setEnvironment(environment)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration{
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }
}
