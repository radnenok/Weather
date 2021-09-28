//
//  LastTableViewCell.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 5.09.21.
//

import UIKit


class LastTableViewCell: UITableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override class func description() -> String {
        return "LastTableViewCell"
    }
    
    func setupCell(name: String) {
            
        nameLabel.attributedText = getStringUnderLined(text1: "Погода - \(name). ", text2: "Открыть в Картах")
       
    }
    
}
