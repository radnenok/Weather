//
//  ViewController.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 22.07.21.
//

import UIKit
import CoreLocation


protocol DataViewControllerDelegate: AnyObject {
    func addCity(model: CityWeather)
}
    
class DataViewController: UIViewController  {
    
    @IBOutlet private weak var weatherCollectionView: UICollectionView!
    @IBOutlet private weak var weatherPageControl: UIPageControl!
    @IBOutlet private weak var addCityButton: UIButton!
    @IBOutlet private weak var openWeatherButton: UIButton!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
    private var responseInfoAllDays: WeatherDaysResponse?
  
    private var dataSourceAllCities: [CityWeather] = []
    private var tempC: Bool = true  // подтянуть из user defaults
    
    private let dataFetcher = DataFetcherService()
    
    private let forAddCity: Bool
    private let showAddButton: Bool
    private var city: String?
    private var placeId: String?
    
    weak var delegate: DataViewControllerDelegate?
    
    var locationManager: CLLocationManager = CLLocationManager()
   
    var currentCoordinate: [String: Double] = ["lat": 0, "lon": 0]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherCollectionView.dataSource = self
        weatherCollectionView.delegate = self
        
        weatherCollectionView.register(UINib(nibName: CityCollectionViewCell.description(), bundle: nil), forCellWithReuseIdentifier: CityCollectionViewCell.description())
        
        if forAddCity {
            guard let cityValue = city else { return }
            addWeatherForCity(city: cityValue, oneCity: false)
     
        } else {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()

           if CLLocationManager.locationServicesEnabled() {
                locationManager.requestLocation()
           }
        }
     
        self.setUI()
      
    }
   
    
    init(placeId: String, city: String, forAddCity: Bool, tempC: Bool, showAddButton: Bool) {
        self.forAddCity = forAddCity
        self.city = city
        self.placeId = placeId
        self.tempC = tempC
        self.showAddButton = showAddButton
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        weatherPageControl.setIndicatorImage(UIImage.init(systemName: "location.fill"), forPage: 0)
    }

  
    @IBAction private func addCityBtn(_ sender: UIButton) {
   
        let controller = CitiesVerticalViewController(model: dataSourceAllCities, tempC: tempC)
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        present(controller, animated: true, completion: nil)
     
    }
    
    
    @IBAction func openWeatherBtn(_ sender: UIButton) {

       let string1 =  "https://weather.com/ru-BY/weather/today/l/BOXX0005:1:BO?Goto=Redirected"
        UIApplication.shared.open(NSURL(string: string1)! as URL)
    }
    
    @objc private func pageControlDidChanged(_ sender: UIPageControl) {
    
        let current = sender.currentPage
        weatherCollectionView.setContentOffset(CGPoint(x: CGFloat(current)*view.frame.size.width, y: 0), animated: true)
        
    }
    
    private func setUI() {
      
        if forAddCity {
            bottomConstraint.constant = 0
        } else {
            bottomConstraint.constant = 64
            
            weatherPageControl.hidesForSinglePage = true
            weatherPageControl.setIndicatorImage(UIImage.init(systemName: "location.fill"), forPage: 0)
            weatherPageControl.addTarget(self, action: #selector(pageControlDidChanged(_:)), for: .valueChanged)
        }
        
        addCityButton.isHidden = forAddCity
        openWeatherButton.isHidden = forAddCity
        weatherPageControl.isHidden = forAddCity
        
    }
    
    private func addWeatherForCity(city: String, oneCity: Bool) {
        
        self.dataFetcher.getWeatherDays(cnt: "10", cityName: city) { [weak self] response in
            
            guard let self = self, let response = response else {return}
            self.responseInfoAllDays = response
            
            self.fillDataSource()
            
            DispatchQueue.main.async {
                self.weatherCollectionView.reloadData()
            }
            
        }
    }
    
    
    private func addWeatherForCityWithLL(forLatitude latitude: CLLocationDegrees, longitude: CLLocationDegrees, oneCity: Bool) {
        
        self.dataFetcher.getWeatherDaysWithLL(forLatitude: latitude, longitude: longitude, cnt: "10") { [weak self] response in
            
            guard let self = self, let response = response else {return}
            self.responseInfoAllDays = response
            
            self.fillDataSource()
            DispatchQueue.main.async {
                self.weatherCollectionView.reloadData()
            }
            
        }
    }
    
    
    private func getTempF(tempInC: Double) -> Int {
        let tempF = Int(round(tempInC*(9/5)+32))
        return tempF
    }
    
    private func fillDataSource() {
        
        var dataMainInfo: CurrentDayModel
        var dataOtherInfo: [OtherInfoModel] = []
        var daysArray: [OtherDayModel] = []
        
        var currentTimeZone: TimeZone = .current
        
        
        // other days responseInfoAllDays.list
        guard let responseInfoAllDays = responseInfoAllDays else {return}
        guard let days = responseInfoAllDays.list else {return}
        
        
        var day: List
        var dayTitleString: String
        
        day = days[0]
        
        // main info
        guard let city = responseInfoAllDays.city?.name else {return}
        
        if let timeZone = responseInfoAllDays.city?.timezone {
            currentTimeZone = TimeZone(secondsFromGMT: timeZone) ?? .current
        }
        
        let lat = responseInfoAllDays.city?.coord?.lat ?? 0
        let lon = responseInfoAllDays.city?.coord?.lon ?? 0
        
        dataMainInfo = CurrentDayModel(city: city, country: responseInfoAllDays.city?.country ?? "", minTemp: Int(round(day.temp?.min ?? 0)), maxtemp: Int(round(day.temp?.max ?? 0)), minTempF: getTempF(tempInC: day.temp?.min ?? 0), maxTempF: getTempF(tempInC: day.temp?.max ?? 0), currentTemp: Int(round(day.temp?.day ?? 0)), currentTempF: getTempF(tempInC: day.temp?.day ?? 0), description: day.weather?.first?.description ?? "", timeZone: currentTimeZone, feelsLike: Int(round(day.feels_like?.day ?? 0)), feelsLikeF: getTempF(tempInC: Double(round(day.feels_like?.day ?? 0))))
        
       
        // other info
        if let epochInt = day.sunrise {
            dayTitleString = DateFormatter.configureDataStringFrom(epoch: epochInt, dateFormat: .timeFull)
            dataOtherInfo.append(OtherInfoModel(title: "ВОСХОД СОЛНЦА", data: dayTitleString))
        }
        
        if let epochInt = day.sunset {
            dayTitleString = DateFormatter.configureDataStringFrom(epoch: epochInt, dateFormat: .timeFull)
            dataOtherInfo.append(OtherInfoModel(title: "ЗАХОД СОЛНЦА", data: dayTitleString))
        }
        
    
        if let humidity = day.humidity {
            dataOtherInfo.append(OtherInfoModel(title: "ВЛАЖНОСТЬ", data: "\(humidity)%"))
        }
        
//        if let feels_like = day.feels_like?.day {
//            dataOtherInfo.append(OtherInfoModel(title: "ОЩУЩАЕТСЯ КАК", data: "\(Int(round(feels_like)))°"))
//        }
        
        if let pressure = day.pressure {
            dataOtherInfo.append(OtherInfoModel(title: "ДАВЛЕНИЕ", data: "\(Double(pressure)*0.75) мм рт.ст."))
        }
        
        guard let speed = day.speed  else {return}
        dataOtherInfo.append(OtherInfoModel(title: "ВЕТЕР", data: "\(speed) м/с"))
        
    
        for index in 1..<days.count {
            day = days[index]
    
            if let epochInt = day.dt {
                
                dayTitleString = DateFormatter.configureDataStringFrom(epoch: epochInt, dateFormat: .dayTitle)
                
                guard let minTemp = day.temp?.min, let maxTemp = day.temp?.max, let icon = day.weather?.first?.icon, let pop = day.pop else {return}
                
                let minTempInt = Int(round(minTemp))
                let maxTempInt = Int(round(maxTemp))
                let popInt = Int(round(pop*100))
                let popString = popInt == 0 ? "" : "\(popInt) %"
                
                daysArray.append(OtherDayModel(date: dayTitleString, minTemp: minTempInt, maxtemp: maxTempInt, minTempF: getTempF(tempInC: minTemp), maxtempF: getTempF(tempInC: maxTemp), icon: "http://openweathermap.org/img/wn/\(icon)@2x.png", pop: popString))
            }
            
        }
        
        self.dataSourceAllCities.append(CityWeather(lat: lat, lon: lon, placeId: placeId ?? "", mainInfo: dataMainInfo, cityData: [.otherDays(days: daysArray), .otherInfo(info: dataOtherInfo), .maps(name: "\(dataMainInfo.city), \(dataMainInfo.country)")]))
        
    }
      
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate
extension DataViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = dataSourceAllCities.count
        weatherPageControl.numberOfPages = count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = weatherCollectionView.dequeueReusableCell(withReuseIdentifier: CityCollectionViewCell.description(), for: indexPath) as! CityCollectionViewCell
        cell.delegate = self
        cell.setupCityCVCell(model: dataSourceAllCities[indexPath.item], forAddCity: forAddCity, tempC: tempC, showAddButton: showAddButton)
        
    //    print("cellForItemAt \(indexPath.item)")
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
    //    print("collectionViewLayout \(indexPath.item)")
        
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let width = scrollView.frame.width - (scrollView.contentInset.left*2)
        let index = scrollView.contentOffset.x/width
        let roundedIndex = round(index)
        weatherPageControl.currentPage = Int(roundedIndex)
      
    }

}


