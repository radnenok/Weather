//
//  CitiesVerticalViewController.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 10.08.21.
//

import UIKit

protocol CitiesVerticalViewControllerDelegate: AnyObject {
    func selectCity(indexPathRow: Int, dataSource: [CityWeather], tempC: Bool)
}

final class CitiesVerticalViewController: UIViewController {
    
    @IBOutlet private weak var citiesTableView: UITableView!
    
    private var dataSource: [CityWeather]
    private var tempC: Bool
    
    weak var delegate: CitiesVerticalViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        citiesTableView.delegate = self
        citiesTableView.dataSource = self
        
        citiesTableView.register(UINib(nibName: CityVerticalTableViewCell.description(), bundle: nil), forCellReuseIdentifier: CityVerticalTableViewCell.description())
        
        citiesTableView.register(UINib(nibName: LastVerticalTableViewCell.description(), bundle: nil), forCellReuseIdentifier: LastVerticalTableViewCell.description())
        
  //      citiesTableView.tableFooterView = UIView()
 //       citiesTableView.tableFooterView?.backgroundColor = .black
        
    }
    
    init(model: [CityWeather], tempC: Bool) {
        self.tempC = tempC
        self.dataSource = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension CitiesVerticalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return (dataSource.count+1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == dataSource.count {
            let cell = citiesTableView.dequeueReusableCell(withIdentifier: LastVerticalTableViewCell.description(), for: indexPath) as! LastVerticalTableViewCell
            cell.setupCell(tempC: tempC)
            cell.delegate = self
            return cell
        } else {
            
            let cell  = citiesTableView.dequeueReusableCell(withIdentifier: CityVerticalTableViewCell.description(), for: indexPath) as! CityVerticalTableViewCell
            if indexPath.row == 0 {
                cell.setupCityVerticalCell(cityTime: dataSource[indexPath.row].mainInfo.city, place: "Моя геопозиция", temperature: tempC ? dataSource[indexPath.row].mainInfo.currentTemp : dataSource[indexPath.row].mainInfo.currentTempF, timeZone: dataSource[indexPath.row].mainInfo.timeZone, tempC: true)
            } else {
                cell.setupCityVerticalCell(cityTime: "", place: dataSource[indexPath.row].mainInfo.city, temperature: tempC ? dataSource[indexPath.row].mainInfo.currentTemp : dataSource[indexPath.row].mainInfo.currentTempF, timeZone: dataSource[indexPath.row].mainInfo.timeZone, tempC: tempC)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == dataSource.count {
            return 50
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != dataSource.count {
            self.dismiss(animated: true, completion: nil)
            self.delegate?.selectCity(indexPathRow: indexPath.row, dataSource: dataSource, tempC: tempC)
        }
    }
}


// MARK: - LastVerticalTableViewCellDelegate
extension CitiesVerticalViewController: LastVerticalTableViewCellDelegate {
    func changeTempC(tempC: Bool) {
        self.tempC = tempC
        citiesTableView.reloadData()
    }
    
    func addCity() {
        let controller = SearchPlaceViewController()
        controller.delegate = self
        present(controller, animated: true, completion: nil)

    }

}

extension CitiesVerticalViewController: SearchPlaceViewControllerDelegate {
    func cityChoosen(model: CityWeather) {
        dataSource.append(model)
        citiesTableView.reloadData()
    }
    
}
