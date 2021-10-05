//
//  MockWeatherRepository.swift
//  Weather Nab UI Test Host
//
//  Created by Huy Nguyen on 10/4/21.
//

import Foundation
import RxSwift

private enum MockResponsePayload: Decodable {
    case dailyForecastReport(DailyForecastReport)
    case error(ForecastError)
}

private struct MockResponse: Decodable {
    let query: String
    let payload: MockResponsePayload
}

class MockWeatherRepository: WeatherRepository {
    private let responses: [MockResponse]
    private let delay: RxTimeInterval
    
    init(delay: Int) {
        self.delay = .seconds(delay)
        
        let url = Bundle.main.url(forResource: "MockWeatherRepositoryResponse", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        self.responses = try! decoder.decode([MockResponse].self, from: data)
    }
    
    func dailyForecastReport(with params: ForecastParams) -> Observable<DailyForecastReport> {
        let response = responses.first {
            $0.query.caseInsensitiveCompare(params.query) == .orderedSame
        }
        
        guard let response = response else {
            return Observable
                .just(())
                .delay(delay, scheduler: MainScheduler.asyncInstance)
                .flatMapLatest { Observable.error(ForecastError.unknown) }
        }
        
        switch response.payload {
        case let .dailyForecastReport(dailyForecastReport):
            return Observable
                .just(dailyForecastReport)
                .delay(delay, scheduler: MainScheduler.asyncInstance)
            
        case let .error(error):
            return Observable
                .just(())
                .delay(delay, scheduler: MainScheduler.asyncInstance)
                .flatMapLatest { Observable.error(error) }
        }
    }
}
