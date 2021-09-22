//
//  LastVerticalTableViewCell.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 10.08.21.
//

import UIKit

protocol LastVerticalTableViewCellDelegate: AnyObject {
    func addCity()
    func changeTempC(tempC: Bool)
    func openWeatherChannel()
}

final class LastVerticalTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var cButton: UIButton!
    @IBOutlet private weak var fButton: UIButton!
    
    private var tempC: Bool = true
    
    weak var delegate: LastVerticalTableViewCellDelegate?
    
    func setupCell(tempC: Bool) {
        self.tempC = tempC
        setupUI()
    }

    override class func description() -> String {
        return "LastVerticalTableViewCell"
    }
    
    @IBAction private func addCityBtn(_ sender: UIButton) {
        self.delegate?.addCity()
    }
    
    
    @IBAction private func tempCPressed(_ sender: UIButton) {
        changeValueTempC(newValue: true)
    }
    
    
    @IBAction func tempFPressed(_ sender: UIButton) {
        changeValueTempC(newValue: false)
    }
    
    
    @IBAction func weatherChannelButton(_ sender: UIButton) {
        self.delegate?.openWeatherChannel()
    }
    
    private func setupUI() {
        if tempC {
            cButton.setTitleColor(.white, for: .normal)
            fButton.setTitleColor(.gray, for: .normal)
        } else {
            cButton.setTitleColor(.gray, for: .normal)
            fButton.setTitleColor(.white, for: .normal)
        }
    }
    
    private func changeValueTempC(newValue: Bool) {
        tempC = newValue
        setupUI()
        self.delegate?.changeTempC(tempC: tempC)
    }
    
}
