//
//  CityVerticalTableViewCell.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 10.08.21.
//

import UIKit

final class CityVerticalTableViewCell: UITableViewCell {

    @IBOutlet private weak var cityTimeLabel: UILabel!
    @IBOutlet private weak var placeLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    
    private var tempC: Bool = true
    
    override class func description() -> String {
        return "CityVerticalTableViewCell"
    }
    
    func setupCityVerticalCell(cityTime: String, place: String, temperature: Int, timeZone: TimeZone, tempC: Bool) {
        
        if cityTime == "" {
            let date = NSDate()
            let time = DateFormatter.configureDataStringWihTymeZoneFrom(date: date as Date, dateFormat: DateFormat.timeFull, timeZone: timeZone)
            cityTimeLabel.text = time
        } else {
            cityTimeLabel.text = cityTime
        }
        
        placeLabel.text = place
        temperatureLabel.text = "\(temperature)°"
        
        self.tempC = tempC
    }
    
    
}
