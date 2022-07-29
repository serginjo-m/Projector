//
//  EventsLouncher.swift
//  Projector
//
//  Created by Serginjo Melnik on 06.01.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

extension CalendarViewController {
    //show events view
    func showUpEventsView(){
        
        blackView.frame = view.frame
    
        //70% of width
        let width = 80 * self.view.frame.width / 100
        
        
        self.eventElements.frame = CGRect(x: -self.view.frame.width, y: 0, width: width, height: self.view.frame.height)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 3.0, options: UIView.AnimationOptions.curveEaseInOut, animations: ({
            self.blackView.alpha = 1
            
            self.eventElements.frame = CGRect(x: 0, y: 0, width: self.eventElements.frame.width, height: self.eventElements.frame.height)
            
        }), completion: nil)
        
    }
    
    //dismiss black view
    @objc func handleDismiss(){
        UIView.animate(withDuration: 0.5) {
            //70% of screen width
            let width = 80 * self.view.frame.width / 100
            
            self.blackView.alpha = 0
            self.eventElements.frame = CGRect(x: -self.view.frame.width, y: 0, width: width, height: self.view.frame.height)
            //------------------------------------- improve needed --------------------------------------
            //because I want to have some kind of observer of whether an array was modified or not
            
            //Events data base for calendar
            self.assembleGroupedEvents()
            //day is need to be current everytime calendar appears &
            //as date is set, all updateAllPageElements calls
            self.baseDate = Date()
            
        }
    }
    
    //define data base for events collection view
    func eventsArrayFromDateKey(date: Date){
        //current date uses cells for sizes configuration
        eventElements.currentDate = date
        
        //clear view controller database
        eventElements.events.removeAll()
        
        //need this for side events panel date label
        let components = Calendar.current.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: date)
        if let day = components.day, let month = components.month, let year = components.year, let weekday = components.weekday {
            let weekDayString = dayOfWeekLetter(for: weekday)
            let monthStr = monthString(for: month)
            eventElements.selectedDateLabel.text = ("\(weekDayString) \(day) \(monthStr) \(year)")
            
            
            //check if user view different year from current
            if year != downloadedHolidaysYear{
                //calculate what is difference between year when holiday was downloaded and year thar user view
                let yearDifference =  downloadedHolidaysYear - year
                            
                let dateComponents = DateComponents(year: year + yearDifference , month: month, day: day)
                let holidayDate = calendar.date(from: dateComponents)
                
                if let unwrappedHolidayDate = holidayDate{
                    //loop through  array to find holiday in given day - month
                    groupedEventDictionary[unwrappedHolidayDate]?.forEach{
                        //pick only holidays in this day
                        if $0.category == "holiday"{
                            eventElements.events.append([$0])
                        }
                    }
                }
            }
        }
        
        //Add all other type of events (user event, step event)
        if let events = groupedEventDictionary[date] {
            
            var eventsByDate = [Event]()
            
            eventsByDate = events.sorted(by: { (a, b) in return a.date! < b.date! })
            
            //unite events by interval intersection
            let intersectedEvents = intersectEvents(events: eventsByDate)
            
            //append events new data
            eventElements.events.append(contentsOf: intersectedEvents)
        }
        
        //reload table view
        eventElements.eventsTableView.reloadData()
        
        //show view controller
        showUpEventsView()
    }
}



extension CalendarViewController{
    
    //unite events by date interval intersection
    func intersectEvents(events: [Event]) -> [[Event]] {
        //array of array to return
        var nestedArray: [[Event]] = [[]]
        //set contains event id
        var id = Set<String>()
        
        //holds united DateInterval for intersected events
        var commonDateInterval = DateInterval()
        //compactMap - because it can return nil
        nestedArray = events.compactMap{
            
            //check if id was in func before
            if id.contains($0.id){
                return nil
            }
            
            //insert current event id into used id's database
            id.insert($0.id)
            //unwrap optional
            guard let mapItemDateInterval = $0.eventDateInterval else {return nil}
            
            //common DateInteval for all intersected events
            commonDateInterval = mapItemDateInterval
            
            // .filter is looking for Bool condition to select item from "events" array
            let filteredArray = events.filter { item in
                guard let itemDateInterval = item.eventDateInterval else {return false}
                
                //check if commonDateInterval intersects with give event DateInterval (Bool)
                let dateIntersection = commonDateInterval.intersects(itemDateInterval)
                //confirm that DateIntervals intersects
                if dateIntersection == true{
                    //takes smallest start point
                    let start: Date = commonDateInterval.start > itemDateInterval.start ? itemDateInterval.start : commonDateInterval.start
                    //takes latest end point
                    let end: Date = commonDateInterval.end < itemDateInterval.end ? itemDateInterval.end : commonDateInterval.end
                    //every time it defines common DateInterval it becames larger to fully cover intersected events
                    commonDateInterval = DateInterval(start: start, end: end)
                    
                    //append id that is controlled for intersection
                    id.insert(item.id)
                }
                
                return dateIntersection
            }

            //Sort events by end time
            let sortedEvents = filteredArray.sorted(by: {(a, b) in
                guard let aEndTime = a.endTime, let bEndTime = b.endTime else {return a.title.count > b.title.count}
                return aEndTime < bEndTime
            })
            return sortedEvents
        }

        return nestedArray
    }
    
    private func dayOfWeekLetter(for dayNumber: Int) -> String {
        switch dayNumber {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return ""
        }
    }
    
    private func monthString(for monthNumber: Int) -> String {
        switch monthNumber {
        case 1:
            return "Jan"
        case 2:
            return "Feb"
        case 3:
            return "Mar"
        case 4:
            return "Apr"
        case 5:
            return "May"
        case 6:
            return "Jun"
        case 7:
            return "Jul"
        case 8:
            return "Aug"
        case 9:
            return "Sep"
        case 10:
            return "Oct"
        case 11:
            return "Nov"
        case 12:
            return "Dec"
        default:
            return ""
        }
    }

}
