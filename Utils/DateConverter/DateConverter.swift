//
//  DateConverter.swift
//  AdirApp
//
//  Created by iMac1 on 02.12.2021.
//

import Foundation

enum DateFormat: String {
    case yyyyMMddTHHmmss = "yyyy-MM-dd'T'HH:mm:ss"
    case yyyyMMdd = "yyyy-MM-dd"
    case MMMMd = "MMMM d"
    case HHmm = "HH:mma"
}

class DateConverter {
    private static let dateFormatter = DateFormatter()
    
    static func getDate(from string: String?, dateFormat: String) -> Date? {
        guard let stringDate = string else { return nil }
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: stringDate)
        return date
    }
    
    static func getString(from date: Date, dateFormat: String) -> String {
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = dateFormat
        let string = dateFormatter.string(from: date)
        return string + createDateEnding(dateString: string)
    }
    
    static func isDateInTomorrow(date: Date) -> Bool {
        Calendar(identifier: .gregorian).isDateInTomorrow(date)
    }
    
    static func isDateInToday(date: Date) -> Bool {
        Calendar(identifier: .gregorian).isDateInTomorrow(date)
    }
    
    private static func createDateEnding(dateString: String) -> String {
        let lastChar = dateString.last
        switch lastChar {
        case "1":
            return "st"
        case "2":
            return "nd"
        case "3":
            return "rd"
        case "4", "5", "6", "7", "8", "9", "0":
            return "th"
        default:
            return ""
        }
    }
}

extension Date {

    var tomorrow: Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }
}
