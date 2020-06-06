//
//  ProjectStep.swift
//  Projector
//
//  Created by Serginjo Melnik on 07.11.2019.
//  Copyright © 2019 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectStep: Object {
    
    //MARK: Properties
    @objc dynamic var name = ""
    @objc dynamic var cost = 0
    @objc dynamic var category = "Other"
    @objc dynamic var distance = 0
    //an array of images url
    let selectedPhotosArray = List<String>()//[String]()
    //an array of items in table view
    let itemsArray = List<String>()
    //id
    @objc dynamic var id = UUID().uuidString
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    @objc dynamic var complete = false
    override var description: String{
        return "\(name)"
    }
    
}
