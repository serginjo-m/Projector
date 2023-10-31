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
    @objc dynamic var timeInterval: Double = 0.0
    @objc dynamic var reminderType: String = "calendar"
    
    @objc dynamic var eventDate: Date = Date()
    
    @objc dynamic var eventTime = false
    
    @objc dynamic var startDate = Date()
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var  radius: Double = 0.0
    @objc dynamic var repeats = false
    @objc dynamic var name = ""
    
    @objc dynamic var category = ""
    
    @objc dynamic var complete = false
    
    @objc dynamic var projectId = ""
    
    @objc dynamic var stepId = ""
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
     
    var name: String
    var category: String
    var complete: Bool
    var projectId: String
    var stepId: String
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
