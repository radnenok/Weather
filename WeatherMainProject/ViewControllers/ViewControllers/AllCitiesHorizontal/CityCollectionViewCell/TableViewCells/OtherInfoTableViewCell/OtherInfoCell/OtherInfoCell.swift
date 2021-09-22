//
//  OtherInfoCell.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 27.07.21.
//

import UIKit



final class OtherInfoCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dataLabel: UILabel!

    func setupOtherInfocell(model: OtherInfoModelCell) {
        titleLabel.text = model.title
        dataLabel.text = model.data
    }
    
}
