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
    @IBOutlet private weak var popLabel: UILabel!
    
    override class func description() -> String {
        return "OtherDayInfoTableViewCell"
    }
    
    
    func setupCellOtherDays(model: OtherDayModelCell) {
        dateLabel.text = model.date
        
        minTemLabel.text = "\(model.minTemp)"
        maxTemLabel.text = "\(model.maxtemp)"
        popLabel.text = model.pop
        
        iconImageView.sd_setImage(with: URL(string: model.icon),
                                  placeholderImage: nil,
                                  options: .refreshCached, context: nil)
    }
    
}
