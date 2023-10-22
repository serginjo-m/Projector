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
    
    //check if holiday objects was downloaded
    func downloadHolidayEvents() {
        //Holiday database
        var holidays: Results<HolidayEvent> {
            get{
                return ProjectListRepository.instance.getHolidays()
            }
        }
        
        //Download only once
        if holidays.count == 0{
            getHolidayResults()
        }
        
        
    }
    
    
    func getHolidayResults() {
        
        let holidayRequest = HolidayRequest(countryCode: "IT")//Italian Holidays
        holidayRequest.getHolidays {[weak self] result in//weak self prevent any retain cycles
            self?.listOfHolidays = result
        }
    }
    
    //convert Holiday obj to Event obj
    func convertHolidaysToEvents(){
        //TODO: need to revise it a bit
        //------------------------- need to optimize a bit 2x holiday version storage ------------------------
        self.listOfHolidays.forEach{
            //Holiday objects database. For now it holds a year when it was downloaded
            let holidayEvent = HolidayEvent()
            holidayEvent.category = "holiday"
            holidayEvent.title = $0.name
            holidayEvent.date = $0.date.datetime.dateObject
            holidayEvent.descr = $0.description
            holidayEvent.year = $0.date.datetime.year
            ProjectListRepository.instance.createHoliday(holidayEvent: holidayEvent)
            
            
            //All Events database (holidays, steps, user events)
            let event = Event()
            
            //configure holiday duration
            var dayComponent    = DateComponents()
            dayComponent.day    = 1 // For removing one day (yesterday): -1
            dayComponent.second = -1 // Actual Holiday duration will be 23:59:59, not one day
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
