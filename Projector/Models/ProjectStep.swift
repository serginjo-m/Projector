//
//  ProjectStep.swift
//  Projector
//
//  Created by Serginjo Melnik on 07.11.2019.
//  Copyright © 2019 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectStep: Object{
    
    //MARK: Properties
    @objc dynamic var name = ""
    
    
    @objc dynamic var category = "todo"
    @objc dynamic var section: StepWaySection?
    @objc dynamic var displayed = true
    @objc dynamic var comment = ""
    @objc dynamic var event: Event?
    @objc dynamic var complete = false
    @objc dynamic var date = "07/06/2020"
    
    
    //an array of images url
    var selectedPhotosArray = List<String>()//[String]()
    var selectedCanvasesArray = List<CanvasNote>()//[String]()
    
    //an array of items in table view
    var itemsArray = List<String>()
    var viewControllersStack = List<String>()
    //id
    @objc dynamic var id = UUID().uuidString
    
    override static func primaryKey() -> String {
        return "id"
    }

    override var description: String{
        return "\(name)"
    }
    
}

extension ProjectStep {
    var reminderEnabled: Bool? {
        if let event = self.event{
            if event.reminder != nil{
                return true
            }
        }
        return false
    }
}
