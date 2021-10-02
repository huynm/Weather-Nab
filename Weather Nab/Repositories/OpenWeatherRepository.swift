//
//  OpenWeatherRepository.swift
//  Weather Nab
//
//  Created by Huy Nguyen on 10/2/21.
//

import Alamofire
import Foundation
import RxSwift

class OpenWeatherRepository: WeatherRepository {
    private static let appIDParamName = "appid"
    private static let measurementUnitParamName = "units"
    private static let numberOfDaysParamName = "cnt"
    private static let queryParamName = "q"
    
    private let session: Session
    private let appId: String
    private let baseURLComponents: URLComponents
    
    init(appId: String) {
        self.appId = appId
        self.session = Alamofire.AF
        
        if let urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/") {
            self.baseURLComponents = urlComponents
        } else {
            fatalError("Invalid URL")
        }
    }
    
    func forecast(with params: ForecastParams) -> Observable<[Weather]> {
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
    ) throws -> [Weather] {
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
        
        let response = try decoder.decode(ForecastResponse.self, from: data)
        return response.list.map {
            Weather(
                date: $0.dt,
                avgTemperature: ($0.temp.max + $0.temp.min) / 2,
                measurementUnit: params.measurementUnit,
                pressure: $0.pressure,
                humidity: $0.humidity,
                description: $0.weather.first?.description ?? ""
            )
        }
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
        case .imperial:
            measurementUnit = "imperial"
        case .metric:
            measurementUnit = "metric"
        case .standard:
            measurementUnit = "standard"
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

private struct ForecastResponse: Decodable {
    let list: [Forecast]
}

private struct ForecastTemperature: Decodable {
    let min: Float
    let max: Float
}

private struct ForecastWeather: Decodable {
    let description: String
}

private struct Forecast: Decodable {
    let dt: Date
    let temp: ForecastTemperature
    let pressure: Int
    let humidity: Int
    let weather: [ForecastWeather]
}
