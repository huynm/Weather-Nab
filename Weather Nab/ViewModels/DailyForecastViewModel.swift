//
//  DailyForecastViewModel.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Foundation
import RxSwift
import RxRelay

protocol DailyForecastViewModelInputs {
    func viewDidLoad()
    func queryDidChange(_ query: String?)
}

protocol DailyForecastViewModelOutputs {
    var viewState: Observable<DailyForecastViewState> { get }
    var isLoading: Observable<Bool> { get }
    var initialQuery: Observable<String> { get }
}

protocol DailyForecastViewModelProtocol {
    var inputs: DailyForecastViewModelInputs { get }
    var outputs: DailyForecastViewModelOutputs { get }
}

enum DailyForecastViewState {
    case forecastReport(DailyForecastReport)
    case error(ForecastError)
}

class DailyForecastViewModel:
    DailyForecastViewModelInputs,
    DailyForecastViewModelOutputs,
    DailyForecastViewModelProtocol
{
    var inputs: DailyForecastViewModelInputs { self }
    var outputs: DailyForecastViewModelOutputs { self }
    
    let isLoading: Observable<Bool>
    let viewState: Observable<DailyForecastViewState>
    let initialQuery: Observable<String>
    
    init(repository: WeatherRepository) {
        let initialQuery = "Saigon"
        let isLoading = BehaviorRelay(value: true)
        
        let fetchForecastsTrigger = Observable.merge(
            viewDidLoadRelay.map { initialQuery },
            queryDidChangeRelay.asObservable()
        )
        let forecasts = fetchForecastsTrigger
            .filter { $0?.trimmed.isEmpty == false }
            .compactMap { $0 }
            .flatMapLatest { query -> Observable<Event<DailyForecastReport>> in
                let params = ForecastParams(
                    forecaseType: .daily,
                    query: query,
                    numberOfDays: 7,
                    measurementUnit: .metric
                )
                return repository
                    .dailyForecastReport(with: params)
                    .do(onSubscribed: {
                        isLoading.accept(true)
                    }, onDispose: {
                        isLoading.accept(false)
                    })
                    .materialize()
            }
            .share()
        
        self.isLoading = isLoading.asObservable()
        
        self.viewState = forecasts
            .map { event in
                switch event {
                case let .next(forecastReport):
                    return .forecastReport(forecastReport)
                case let .error(error):
                    guard let forecastError = error as? ForecastError else {
                        return .error(.unknown)
                    }
                    return .error(forecastError)
                default:
                    return nil
                }
            }
            .compactMap { $0 }
        
        self.initialQuery = Observable.just(initialQuery)
    }
    
    private let viewDidLoadRelay = PublishRelay<Void>()
    func viewDidLoad() {
        viewDidLoadRelay.accept(())
    }
    
    private let queryDidChangeRelay = PublishRelay<String?>()
    func queryDidChange(_ query: String?) {
        queryDidChangeRelay.accept(query)
    }
}
