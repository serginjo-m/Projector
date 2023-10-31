//
//  ProjectList.swift
//  Projector
//
//  Created by Serginjo Melnik on 07.11.2019.
//  Copyright © 2019 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
import Photos

class ProjectList: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var category = ""
    @objc dynamic var selectedImagePathUrl: String?
    @objc dynamic var date = "07/06/2020"
    @objc dynamic var filterIsActive = false
    
    let projectStep = List<ProjectStep>()
    var projectStatistics = List<StatisticData>()
    
    override static func primaryKey() -> String {
        return "id"
    }
    override var description: String{
        return "This Value is Changing by Complete Function \(filterIsActive)"
    }
}
