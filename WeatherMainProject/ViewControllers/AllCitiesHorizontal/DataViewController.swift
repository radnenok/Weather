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
    private var responseInfoCurrentDay: WeatherResponse?
    
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
            bottomConstraint.constant = 74
            
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
            
            self.dataFetcher.getWeather(cityName: city) { [weak self] response in
                guard let self = self, let responseCurrentDay = response else {return}
                
                self.responseInfoCurrentDay = responseCurrentDay
                
                self.fillDataSource()
                
                DispatchQueue.main.async {
                    self.weatherCollectionView.reloadData()
                }
                
            }
        }
    }
    
    
    private func addWeatherForCityWithLL(forLatitude latitude: CLLocationDegrees, longitude: CLLocationDegrees, oneCity: Bool) {
        
        self.dataFetcher.getWeatherDaysWithLL(forLatitude: latitude, longitude: longitude, cnt: "10") { [weak self] response in
            
            guard let self = self, let response = response else {return}
            self.responseInfoAllDays = response
            
            self.dataFetcher.getWeatherWithLL(forLatitude: latitude, longitude: longitude) { [weak self] response in
                guard let self = self, let responseCurrentDay = response else {return}
                
                self.responseInfoCurrentDay = responseCurrentDay
                
                self.fillDataSource()
                DispatchQueue.main.async {
                    self.weatherCollectionView.reloadData()
                }
              
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
        
        // main info
        guard let responseInfoCurrentDay = responseInfoCurrentDay else {return}
            
        guard let city = responseInfoCurrentDay.name else {return}
        
        if let timeZone = responseInfoCurrentDay.timezone {
            currentTimeZone = TimeZone(secondsFromGMT: timeZone) ?? .current
        }
        
        let lat = responseInfoCurrentDay.coord?.lat ?? 0
        let lon = responseInfoCurrentDay.coord?.lon ?? 0
        
        dataMainInfo = CurrentDayModel(city: city, minTemp: Int(round(responseInfoCurrentDay.main?.temp_min ?? 0)), maxtemp: Int(round(responseInfoCurrentDay.main?.temp_max ?? 0)), minTempF: getTempF(tempInC: responseInfoCurrentDay.main?.temp_min ?? 0), maxTempF: getTempF(tempInC: responseInfoCurrentDay.main?.temp_max ?? 0), currentTemp: Int(round(responseInfoCurrentDay.main?.temp ?? 0)), currentTempF: getTempF(tempInC: responseInfoCurrentDay.main?.temp ?? 0), description: responseInfoCurrentDay.weather?.first?.description ?? "", timeZone: currentTimeZone)
        
        
        // other info
        if let sys = responseInfoCurrentDay.sys {
            
            var dayTitleString = ""
            
            if let epochInt = sys.sunrise {
                dayTitleString = DateFormatter.configureDataStringFrom(epoch: epochInt, dateFormat: .timeFull)
                dataOtherInfo.append(OtherInfoModel(title: "ВОСХОД СОЛНЦА", data: dayTitleString))
            }
            
            if let epochInt = sys.sunset {
                dayTitleString = DateFormatter.configureDataStringFrom(epoch: epochInt, dateFormat: .timeFull)
                dataOtherInfo.append(OtherInfoModel(title: "ЗАХОД СОЛНЦА", data: dayTitleString))
            }
            
        }
        
        if let main = responseInfoCurrentDay.main {
            if let humidity = main.humidity {
                dataOtherInfo.append(OtherInfoModel(title: "ВЛАЖНОСТЬ", data: "\(humidity)%"))
            }
            
            if let feels_like = main.feels_like {
                dataOtherInfo.append(OtherInfoModel(title: "ОЩУЩАЕТСЯ КАК", data: "\(Int(round(feels_like)))°"))
            }
            
            if let pressure = main.pressure {
                dataOtherInfo.append(OtherInfoModel(title: "ДАВЛЕНИЕ", data: "\(Double(pressure)*0.75) мм рт.ст."))
            }
        }
        
        if let wind = responseInfoCurrentDay.wind {
            guard let speed = wind.speed, let deg = wind.deg  else {return}
            dataOtherInfo.append(OtherInfoModel(title: "ВЕТЕР", data: "\(speed) м/с"))
        }
        
        if let visibility = responseInfoCurrentDay.visibility {
            dataOtherInfo.append(OtherInfoModel(title: "ВИДИМОСТЬ", data: "\(Double(visibility/100)/10) км"))
        }
        
        
        // other days responseInfoAllDays.list
        guard let responseInfoAllDays = responseInfoAllDays else {return}
        guard let days = responseInfoAllDays.list else {return}
        
        var notFirstPosition = false
        for day in days {
            
            if notFirstPosition {
                
                var dayTitleString = ""
                
                if let epochInt = day.dt {
                    
                    dayTitleString = DateFormatter.configureDataStringFrom(epoch: epochInt, dateFormat: .dayTitle)
                    
                    guard let minTemp = day.temp?.min, let maxTemp = day.temp?.max, let icon = day.weather?.first?.icon else {return}
                    
                    let minTempInt = Int(round(minTemp))
                    let maxTempInt = Int(round(maxTemp))
                    
                    daysArray.append(OtherDayModel(date: dayTitleString, minTemp: minTempInt, maxtemp: maxTempInt, minTempF: getTempF(tempInC: minTemp), maxtempF: getTempF(tempInC: maxTemp), icon: "http://openweathermap.org/img/wn/\(icon)@2x.png"))
                }
                
            }
            
            notFirstPosition = true
        }
        
        self.dataSourceAllCities.append(CityWeather(lat: lat, lon: lon, placeId: placeId ?? "", mainInfo: dataMainInfo, cityData: [.otherDays(days: daysArray), .otherInfo(info: dataOtherInfo), .maps(name: dataMainInfo.city)]))
        
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
        
        print("cellForItemAt \(indexPath.item)")
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        print("collectionViewLayout \(indexPath.item)")
        
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




