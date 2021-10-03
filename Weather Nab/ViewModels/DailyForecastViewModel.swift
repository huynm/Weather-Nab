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
    func didSubmitQuery(_ query: String?)
}

protocol DailyForecastViewModelOutputs {
    var viewState: Observable<DailyForecastViewState> { get }
    var isLoading: Observable<Bool> { get }
    var initialQuery: Observable<String> { get }
    var showAlert: Observable<DailyForecastAlert> { get }
}

protocol DailyForecastViewModelProtocol {
    var inputs: DailyForecastViewModelInputs { get }
    var outputs: DailyForecastViewModelOutputs { get }
}

enum DailyForecastAlert {
    case minimumQueryLength(Int)
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
    let showAlert: Observable<DailyForecastAlert>
    
    init(repository: WeatherRepository) {
        let initialQuery = "Saigon"
        let minimumQueryLength = 3
        let isLoading = BehaviorRelay(value: true)
        
        let fetchForecastsTrigger = Observable.merge(
            viewDidLoadRelay.map { initialQuery },
            didSubmitQueryRelay.asObservable()
        )
        let forecasts = fetchForecastsTrigger
            .filter { ($0?.trimmed.count ?? 0) >= minimumQueryLength }
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
        
        self.showAlert = didSubmitQueryRelay.compactMap {
            if ($0?.count ?? 0) < minimumQueryLength {
                return .minimumQueryLength(minimumQueryLength)
            }
            return nil
        }
    }
    
    private let viewDidLoadRelay = PublishRelay<Void>()
    func viewDidLoad() {
        viewDidLoadRelay.accept(())
    }
    
    private let didSubmitQueryRelay = PublishRelay<String?>()
    func didSubmitQuery(_ query: String?) {
        didSubmitQueryRelay.accept(query)
    }
}
