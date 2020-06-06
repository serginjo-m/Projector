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
    
    //MARK: Properties
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var category = ""
    @objc dynamic var distance = 1
    @objc dynamic var selectedImagePathUrl: String?
    @objc dynamic var comment = ""
    @objc dynamic var progress: Float {
        //full progress of progressView
        let achievedProject: Float = 1.0
        //find how many parts to achieve in project
        let numberOfStepsInProject = Float(steps)
        // counter for completed steps
        var completedStepsInProject: Float = 0.0
        //Won't divide by 0
        if steps > 0 {
            //calculating number of completed steps in project
            for item in projectStep {
                if item.complete == true {
                    completedStepsInProject += 1.0
                }
            }
            //calculate completed percentage
            let completedPercentage = (achievedProject / numberOfStepsInProject) * completedStepsInProject
            return completedPercentage
        }
        return completedStepsInProject
    }
    
    @objc dynamic var steps: Int {
        get{
            return projectStep.count
        }
    }
    
    @objc dynamic var complete: Bool {
        get{
            // if there is no items return false
            if projectStep.count == 0{
                return false
            }
            //loop through items & searching for complete false
            for prjS in projectStep {
                if !prjS.complete {
                    return false
                }
            }
            return true
        }
    }
    
    //finance variables.
    @objc dynamic var budget = 1
    @objc dynamic var totalCost = 0 // 123 / 123 format
    @objc dynamic var spending = 1

    let projectStep = List<ProjectStep>() //[ProjectStep]() - obj
    
    //MARK: Methods
    override static func primaryKey() -> String {
        return "id"
    }
    
    override var description: String{
        return "This Value is Changing by Complete Function \(complete)"
    }
}
