//
//  LastTableViewCell.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 5.09.21.
//

import UIKit


class LastTableViewCell: UITableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!
    
    override class func description() -> String {
        return "LastTableViewCell"
    }
    
    func setupCell(name: String) {
            
        nameLabel.attributedText = getStringUnderLined(text1: "Погода - \(name). ", text2: "Открыть в Картах")
       
    }
    
}
