//
//  String.swift
//  WeatherMainProject
//
//  Created by Виктория Раднёнок on 27.07.21.
//

import Foundation
import UIKit
//import PlaygroundSupport


enum TypeTemperatureString {
    case long
    case short
}

func getStringTempMaxMin(tempMax: Int, tempMin: Int, type: TypeTemperatureString) -> NSAttributedString {
    
    switch type {
    case .long:
        let attributedString = NSAttributedString(string: "Макс. \(tempMax)°, мин. \(tempMin)°", attributes: [.font : UIFont.systemFont(ofSize:  17.0)])
        
        return attributedString
    case .short:
        
        let attributedString = NSMutableAttributedString(string: "\(tempMax)", attributes: [.font : UIFont.systemFont(ofSize:  17.0)])
        
        attributedString.append(NSAttributedString(string: "   \(tempMin)", attributes: [.font : UIFont.systemFont(ofSize:  17.0), .foregroundColor : UIColor.systemGray4]))
        
        return attributedString
    }
   
}

func getStringUnderLined(text1: String, text2: String) -> NSAttributedString {

    let attributedString = NSMutableAttributedString(string: "\(text1)", attributes: [.font : UIFont.systemFont(ofSize:  17.0)])
    
    attributedString.append(NSAttributedString(string: "\(text2)", attributes: [.font : UIFont.systemFont(ofSize:  17.0), .underlineStyle : NSUnderlineStyle.single.rawValue, .underlineColor : UIColor.white]))
    
    return attributedString
}


