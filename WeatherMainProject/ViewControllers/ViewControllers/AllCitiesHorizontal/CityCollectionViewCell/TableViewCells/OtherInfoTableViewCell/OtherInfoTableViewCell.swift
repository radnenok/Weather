//
//  OtherInfoTableViewCell.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 27.07.21.
//

import UIKit

final class OtherInfoTableViewCell: UITableViewCell {

    @IBOutlet private weak var otherInfoTableView: UITableView!
    
    private var dataSourceOtherInfo: [OtherInfoModelCell] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        otherInfoTableView.dataSource = self
        otherInfoTableView.delegate = self
        
        otherInfoTableView.register(cellType: OtherInfoCell.self)
    
    }
    
    override class func description() -> String {
        return "OtherInfoTableViewCell"
    }
    
    func setupCell(model: [OtherInfoModelCell]) {
        dataSourceOtherInfo = model
        otherInfoTableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension OtherInfoTableViewCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSourceOtherInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = otherInfoTableView.dequeueReusableCell(with: OtherInfoCell.self, for: indexPath)
        cell.setupOtherInfocell(model: dataSourceOtherInfo[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
}
