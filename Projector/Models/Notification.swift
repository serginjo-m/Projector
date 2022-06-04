//
//  Notification.swift
//  Projector
//
//  Created by Serginjo Melnik on 11.08.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class Notification: Object, Codable, Identifiable {
    //New functionality added
    //---------------------------------------
    @objc dynamic var timeInterval: Double = 0.0
    @objc dynamic var reminderType: String = "calendar"//"time", "calendar", "location"
    // competition date
    @objc dynamic var eventDate: Date = Date()// <---- uses inside notification
    //is time included
    @objc dynamic var eventTime = false
    //date start point
    @objc dynamic var startDate = Date()
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var  radius: Double = 0.0
    @objc dynamic var repeats = false
    //---------------------------------------
    
    
    //notification title
    @objc dynamic var name = ""
    //object category
    @objc dynamic var category = ""
    //complete or not
    @objc dynamic var complete = false
    //link to project object
    @objc dynamic var projectId = ""
    //link to step object
    @objc dynamic var stepId = ""
    
    //id
    @objc dynamic var id = UUID().uuidString
    override static func primaryKey() -> String {
        return "id"
    }
    override var description: String{
        return "\(name)"
    }
}

struct Task: Codable, Identifiable {
    
    var reminder: Reminder
        
    var eventDate: Date
    
    var eventTime: Bool
    
    var startDate: Date
     
    //notification title
    var name: String
    //object category
    var category: String
    //complete or not
    var complete: Bool
    //link to project object
    var projectId: String
    //link to step object
    var stepId: String
    
    //id
    var id: String
}

struct Reminder: Codable {
  var timeInterval: TimeInterval?
  var date: Date?
  var location: LocationReminder?
  var reminderType: ReminderType = .time
  var repeats = false
}

struct LocationReminder: Codable {
  var latitude: Double
  var longitude: Double
  var radius: Double
}

enum ReminderType: Int, CaseIterable, Identifiable, Codable {
  case time
  case calendar
  case location
  var id: Int { self.rawValue }
}
