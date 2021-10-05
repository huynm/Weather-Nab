//
//  localizedString.swift
//  Weather NabUITests
//
//  Created by Huy Nguyen on 10/4/21.
//

import Foundation

func localizedString(_ key: String, language: String) -> String {
    let bundle = Bundle(for: DailyForecastUITests.self)
    guard let localizationBundlePath = bundle.path(forResource: language, ofType: "lproj"),
          let localizationBundle = Bundle(path: localizationBundlePath) else
    {
        return key
    }
    return NSLocalizedString(key, bundle: localizationBundle, comment: "")
}
