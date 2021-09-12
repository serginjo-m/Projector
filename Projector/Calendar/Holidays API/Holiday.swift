//
//  Holiday.swift
//  Projector
//
//  Created by Serginjo Melnik on 05.09.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

struct HolidayResponse:Decodable {
    var response:Holidays
}

struct Holidays:Decodable {
    var holidays:[HolidayDetail]
}

struct HolidayDetail:Decodable {
    var name:String
    var description:String
    var date:DateInfo
}

struct DateInfo:Decodable {
    var iso:String
    var datetime:DateTime
}

struct DateTime:Decodable {
    var year:Int
    var month:Int
    var day:Int
}

extension DateTime {
    var dateObject: Date? {
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = self.year
        dateComponents.month = self.month
        dateComponents.day = self.day
        dateComponents.hour = 0
        dateComponents.minute = 00
        
        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
        let date = userCalendar.date(from: dateComponents)
        return date
    }
}
