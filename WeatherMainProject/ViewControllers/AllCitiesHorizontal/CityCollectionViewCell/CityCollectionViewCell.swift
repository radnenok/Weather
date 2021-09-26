//
//  CityCollectionViewCell.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 31.07.21.
//

import UIKit


protocol CityCollectionViewCellDelegate: AnyObject {
    func cancel()
    func add(model: CityWeather)
    func openMap(latitude: Double, longitude: Double)
}

func getNewAlpha(height: CGFloat, newHeight: CGFloat, to: CGFloat) -> CGFloat {
    
    let newAlpha = 1-(height-newHeight)/to
    return newAlpha
}

final class CityCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var weatherDataTableView: UITableView!
    
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var currentTempLabel: UILabel!
    @IBOutlet private weak var minMaxTempLabel: UILabel!
    
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    
    @IBOutlet private weak var headerView: UIView!
    
    @IBOutlet private weak var headerHeight: NSLayoutConstraint!
    @IBOutlet private weak var cityLabelTop: NSLayoutConstraint!
    
    
    private var dataSource: CityWeather = CityWeather(lat: 0, lon: 0, placeId: "", mainInfo: CurrentDayModel(city: "", country: "", minTemp: 0, maxtemp: 0, minTempF: 0, maxTempF: 0, currentTemp: 0, currentTempF: 0, description: "", timeZone: .current, feelsLike: 0, feelsLikeF: 0), cityData: [])
    
    private var tempC = true
    
    private var forAddCity: Bool = false
    
    private var minNewHeight = CGFloat(116)
    private var maxNewHeight = CGFloat(290)
    private var maxNewTop = CGFloat(50)
    private var minNewTop = CGFloat(15)
    
    private var insetHeight = CGFloat(174)
    
    weak var delegate: CityCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        weatherDataTableView.dataSource = self
        weatherDataTableView.delegate = self
        
        weatherDataTableView.tableFooterView = UIView()
        
        weatherDataTableView.register(UINib(nibName: OtherDaysTableViewCell.description(), bundle: nil), forCellReuseIdentifier: OtherDaysTableViewCell.description())
        
        weatherDataTableView.register(UINib(nibName: OtherInfoTableViewCell.description(), bundle: nil), forCellReuseIdentifier: OtherInfoTableViewCell.description())
        
        
        weatherDataTableView.register(UINib(nibName: LastTableViewCell.description(), bundle: nil), forCellReuseIdentifier: LastTableViewCell.description())
        
        weatherDataTableView.contentInset = UIEdgeInsets(top: insetHeight, left: 0, bottom: 0, right: 0)
          
        let frameFooter = CGRect(x: 0, y: 0, width: weatherDataTableView.frame.width, height: 1)
        let footerView = UIView(frame: frameFooter)
        footerView.backgroundColor = .clear
        weatherDataTableView.tableFooterView = footerView
        
    }
    
   
    override class func description() -> String {
        return "CityCollectionViewCell"
    }
    
    func setupCityCVCell(model: CityWeather, forAddCity: Bool, tempC: Bool, showAddButton: Bool) {
        
        self.tempC = tempC
        self.forAddCity = forAddCity
       
        cityLabel.text = model.mainInfo.city
        descriptionLabel.text = model.mainInfo.description
        currentTempLabel.text = "\(tempC ? model.mainInfo.currentTemp : model.mainInfo.currentTempF)°"
        minMaxTempLabel.attributedText = getStringTempMaxMin(tempMax: tempC ? model.mainInfo.maxtemp : model.mainInfo.maxTempF, tempMin: tempC ? model.mainInfo.minTemp : model.mainInfo.minTempF, type: .long)

        cancelButton.isHidden = !forAddCity
        addButton.isHidden = !forAddCity ? true : !showAddButton
        
        dataSource = model
        
        self.headerHeight.constant = 290
        self.cityLabelTop.constant = 50
        
        weatherDataTableView.reloadData()
   //     print("\(weatherDataTableView.contentOffset.y)")
  
        weatherDataTableView.contentOffset.y = -174
   //     print("\(weatherDataTableView.contentOffset.y)")
        
        
    }
    
    func openMap(latitude: Double, longitude: Double) {
        self.delegate?.openMap(latitude: latitude, longitude: longitude)
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.delegate?.cancel()
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        self.delegate?.add(model: dataSource)
    }
    
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension CityCollectionViewCell: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.cityData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch dataSource.cityData[indexPath.row] {
       
        case .otherDays(days: let days):
            let cell = weatherDataTableView.dequeueReusableCell(withIdentifier: OtherDaysTableViewCell.description(), for: indexPath) as! OtherDaysTableViewCell
            
            if tempC {
                cell.setupCellOtherDays(model: days.compactMap({ OtherDayModelCell(date: $0.date, minTemp: $0.minTemp, maxtemp: $0.maxtemp, icon: $0.icon, pop: $0.pop) }))
                
            } else {
                cell.setupCellOtherDays(model: days.compactMap({ OtherDayModelCell(date: $0.date, minTemp: $0.minTempF, maxtemp: $0.maxtempF, icon: $0.icon, pop: $0.pop) }))
            }
            cell.selectionStyle = .none
            return cell
        
        case .otherInfo(info: let info):
            
            let cell = weatherDataTableView.dequeueReusableCell(withIdentifier: OtherInfoTableViewCell.description(), for: indexPath) as! OtherInfoTableViewCell
            var modelOtherInfoCell = info.compactMap({OtherInfoModelCell(title: $0.title, data: $0.data)})
            
            modelOtherInfoCell.insert(OtherInfoModelCell(title: "ОЩУЩАЕТСЯ КАК", data:  tempC ? "\(dataSource.mainInfo.feelsLike)°" : "\(dataSource.mainInfo.feelsLikeF)°"), at: 3)
            
            cell.setupCell(model: modelOtherInfoCell)
            cell.selectionStyle = .none
            return cell
       
        case .maps(name: let name):
            let cell = weatherDataTableView.dequeueReusableCell(withIdentifier: LastTableViewCell.description(), for: indexPath) as! LastTableViewCell
            cell.setupCell(name: name)
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource.cityData[indexPath.row] {
        case .otherDays:
            return 34*9
        case .otherInfo:
            return 348// 6  cells * 58

        case .maps:
            return 51
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource.cityData[indexPath.row] {
        case .otherDays:
            return 34*9
        case .otherInfo:
            return 348// 6  cells * 58
    
        case .maps:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dataSource.cityData[indexPath.row] {
        
        case .maps(name: let name):
            openMap(latitude: dataSource.lat, longitude: dataSource.lon)
        default:
            return
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offsetY = scrollView.contentOffset.y
        if offsetY+insetHeight < 0 {return}
        if offsetY > 0 {return}
        
        headerHeight.constant = minNewHeight
        cityLabelTop.constant = minNewTop
        
        UIView.animate(withDuration: 0.6) {
            self.headerView.superview?.layoutIfNeeded()
            scrollView.contentOffset.y = 0
        }

    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
        let offsetY = scrollView.contentOffset.y

        var newHeight: CGFloat
        var newTop: CGFloat

        if offsetY < 0 {
        newHeight = max(abs(offsetY)+minNewHeight, minNewHeight)
        } else {
            newHeight = minNewHeight
        }

        if offsetY+insetHeight > 0 {
            newTop = max(maxNewTop-(offsetY+insetHeight)/5, minNewTop)
        } else {
            newTop = maxNewTop
        }

        headerHeight.constant = newHeight
        cityLabelTop.constant = newTop
        minMaxTempLabel.alpha = getNewAlpha(height: maxNewHeight, newHeight: newHeight, to: 86)
        currentTempLabel.alpha = getNewAlpha(height: maxNewHeight, newHeight: newHeight, to: 136)
        
        
    }
    

}




