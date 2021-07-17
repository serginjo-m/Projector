//
//  ChartCalendarExtension.swift
//  Projector
//
//  Created by Serginjo Melnik on 07.07.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

//---------------------------------------- must be for both calendar and statistics ------------------------------
extension BarChartController {
    //accept Date and return MonthMetadata object
    func monthMetadata(for baseDate: Date) throws -> MonthMetadata{
        //asks calendar for the number of days in basedate's month. return first day
        guard
            let numberOfDaysInMonth = calendar.range(
                of: .day,
                in: .month,
                for: baseDate)?.count,
            let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate))
            
            else{
                throw CalendarDataError.metadataGeneration
        }
        
        //which day of the week first day of month falls on
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        return MonthMetadata(
            numberOfDays: numberOfDaysInMonth,
            firstDay: firstDayOfMonth,
            firstDayWeekday: firstDayWeekday)
        
    }
    
    //takes day and return an array of days
    func generateDaysInMonth (for baseDate: Date) -> [Day] {
        //calls metadata function for object
        guard let metadata = try? monthMetadata(for: baseDate) else {
            fatalError("An error occurred when generating the metadata for \(baseDate)")
        }
        //extract values from object
        let numberOfDaysInMonth = metadata.numberOfDays//31
        
        
        
        let firstDayOfMonth = metadata.firstDay
        
        //adds extra bit to begining of month if needed
        let days: [Day] = (1...numberOfDaysInMonth)
            .map { day in
                
                // calculate the offset
                let dayOffset = day - 1//day = 1....
                
                // adds of substructs an offset from Date for new day
                return generateDay(offsetBy: dayOffset, for: firstDayOfMonth)
        }
        
        return days
    }
    
    // 7 : Generate Days For Calendar
    func generateDay( offsetBy dayOffset: Int, for baseDate: Date) -> Day {
        
        let date = calendar.date( byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        
        return Day( date: date, number: self.dateFormatter.string(from: date), isSelected: false, isWithinDisplayedMonth: true,  containEvent: false)
    }
    
    
    
    enum CalendarDataError: Error {
        case metadataGeneration
    }
}
