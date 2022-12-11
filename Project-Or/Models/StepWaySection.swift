//
//  StepWaySection.swift
//  Projector
//
//  Created by Serginjo Melnik on 05/10/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class StepWaySection: Object {
    
    @objc dynamic var id = UUID().uuidString
    
    //Description
    @objc dynamic var name = ""
    @objc dynamic var indexNumber = 0
    @objc dynamic var projectId = ""
    
    //MARK: Methods
    override static func primaryKey() -> String {
        return "id"
    }
}
