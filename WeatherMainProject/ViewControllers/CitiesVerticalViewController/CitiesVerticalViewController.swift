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
    private let date = NSDate()
    
    weak var delegate: CitiesVerticalViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        citiesTableView.delegate = self
        citiesTableView.dataSource = self
        
        citiesTableView.register(UINib(nibName: CityVerticalTableViewCell.description(), bundle: nil), forCellReuseIdentifier: CityVerticalTableViewCell.description())
        
        citiesTableView.register(UINib(nibName: LastVerticalTableViewCell.description(), bundle: nil), forCellReuseIdentifier: LastVerticalTableViewCell.description())
        
        citiesTableView.tableFooterView = UIView()
  
    }
    
    override class func awakeFromNib() {
        print(#function)
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
                
                cell.setupCityVerticalCell(cityTime: dataSource[indexPath.row].mainInfo.city, place: "Моя геопозиция", temperature: tempC ? dataSource[indexPath.row].mainInfo.currentTemp : dataSource[indexPath.row].mainInfo.currentTempF)
                
            } else {
                
                let time = DateFormatter.configureDataStringWihTymeZoneFrom(date: date as Date, dateFormat: DateFormat.timeFull, timeZone: dataSource[indexPath.row].mainInfo.timeZone)

                cell.setupCityVerticalCell(cityTime: time, place: dataSource[indexPath.row].mainInfo.city, temperature: tempC ? dataSource[indexPath.row].mainInfo.currentTemp : dataSource[indexPath.row].mainInfo.currentTempF)
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
    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        print("\(indexPath.row)")
//        return
//    }
}


// MARK: - LastVerticalTableViewCellDelegate
extension CitiesVerticalViewController: LastVerticalTableViewCellDelegate {
    
    func openWeatherChannel() {
        //        let stringUrl =  tempC ? "https://weather.com/ru-BY/weather/today/l/c855859306f030f8d49f5384679a817861c690451a73f3d35ca55ec197aa452a" : "https://weather.com/ru-BY/weather/today/l/c855859306f030f8d49f5384679a817861c690451a73f3d35ca55ec197aa452a"
                let stringUrl = "https://weather.com/ru-BY/weather/today/l/c855859306f030f8d49f5384679a817861c690451a73f3d35ca55ec197aa452a"
                 UIApplication.shared.open(NSURL(string: stringUrl)! as URL)
    }
    
    func changeTempC(tempC: Bool) {
        self.tempC = tempC
        citiesTableView.reloadData()
    }
    
    func addCity() {
        var placeIdArray: [String] = []
        for place in dataSource {
            placeIdArray.append(place.placeId)
        }
        
        let controller = SearchPlaceViewController(tempC: tempC, placeIdArray: placeIdArray)
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
