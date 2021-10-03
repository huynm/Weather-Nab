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

enum DailyForecastAlert: Equatable {
    case minimumQueryLength(Int)
    
    static func ==(lhs: DailyForecastAlert, rhs: DailyForecastAlert) -> Bool {
        switch (lhs, rhs) {
        case let (.minimumQueryLength(lhsLength), .minimumQueryLength(rhsLength)):
            return lhsLength == rhsLength
        }
    }
}

enum DailyForecastViewState: Equatable {
    case forecastReport(DailyForecastReport)
    case error(ForecastError)
    
    static func ==(lhs: DailyForecastViewState, rhs: DailyForecastViewState) -> Bool {
        switch (lhs, rhs) {
        case let (.forecastReport(lhsReport), .forecastReport(rhsReport)):
            return lhsReport == rhsReport
        case let (.error(lhsError), .error(rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
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
    
    init(initialQuery: String, repository: WeatherRepository) {
        let minimumQueryLength = 3
        let isLoading = BehaviorRelay(value: false)
        
        let fetchForecastTrigger = Observable.merge(
            viewDidLoadRelay.map { initialQuery },
            didSubmitQueryRelay.asObservable()
        )
        let forecasts = fetchForecastTrigger
            .filter {
                ($0?.trimmed.count ?? 0) >= minimumQueryLength
            }.compactMap {
                $0
            }.flatMapLatest { query -> Observable<Event<DailyForecastReport>> in
                let params = ForecastParams(
                    forecaseType: .daily,
                    query: query.trimmed,
                    numberOfDays: 7,
                    measurementUnit: .metric
                )
                return repository
                    .dailyForecastReport(with: params)
                    .do(onNext: { _ in
                        isLoading.accept(false)
                    }, onError: { _ in
                        isLoading.accept(false)
                    }, onSubscribe: {
                        isLoading.accept(true)
                    })
                    .materialize()
            }
        
        self.isLoading = isLoading.distinctUntilChanged()
        
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
            .distinctUntilChanged()
        
        self.initialQuery = .just(initialQuery)
        
        self.showAlert = didSubmitQueryRelay
            .compactMap {
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
