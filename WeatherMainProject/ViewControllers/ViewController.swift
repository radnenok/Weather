//
//  ViewController.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 22.07.21.
//

import UIKit

  
final class ViewController: UIViewController  {
    
    @IBOutlet private weak var weatherCollectionView: UICollectionView!
    
    @IBOutlet private weak var weatherPageControl: UIPageControl!
    
    private var dataSourceAllCities: [CityWeather] = []
    
    private var dataSource: [CellDataType] = []
    private var tempC: Bool = true
    private let dataFetcher = DataFetcherService()
    private let dataFetcherCurrentDay = DataFetcherService()
    
    private let forAddCity = false
    
    private var arrayCities: [String] = ["Minsk"] // подтянуть из user defaults
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ViewController - viewDidLoad")
        
        weatherCollectionView.dataSource = self
        weatherCollectionView.delegate = self
        
        setPageControl()
        
        weatherCollectionView.register(UINib(nibName: CityCollectionViewCell.description(), bundle: nil), forCellWithReuseIdentifier: CityCollectionViewCell.description())
         
        for city in arrayCities {
            addWeatherForCity(placeId: "", city: city, oneCity: false)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ViewController - viewWillAppear")
        setPageControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("ViewController - viewDidAppear")
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      print("ViewController - viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("ViewController - viewDidDisappear")
    }
    
    
    @objc private func pageControlDidChanged(_ sender: UIPageControl) {
    
        let current = sender.currentPage
        weatherCollectionView.setContentOffset(CGPoint(x: CGFloat(current)*view.frame.size.width, y: 0), animated: true)
    }
    
  
    
    private func setPageControl() {
      
        weatherPageControl.setIndicatorImage(UIImage.init(systemName: "location.fill"), forPage: 0)
        weatherPageControl.hidesForSinglePage = true
        weatherPageControl.addTarget(self, action: #selector(pageControlDidChanged(_:)), for: .valueChanged)
            
    }
    
    private func addWeatherForCity(placeId: String, city: String, oneCity: Bool) {
        
        self.dataFetcher.getWeatherDays(cnt: "15", cityName: city) { [weak self] response in
            guard let self = self, let response = response else {return}
            self.fillDataSource(response: response)
            
            self.dataFetcherCurrentDay.getWeather(cityName: city) { [weak self] response in
                guard let self = self, let responseCurrentday = response else {return}
                self.addDataSource(response: responseCurrentday, attrOneCity: oneCity)
                
                if oneCity {
                    self.weatherCollectionView.reloadData()
                }
            }
        }
    }
    
    private func getTempF(tempInC: Double) -> Int {
        let tempF = Int(round(tempInC*(9/5)+32))
        return tempF
    }
    
    private func addDataSource(response: WeatherResponse, attrOneCity: Bool) {
        var dataMainInfo: CurrentDayModel!
        
        var dataOtherInfo: [OtherInfoModel] = []
        var currentTimeZone: TimeZone = .current
        // main info
        guard let city = response.name else {return}
        
        
        if let timeZone = response.timezone {
            currentTimeZone = TimeZone(secondsFromGMT: timeZone) ?? .current
        }
        
        let lat = response.coord?.lat ?? 0
        let lon = response.coord?.lon ?? 0
        
        dataMainInfo = CurrentDayModel(city: city, minTemp: Int(round(response.main?.temp_min ?? 0)), maxtemp: Int(round(response.main?.temp_max ?? 0)), minTempF: getTempF(tempInC: response.main?.temp_min ?? 0), maxTempF: getTempF(tempInC: response.main?.temp_max ?? 0), currentTemp: Int(round(response.main?.temp ?? 0)), currentTempF: getTempF(tempInC: response.main?.temp ?? 0), description: response.weather?.first?.description ?? "", timeZone: currentTimeZone)
        
        // other info
        if let sys = response.sys {
            
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

//      -  "ВЕРОЯТНОСТЬ ДОЖДЯ"

        if let main = response.main {
            if let humidity = main.humidity {
                dataOtherInfo.append(OtherInfoModel(title: "ВЛАЖНОСТЬ", data: "\(humidity)%"))
            }

            //      +-  "ВЕТЕР"
            
            if let feels_like = main.feels_like {
                dataOtherInfo.append(OtherInfoModel(title: "ОЩУЩАЕТСЯ КАК", data: "\(Int(round(feels_like)))°"))
            }

            if let pressure = main.pressure {
                dataOtherInfo.append(OtherInfoModel(title: "ДАВЛЕНИЕ", data: "\(Double(pressure)*0.75) мм рт.ст."))
            }
        }

        if let wind = response.wind {
            guard let speed = wind.speed, let deg = wind.deg  else {return}
            dataOtherInfo.append(OtherInfoModel(title: "ВЕТЕР", data: "\(speed) м/с"))
        }

//   -    "ОСАДКИ"

//   +    "ДАВЛЕНИЕ"

        if let visibility = response.visibility {
            dataOtherInfo.append(OtherInfoModel(title: "ВИДИМОСТЬ", data: "\(Double(visibility/100)/10) км"))
        }
//    -    "УФ-ИНДЕКС"

        self.dataSource.append(.otherInfo(info: dataOtherInfo))
        
        self.dataSourceAllCities.append(CityWeather(lat: lat, lon: lon, placeId: "", mainInfo: dataMainInfo, cityData: dataSource))
        self.weatherCollectionView.reloadData()
        
        self.dataSource.removeAll()
      
    }
    
    private func fillDataSource(response: WeatherDaysResponse) {
       
        // other days
        guard let days = response.list else {return}
        
        var daysArray: [OtherDayModel] = []
        
        for day in days {
            
            var dayTitleString = ""
            
            if let epochInt = day.dt {
                
                dayTitleString = DateFormatter.configureDataStringFrom(epoch: epochInt, dateFormat: .dayTitle)
                
                guard let minTemp = day.temp?.min, let maxTemp = day.temp?.max, let icon = day.weather?.first?.icon else {return}
            
                let minTempInt = Int(round(minTemp))
                let maxTempInt = Int(round(maxTemp))
                
                
                
                daysArray.append(OtherDayModel(date: dayTitleString, minTemp: minTempInt, maxtemp: maxTempInt, minTempF: getTempF(tempInC: minTemp), maxtempF: getTempF(tempInC: maxTemp), icon: "http://openweathermap.org/img/wn/\(icon)@2x.png"))
            }
            
        }
        
        self.dataSource.append(.otherDays(days: daysArray))
        
    }
    
  
    @IBAction private func addCityBtn(_ sender: UIButton) {
   
        let controller = CitiesVerticalViewController(model: dataSourceAllCities, tempC: tempC)
        controller.modalPresentationStyle = .fullScreen
        controller.delegate = self
        present(controller, animated: true, completion: nil)
        
    }
  
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = dataSourceAllCities.count
        weatherPageControl.numberOfPages = count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = weatherCollectionView.dequeueReusableCell(withReuseIdentifier: CityCollectionViewCell.description(), for: indexPath) as! CityCollectionViewCell
        cell.setupCityCVCell(model: dataSourceAllCities[indexPath.item], forAddCity: forAddCity, tempC: tempC, showAddButton: forAddCity)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let width = scrollView.frame.width - (scrollView.contentInset.left*2)
        let index = scrollView.contentOffset.x/width
        let roundedIndex = round(index)
        weatherPageControl.currentPage = Int(roundedIndex)
        
    }

}

// MARK: - CitiesVerticalViewControllerDelegate
extension ViewController: CitiesVerticalViewControllerDelegate {
    func selectCity(indexPathRow: Int, dataSource: [CityWeather], tempC: Bool) {
        
        dataSourceAllCities = dataSource
        weatherCollectionView.reloadData()
        
        print("reloadData")
        
        let current = indexPathRow
        weatherCollectionView.setContentOffset(CGPoint(x: CGFloat(current)*view.frame.size.width, y: 0), animated: true)
       
        weatherPageControl.currentPage = indexPathRow
        
       
    }
    
}

