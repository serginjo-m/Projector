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
    @objc dynamic var date: String = " 1 Mar 2021"
    let userActivities = List<UserActivity>()
    
    override static func primaryKey() -> String {
        return "id"
    }
}
