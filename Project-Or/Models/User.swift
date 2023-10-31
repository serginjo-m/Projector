//
//  User.swift
//  Projector
//
//  Created by Serginjo Melnik on 10.10.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//


import UIKit
import RealmSwift

class User: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var email = ""
    @objc dynamic var password = ""
    @objc dynamic var imageString = ""
    @objc dynamic var isLogined = false
    @objc dynamic var id = UUID().uuidString
    
    override static func primaryKey() -> String {
        return "id"
    }
    override var description: String{
        return "\(name)"
    }
}

