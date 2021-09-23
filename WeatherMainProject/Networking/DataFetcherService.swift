//
//  DataFetcherService.swift
//  Papa Johns Codes
//
//  Created by Aleksei Elin on 19.09.2019.
//  Copyright © 2019 Aleksei Elin. All rights reserved.
//

import Foundation
import CoreLocation

class DataFetcherService {
    var networkDataFetcher: DataFetcher
    
    init(networkDataFetcher: DataFetcher = NetworkDataFetcher()) {
        self.networkDataFetcher = networkDataFetcher
    }

    func getWeatherDays(cnt: String, cityName: String, completion: @escaping (WeatherDaysResponse?) -> Void) {
        let urlForCodes = "https://api.openweathermap.org/data/2.5/forecast/daily"
        let params: [String : String] = ["q"     : cityName,
                                         "appid" : "64b33b91272f06dc53f406df2349ea19",
                                         "lang"  : "ru",
                                         "units" : "metric",
                                         "cnt" : cnt]
        
        networkDataFetcher.getGenericJSONDataWith(type: .GET, urlString: urlForCodes, parameters: params, response: completion)
        
    }
    
    func getWeatherDaysWithLL(forLatitude latitude: CLLocationDegrees, longitude: CLLocationDegrees, cnt: String, completion: @escaping (WeatherDaysResponse?) -> Void) {
        let urlForCodes = "https://api.openweathermap.org/data/2.5/forecast/daily"
        let params: [String : String] = ["lat"     : "\(latitude)",
                                         "lon"     : "\(longitude)",
                                         "appid" : "64b33b91272f06dc53f406df2349ea19",
                                         "lang"  : "ru",
                                         "units" : "metric",
                                         "cnt" : cnt]
        
        networkDataFetcher.getGenericJSONDataWith(type: .GET, urlString: urlForCodes, parameters: params, response: completion)
        
    }
    
}
