//
//  UserActivitySingleton.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
//this class should contain user activity object accessable to all view controllers and classes
class UserActivitySingleton {
    
    static let shared = UserActivitySingleton()
    
    //a bit trick here
    //because I don't want to deal with optionals everywhere I need to add new item
    //first create an empty object, and then it will be rewritten immediately
    var currentDayActivity = DayActivity()
    
    let calendar = Calendar(identifier: .gregorian)
    
    let selectedDate = Date()
    
    //create user activity object with date
    func createUserActivity(description: String){
        let userActivity = UserActivity()
        userActivity.date = Date()
        userActivity.descr = description
        ProjectListRepository.instance.appendNewItemToDayActivity(dayActivity: currentDayActivity, userActivity: userActivity)
    }
    
    private lazy var dateFormatterNumber: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    private lazy var dateFormatterFullDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter
    }()
    
    //takes day and return an array of days
    func generateDaysInMonth (for baseDate: Date) -> [RecentDay] {
        
        //last 29 days
        let offsetInInitialRow = 29
        // "first day of month" is today
        let firstDayOfMonth = Date()
        
        
        
        //calculate last 30 days from today
        let days: [RecentDay] = (0...29)
            .map { day in
                
                // check day for current or previous month
                let isWithinDisplayedMonth = day >= offsetInInitialRow
                
                // calculate the offset
                let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)
                
                // adds of substructs an offset from Date for new day
                return generateDay(offsetBy: dayOffset, for: firstDayOfMonth)
        }
        
        return days
    }
    
    //Generate Days For Calendar
    func generateDay( offsetBy dayOffset: Int, for baseDate: Date) -> RecentDay {
        
        let date = calendar.date( byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        
        return RecentDay(
            date: date,
            number: self.dateFormatterNumber.string(from: date),
            dateString: self.dateFormatterFullDate.string(from: date)
        )
    }
}


