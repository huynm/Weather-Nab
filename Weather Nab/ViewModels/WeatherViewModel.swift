//
//  WeatherViewModel.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Foundation
import RxSwift
import RxRelay

protocol WeatherViewModelInputs {
    func viewDidLoad()
}

protocol WeatherViewModelOutputs {
    var weather: Observable<[Weather]> { get }
}

protocol WeatherViewModelProtocol {
    var inputs: WeatherViewModelInputs { get }
    var outputs: WeatherViewModelOutputs { get }
}

class WeatherViewModel:
    WeatherViewModelInputs,
    WeatherViewModelOutputs,
    WeatherViewModelProtocol
{
    var inputs: WeatherViewModelInputs { self }
    var outputs: WeatherViewModelOutputs { self }
    let weather: Observable<[Weather]>
    
    init(repository: WeatherRepository) {
        self.weather = viewDidLoadRelay.flatMapLatest { () -> Observable<[Weather]> in
            let params = ForecastParams(
                forecaseType: .daily,
                query: "saigon",
                numberOfDays: 7,
                measurementUnit: .metric
            )
            return repository
                .forecast(with: params)
        }
    }
    
    private let viewDidLoadRelay = PublishRelay<Void>()
    func viewDidLoad() {
        viewDidLoadRelay.accept(())
    }
}
