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
    
    //user name
    @objc dynamic var name = ""
    //user email
    @objc dynamic var email = ""
    //user password
    @objc dynamic var password = ""
    //user image
    @objc dynamic var imageString = ""
    //login
    @objc dynamic var isLogined = false
    //id
    @objc dynamic var id = UUID().uuidString
    
    
    override static func primaryKey() -> String {
        return "id"
    }
    override var description: String{
        return "\(name)"
    }
}

