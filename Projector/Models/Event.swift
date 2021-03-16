//
//  Event.swift
//  Projector
//
//  Created by Serginjo Melnik on 27.12.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class Event: Object {
    
    @objc dynamic var id = UUID().uuidString
    
    //Event title
    @objc dynamic var title: String = ""
    
    // Date represents a given day in a month.
    @objc dynamic var date: Date?
    
    //Description
    @objc dynamic var descr: String?
    
    //Type of event
    @objc dynamic var category: String?
    
    //becouse Realm is not support UIImages type
    @objc dynamic var picture: String?
    
    //MARK: Methods
    override static func primaryKey() -> String {
        return "id"
    }
}