//
//  DayActivity.swift
//  Projector
//
//  Created by Serginjo Melnik on 17.03.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//
import UIKit
import RealmSwift

class DayActivity: Object {
    
    @objc dynamic var id = UUID().uuidString
    
    // Date represents a given day in a month.
    @objc dynamic var date: String = " 1 Mar 2021"
    
    //an array of all user activities during the day
    let userActivities = List<UserActivity>()
    
    //MARK: Methods
    override static func primaryKey() -> String {
        return "id"
    }
}
