//
//  Notification.swift
//  Projector
//
//  Created by Serginjo Melnik on 11.08.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class Notification: Object {
    
    //MARK: Properties
    
    //notification title
    @objc dynamic var name = ""
    //object category
    @objc dynamic var category = ""
    //complete or not
    @objc dynamic var complete = false
    // competition date
    @objc dynamic var eventDate: Date = Date()
    //date start point
    @objc dynamic var startDate = Date()
    
    
    
    
    
    //id
    @objc dynamic var id = UUID().uuidString
    override static func primaryKey() -> String {
        return "id"
    }
    override var description: String{
        return "\(name)"
    }
    
    
}
