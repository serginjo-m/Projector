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
    //id
    @objc dynamic var id = UUID().uuidString
    //project name
    @objc dynamic var name = ""
    //project category
    @objc dynamic var category = ""
    //project main image
    @objc dynamic var selectedImagePathUrl: String?
    //created
    @objc dynamic var date = "07/06/2020"
    //complete button
    @objc dynamic var complete = false
    
    //project step objects
    let projectStep = List<ProjectStep>()//[ProjectStep]() - obj
    //statistic data objects
    var projectStatistics = List<StatisticData>()
    
    //MARK: Methods
    override static func primaryKey() -> String {
        return "id"
    }
    
    override var description: String{
        return "This Value is Changing by Complete Function \(complete)"
    }
}
