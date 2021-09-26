//
//  ModelManager.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 29.08.21.
//

import Foundation

protocol OtherDayData {
    var date: String { get }
    var minTemp: Int { get }
    var maxtemp: Int { get }
    var icon: String { get }
}


struct OtherInfoModel {
    let title: String
    let data: String
}

struct OtherDayModel: OtherDayData {
    var date: String
    var minTemp: Int
    var maxtemp: Int
    var minTempF: Int
    var maxtempF: Int
    var icon: String
    var pop: String
}

struct CurrentDayModel {
    let city: String
    let country: String
    let minTemp: Int
    let maxtemp: Int
    let minTempF: Int
    let maxTempF: Int
    let currentTemp: Int
    let currentTempF: Int
    let description: String
    let timeZone: TimeZone
    let feelsLike: Int
    let feelsLikeF: Int
  
}

enum CellDataType {
    case otherDays(days: [OtherDayModel])
    case otherInfo(info: [OtherInfoModel])
    case maps(name: String)
}

struct CityWeather {
   let lat: Double
    let lon: Double
    let placeId: String
    let mainInfo: CurrentDayModel
    let cityData: [CellDataType]
}

