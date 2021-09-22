//
//  File.swift
//  homeworkTableView
//
//  Created by Виктория Раднёнок on 4.07.21.
//

import Foundation

enum DateFormat: String {
    case dayTitle = "EEEE"
    case timeFull = "HH:mm"
    case dateTitle = "E, dd MMMM"
}

// MARK: - DateFormatter
extension DateFormatter {
    
    static func configureDataStringFrom(epoch: Int, dateFormat: DateFormat) -> String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(epoch)) as Date
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current
        dateFormatter.dateFormat = dateFormat.rawValue
        return dateFormatter.string(from: date)
    }
    
    static func configureDataStringWihTymeZoneFrom(date: Date, dateFormat: DateFormat, timeZone: TimeZone) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = .current
        dateFormatter.dateFormat = dateFormat.rawValue
        return dateFormatter.string(from: date)
    }
    
    static func timeDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "h:mm a"
        
        return dateFormatter
    }
    
    static func dateDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current
        dateFormatter.dateStyle = .medium
        
        return dateFormatter
    }
    
    static func dayTimeDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "dd HH:mm:ss"
        
 
        return dateFormatter
    }
    
    static func longDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        
        return dateFormatter
    }
    
//    static func newDateFormatter() -> DateFormatter {
//        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = .current
//        dateFormatter.dateFormat = "E, dd MMMM"
//    
//        return dateFormatter
//    }
    
   
}

