//
//  OtherDaysTableViewCell.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 29.08.21.
//

import UIKit

final class OtherDaysTableViewCell: UITableViewCell {

    @IBOutlet private weak var otherDaysTableView: UITableView!
    private var dataSource: [OtherDayModelCell] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        otherDaysTableView.delegate = self
        otherDaysTableView.dataSource = self
        
        otherDaysTableView.register(UINib(nibName: OtherDayInfoTableViewCell.description(), bundle: nil), forCellReuseIdentifier: OtherDayInfoTableViewCell.description())
    }

    override class func description() -> String {
        return "OtherDaysTableViewCell"
    }
    
    func setupCellOtherDays(model: [OtherDayModelCell]) {
        dataSource = model
        otherDaysTableView.reloadData()
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension OtherDaysTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = otherDaysTableView.dequeueReusableCell(withIdentifier: OtherDayInfoTableViewCell.description(), for: indexPath) as! OtherDayInfoTableViewCell
        cell.setupCellOtherDays(model: dataSource[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}
