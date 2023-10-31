//
//  UserActivitySingleton.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class UserActivitySingleton {
    
    static let shared = UserActivitySingleton()

    var currentDayActivity = DayActivity()
    
    let calendar = Calendar(identifier: .gregorian)
    
    let selectedDate = Date()

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
    
    
    func generateDaysInMonth (for baseDate: Date) -> [RecentDay] {
    
        let offsetInInitialRow = 29
        
        let firstDayOfMonth = Date()
        
        let days: [RecentDay] = (0...29)
            .map { day in
                
                let isWithinDisplayedMonth = day >= offsetInInitialRow
                
                let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)
                
                return generateDay(offsetBy: dayOffset, for: firstDayOfMonth)
        }
        
        return days
    }
    
    func generateDay( offsetBy dayOffset: Int, for baseDate: Date) -> RecentDay {
        
        let date = calendar.date( byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        
        return RecentDay(
            date: date,
            number: self.dateFormatterNumber.string(from: date),
            dateString: self.dateFormatterFullDate.string(from: date)
        )
    }
}


