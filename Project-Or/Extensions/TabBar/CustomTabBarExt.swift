//
//  CustomTabBarController.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
import Photos

extension CustomTabBarController {
    
    func downloadHolidayEvents() {
        var holidays: Results<HolidayEvent> {
            get{
                return ProjectListRepository.instance.getHolidays()
            }
        }
        
        if holidays.count == 0{
            getHolidayResults()
        }
    }
    
    
    func getHolidayResults() {
        let holidayRequest = HolidayRequest(countryCode: "IT")
        holidayRequest.getHolidays {[weak self] result in
            self?.listOfHolidays = result
        }
    }
    
    func convertHolidaysToEvents(){
        self.listOfHolidays.forEach{
            let holidayEvent = HolidayEvent()
            holidayEvent.category = "holiday"
            holidayEvent.title = $0.name
            holidayEvent.date = $0.date.datetime.dateObject
            holidayEvent.descr = $0.description
            holidayEvent.year = $0.date.datetime.year
            ProjectListRepository.instance.createHoliday(holidayEvent: holidayEvent)
            
            let event = Event()
            
            var dayComponent    = DateComponents()
            dayComponent.day    = 1
            dayComponent.second = -1
            let theCalendar     = Calendar.current
            if let holidayEventDate = holidayEvent.date {
                let nextDay = theCalendar.date(byAdding: dayComponent, to: holidayEventDate)
                event.endTime = nextDay
            }
            
            event.category = holidayEvent.category
            event.title = holidayEvent.title
            event.date = holidayEvent.date
            event.startTime = holidayEvent.date
            
            event.descr = holidayEvent.descr
            ProjectListRepository.instance.createEvent(event: event)
            
        }
    }
}
