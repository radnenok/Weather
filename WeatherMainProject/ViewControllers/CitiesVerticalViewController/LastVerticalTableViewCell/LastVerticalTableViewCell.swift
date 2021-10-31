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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
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
        tempC = true
        setupUI()
        self.delegate?.changeTempC(tempC: true)
    }
    
    @IBAction func openWeatherButton(_ sender: UIButton) {
        
        self.delegate?.openWeatherChannel()
 
    }
    
    @IBAction func tempFPressed(_ sender: UIButton) {
        tempC = false
        setupUI()
        self.delegate?.changeTempC(tempC: tempC)
        
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
}
