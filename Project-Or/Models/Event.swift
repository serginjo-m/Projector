//
//  Event.swift
//  Projector
//
//  Created by Serginjo Melnik on 27.12.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class Event: Object, Identifiable, Codable{
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var date: Date?
    @objc dynamic var startTime: Date?
    @objc dynamic var endTime: Date?
    @objc dynamic var descr: String?
    @objc dynamic var category: String?
    @objc dynamic var stepId: String?
    @objc dynamic var projectId: String?
    @objc dynamic var reminder: Notification?
    @objc dynamic var picture: String?

    override static func primaryKey() -> String {
        return "id"
    }
}

extension Event {
    
    var eventTimeInterval: TimeInterval? {
        guard let date = date, let endTime = endTime else {return TimeInterval()}
        return endTime.timeIntervalSince(date)
    }
    
    var eventDateInterval: DateInterval? {
        guard let date = date, let endTime = endTime else {return DateInterval()}
        return DateInterval(start: date, end: endTime)
    }
}
