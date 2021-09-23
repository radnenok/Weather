//
//  SearchPlaceViewController.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 9.08.21.
//

import UIKit
import GooglePlaces

protocol SearchPlaceViewControllerDelegate: AnyObject {
    func cityChoosen(model: CityWeather)
}

final class SearchPlaceViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var searchBar: UISearchBar!
    
    private var tableDataSource: GMSAutocompleteTableDataSource!
    
    weak var delegate: SearchPlaceViewControllerDelegate?
    
    private var tempC: Bool
    private var placeIdArray: [String]
    
    init(tempC: Bool, placeIdArray: [String]) {
        self.tempC = tempC
        self.placeIdArray = placeIdArray
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource.delegate = self
        tableDataSource.tableCellBackgroundColor = .white
        
        tableView.delegate = tableDataSource
        tableView.dataSource = tableDataSource
        
        searchBar.delegate = self
     
    }
    
    
    private func cityChoosen(place: String, placeId: String) {

        let showAddButton = !placeIdArray.contains(placeId)
        
        let controller = DataViewController(placeId: placeId, city: place, forAddCity: true, tempC: self.tempC, showAddButton: showAddButton)
        controller.delegate = self
        present(controller, animated: true, completion: nil)
        
    }

}


extension SearchPlaceViewController: GMSAutocompleteTableDataSourceDelegate {
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        tableView.reloadData()
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        tableView.reloadData()
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
  
        guard let addressComponents = place.addressComponents else {return}

 //       guard let address = place.name else {return}
        let address = "\(addressComponents[0].shortName ?? place.name ?? ""),\(addressComponents[addressComponents.count-1].shortName ?? "")"
    
        self.cityChoosen(place: address, placeId: place.placeID ?? "")
    
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        return true
    }
    
}


//MARK: - UISearchBarDelegate
extension SearchPlaceViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableDataSource.sourceTextHasChanged(searchText)
    }
}


// MARK: - DataViewControllerDelegate
extension SearchPlaceViewController: DataViewControllerDelegate {
   
    func addCity(model: CityWeather) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.cityChoosen(model: model)
    }
    
}

