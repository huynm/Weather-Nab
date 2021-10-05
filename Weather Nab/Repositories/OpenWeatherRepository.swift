//
//  OpenWeatherRepository.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Alamofire
import Foundation
import RxSwift

/** Cache response in a day only, because next day will have new forecasts */
private class OpenWeatherURLCache: URLCache, CachedResponseHandler {
    private static let dateKey = "date"
    
    func dataTask(_ task: URLSessionDataTask, willCacheResponse response: CachedURLResponse, completion: @escaping (CachedURLResponse?) -> Void) {
        getCachedResponse(for: task) { cachedResponse in
            guard cachedResponse == nil else {
                completion(nil)
                return
            }
            completion(CachedURLResponse(
               response: response.response,
               data: response.data,
               userInfo: [Self.dateKey: Date()],
               storagePolicy: .allowed
           ))
        }
    }
    
    override func getCachedResponse(for dataTask: URLSessionDataTask, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        super.getCachedResponse(for: dataTask) { [unowned self] response in
            guard let response = response else {
                completionHandler(nil)
                return
            }
            
            guard let cachedDate = response.userInfo?[Self.dateKey] as? Date,
                  cachedDate >= Date.startOfToday else
            {
                removeCachedResponse(for: dataTask)
                completionHandler(nil)
                return
            }
            
            completionHandler(response)
        }
    }
}

class OpenWeatherRepository: WeatherRepository {
    private static let cacheCapacity = 10 * 1024 * 1024 // 10MB
    private static let appIDParamName = "appid"
    private static let measurementUnitParamName = "units"
    private static let numberOfDaysParamName = "cnt"
    private static let queryParamName = "q"
    
    private let session: Session
    private let appId: String
    private let baseURLComponents: URLComponents
    
    init(appId: String) {
        self.appId = appId
        
        let cache = OpenWeatherURLCache(memoryCapacity: Self.cacheCapacity, diskCapacity: Self.cacheCapacity)
        let configuration = URLSessionConfiguration.af.default
        configuration.urlCache = cache
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        self.session = Session(
            configuration: configuration,
            cachedResponseHandler: cache
        )
        
        if let urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/") {
            self.baseURLComponents = urlComponents
        } else {
            fatalError("Invalid URL")
        }
    }
    
    func dailyForecastReport(with params: ForecastParams) -> Observable<DailyForecastReport> {
        let url = buildForecastURL(with: params)
        let session = session
        let request = session.request(url)
        
        return Observable.create { observer in
            request.responseData {
                switch $0.result {
                case .success(let data):
                    do {
                        let weather = try Self.parseForecaseResponseData(
                            data,
                            statusCode: $0.response?.statusCode,
                            params: params
                        )
                        observer.onNext(weather)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                case .failure:
                    observer.onError(ForecastError.unknown)
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    private static func parseForecaseResponseData(
        _ data: Data,
        statusCode: Int?,
        params: ForecastParams
    ) throws -> DailyForecastReport {
        guard let statusCode = statusCode else {
            throw ForecastError.unknown
        }
        
        guard statusCode < 400 else {
            switch statusCode {
            case 404:
                throw ForecastError.cityNotFound
            default:
                throw ForecastError.unknown
            }
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        let response = try decoder.decode(DailyForecastResponse.self, from: data)
        let forecasts = response.list.map {
            DailyForecast(
                date: $0.dt,
                averageTemperature: ($0.temp.max + $0.temp.min) / 2,
                measurementUnit: params.measurementUnit,
                pressure: $0.pressure,
                humidity: $0.humidity,
                description: $0.weather.first?.description ?? ""
            )
        }
        
        return DailyForecastReport(city: response.city.name, forecasts: forecasts)
    }
    
    private func buildForecastURL(with params: ForecastParams) -> URL {
        var urlComponents = baseURLComponents
        
        let forecastType: String
        switch params.forecaseType {
        case .daily:
            forecastType = "daily"
        }
        
        let measurementUnit: String
        switch params.measurementUnit {
        case .metric:
            measurementUnit = "metric"
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: Self.queryParamName, value: params.query),
            URLQueryItem(name: Self.appIDParamName, value: appId),
            URLQueryItem(name: Self.numberOfDaysParamName, value: "\(params.numberOfDays)"),
            URLQueryItem(name: Self.measurementUnitParamName, value: measurementUnit)
        ]
        
        guard let url = urlComponents.url?
                .appendingPathComponent("forecast")
                .appendingPathComponent(forecastType) else {
                    fatalError("Invalid URL")
                }
        
        return url
    }
}

private struct DailyForecastResponse: Decodable {
    let list: [RawDailyForecast]
    let city: DailyForecastCity
}

private struct DailyForecastCity: Decodable {
    let name: String
}

private struct DailyForecastTemperature: Decodable {
    let min: Double
    let max: Double
}

private struct DailyForecastWeather: Decodable {
    let description: String
}

// The Raw prefix is to prevent naming conflict with DailyForecast
private struct RawDailyForecast: Decodable {
    let dt: Date
    let temp: DailyForecastTemperature
    let pressure: Int
    let humidity: Int
    let weather: [DailyForecastWeather]
}
