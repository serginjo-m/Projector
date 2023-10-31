//
//  UserActivity.swift
//  Projector
//
//  Created by Serginjo Melnik on 17.03.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class UserActivity: Object {
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var date: Date?
    @objc dynamic var descr = ""
    
    override static func primaryKey() -> String {
        return "id"
    }
}
