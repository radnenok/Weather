//
//  OtherDayInfoTableViewCell.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 29.08.21.
//

import UIKit
import SDWebImage


final class OtherDayInfoTableViewCell: UITableViewCell {

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var minTemLabel: UILabel!
    @IBOutlet private weak var maxTemLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!

    override class func description() -> String {
        return "OtherDayInfoTableViewCell"
    }
    
   
    func setupCellOtherDays(model: OtherDayModelCell, tempC: Bool) {
        dateLabel.text = model.date
        minTemLabel.text = "\(tempC ? model.minTemp : model.minTempF)"
        maxTemLabel.text = "\(tempC ? model.maxtemp : model.maxtempF)"
        
//
//        iconImageView.sd_setImage(with: URL(string: model.icon), completed: nil)
//
//        iconImageView.sd_setImage(with: URL(string: model.icon),
//                                 placeholderImage: nil,
//                                 options: .avoidAutoSetImage, context: nil)
    }
    
}