// MARK: - CityCollectionViewCellDelegate
extension DataViewController: CityCollectionViewCellDelegate {
    
    func openMap(latitude: Double, longitude: Double) {
        
        let string1 = "https://yandex.ru/maps/?ll=\(longitude),\(latitude)&z=12&l=map"

        let url = URL(string: string1)!

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
       }
  
    }
    
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func add(model: CityWeather) {
        
        self.dismiss(animated: true, completion: nil)
        self.delegate?.addCity(model: model)
        
    }
    
}


// MARK: - CitiesVerticalViewControllerDelegate
extension DataViewController: CitiesVerticalViewControllerDelegate {
    func selectCity(indexPathRow: Int, dataSource: [CityWeather], tempC: Bool) {
        
        self.tempC = tempC
        self.dataSourceAllCities = dataSource
        
        DispatchQueue.main.async {
            self.weatherCollectionView.reloadData()
            
            DispatchQueue.main.async {
                let current = indexPathRow
                self.weatherCollectionView.setContentOffset(CGPoint(x: CGFloat(current)*self.view.frame.size.width, y: 0), animated: true)
                
                self.weatherPageControl.currentPage = indexPathRow
            }
        }
        
    }
    
}

// MARK: - CLLocationManagerDelegate
extension DataViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
    //    print("latitude: \(latitude), longitude: \(longitude)")
       
        if currentCoordinate["lat"] != latitude || currentCoordinate["lon"] != longitude {
            addWeatherForCityWithLL(forLatitude: latitude, longitude: longitude, oneCity: false)
            currentCoordinate["lat"] = latitude
            currentCoordinate["lon"] = longitude
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}




