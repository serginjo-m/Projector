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
    func showUpEventsView(){
        
        blackView.frame = view.frame
        let width = 80 * self.view.frame.width / 100
        self.eventElements.frame = CGRect(x: -self.view.frame.width, y: 0, width: width, height: self.view.frame.height)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 3.0, options: UIView.AnimationOptions.curveEaseInOut, animations: ({
            self.blackView.alpha = 1
            
            self.eventElements.frame = CGRect(x: 0, y: 0, width: self.eventElements.frame.width, height: self.eventElements.frame.height)
            
        }), completion: nil)
        
    }
    
    @objc func handleDismiss(){
        UIView.animate(withDuration: 0.5) {
            let width = 80 * self.view.frame.width / 100
            self.blackView.alpha = 0
            self.eventElements.frame = CGRect(x: -self.view.frame.width, y: 0, width: width, height: self.view.frame.height)
            self.assembleGroupedEvents()
            self.baseDate = Date()
        }
    }
    
    func eventsArrayFromDateKey(date: Date){
        updateCalendarContent(date: date)
        showUpEventsView()
    }
    
    func updateCalendarContent(date: Date){
        eventElements.currentDate = date
        eventElements.events.removeAll()
        let components = Calendar.current.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: date)
        guard let day = components.day,
              let month = components.month,
              let year = components.year,
              let weekday = components.weekday else {return}
        
        let weekDayString = dayOfWeekLetter(for: weekday)
        let monthStr = monthString(for: month)
        eventElements.selectedDateLabel.text = ("\(weekDayString) \(day) \(monthStr) \(year)")
        let yearDifference =  downloadedHolidaysYear - year
        let dateComponents = DateComponents(year: year + yearDifference , month: month, day: day)
        let holidayDate = calendar.date(from: dateComponents)
        
        var eventsByDate = [Event]()
        
        if year != downloadedHolidaysYear{
            
            if let unwrappedHolidayDate = holidayDate{
        
                let holidayEvents = checkForHoliday(holidayDate: unwrappedHolidayDate, currentDate: date)
                
                if holidayEvents.isEmpty == false {
                    
                    eventsByDate.append(contentsOf: holidayEvents)
                }
            }
        }

        if let events = groupedEventDictionary[date] {

            eventsByDate.append(contentsOf: events)
        }
            
        eventsByDate = eventsByDate.sorted(by: { (a, b) in return a.date! < b.date! })

        let intersectedEvents = intersectEvents(events: eventsByDate)

        eventElements.events.append(contentsOf: intersectedEvents)

        eventElements.eventsTableView.reloadData()
    }
    
    private func checkForHoliday(holidayDate: Date, currentDate: Date) -> [Event] {
        
        var events = [Event]()
        
                groupedEventDictionary[holidayDate]?.forEach{
        
                    if $0.category == "holiday"{
                        
                        let event = Event()
                        
                        event.id = $0.id
                        event.title = $0.title
                        event.descr = $0.descr
                        event.date = currentDate
                        event.startTime = currentDate
                        var dayComponent = DateComponents()
                        dayComponent.day = 1
                        dayComponent.second = -1
                        let theCalendar = Calendar.current
                        
                        let nextDay = theCalendar.date(byAdding: dayComponent, to: currentDate)
                        event.endTime = nextDay
                        event.category = $0.category
                        event.stepId = $0.stepId
                        event.projectId = $0.projectId
                        event.reminder = $0.reminder
                        event.picture = $0.picture
                        
                        events.append(event)
                    }
                }

        return events
    }
}

extension CalendarViewController{
 
    func intersectEvents(events: [Event]) -> [[Event]] {
    
        var nestedArray: [[Event]] = [[]]
        var id = Set<String>()
        var commonDateInterval = DateInterval()
        nestedArray = events.compactMap{
            
            if id.contains($0.id){
                return nil
            }
            
            id.insert($0.id)
            
            guard let mapItemDateInterval = $0.eventDateInterval else {return nil}
            commonDateInterval = mapItemDateInterval

            let filteredArray = events.filter { item in
                guard let itemDateInterval = item.eventDateInterval else {return false}
                
                let dateIntersection = commonDateInterval.intersects(itemDateInterval)
                
                if dateIntersection == true{
                
                    let start: Date = commonDateInterval.start > itemDateInterval.start ? itemDateInterval.start : commonDateInterval.start
                    
                    let end: Date = commonDateInterval.end < itemDateInterval.end ? itemDateInterval.end : commonDateInterval.end
                    
                    commonDateInterval = DateInterval(start: start, end: end)
                    
                    id.insert(item.id)
                }
                
                return dateIntersection
            }

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
