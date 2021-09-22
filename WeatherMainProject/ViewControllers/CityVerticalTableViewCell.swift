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
    
    
    override class func description() -> String {
        return "CityVerticalTableViewCell"
    }
    
    func setupCityVerticalCell(cityTime: String, place: String, temperature: Int) {
        
        cityTimeLabel.text = cityTime
        placeLabel.text = place
        temperatureLabel.text = "\(temperature)°"
        
    }
    
    
}
