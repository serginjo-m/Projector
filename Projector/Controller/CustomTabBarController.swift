//
//  CustomTabBarController.swift
//  Projector
//
//  Created by Serginjo Melnik on 31.10.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
//Bottom Navigation
class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    //------------------------under construction var -----------------------
    //date as a start point for calendar
    let date = Date()
    
    //list of holidays received from server
    var listOfHolidays = [HolidayDetail](){
        didSet{
            //Dispatch, so it works indipendently and not slow down all app
            DispatchQueue.main.async {
                //creates grouped holidays dictionary
                self.convertHolidaysToEvents()
            }
        }
    }
    
    //---------------------------------------------------------------------------------------------
    //get ALL events, for checking, is data base contain previously downloaded holidays from server
    var events: Results<Event>{
        get{
            return ProjectListRepository.instance.getEvents()
        }
        set{
            //update?
        }
    }
    
    override func viewDidLoad() {
        
        //------------------------- optimization needed -------------------------------------------
        //check if holiday data was downloaded
        downloadHolidayEvents()
        
        self.delegate = self
        
        viewControllers = [
            createNavControllerWithTitle(viewController: ProjectViewController(), title: "Home", imageName: "home"),
            createCalendarViewController(),
            createNavControllerWithTitle(viewController: NewProjectViewController(), title: "Add", imageName: "addButton"),
            
            //with this type of init I can pass different type of layout (Pinterest or default)
            createNavControllerWithTitle(viewController: StatisticsViewController(), title: "Spendings", imageName: "money"),
            createNavControllerWithTitle(viewController: NotificationsViewController(), title: "Notifications", imageName: "bell")
        ]
    }
    
    //Build Calendar and then calls create nav controller
    private func createCalendarViewController() -> UINavigationController {
        let calendarViewController = CalendarViewController(baseDate: date) { (date) in
            
            //Do Nothing here !!
            //So maybe modify logic ?
        }
        return createNavControllerWithTitle(viewController: calendarViewController, title: "Calendar", imageName: "calendarIcon")
    }
    
    //Template for navigation items
    private func createNavControllerWithTitle(viewController: UIViewController, title: String, imageName: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: viewController)
        navController.setNavigationBarHidden(true, animated: false)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
    }
    
   
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        //get index of selected value
        guard let index = viewControllers?.index(of: viewController) else {
            return false
        }
        
        // index == 2 corresponds to add button
        if index == 2 {
            
            //get current visualized view controller
            guard let currentViewController = (self.selectedViewController as! UINavigationController).topViewController else {return false}
            
            //class identifier for logic purposes
            var lastVCClass: String = ""
            
            //base for switch cases logic
            lastVCClass = "\(currentViewController.classForCoder)"
        
            func configureAddItemAction(newObjectVC: [String: UIViewController]){
                
                
                //get my add items nav view controller for setting its stack view controllers in func
               // let targetNavController = viewController as! UINavigationController
                
                //ALERT MENU
                let alert = UIAlertController(title: "Select Creation Type", message: "Please select the desired creation type", preferredStyle: .actionSheet)
                
                
                for (key, value) in newObjectVC {
                    let action = UIAlertAction(title: key, style: .default) { (action: UIAlertAction) in
                        self.present(value, animated: true, completion: nil)
                    }
                    
                    alert.addAction(action)
                }
                
                let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
                    // Do nothing
                }
                
                
                alert.addAction(action3)
                
                present(alert, animated: true, completion: nil)
            }
            
            //perform logic based on last visualized view controller class
            switch lastVCClass {
                case "DetailViewController":
                    
                    guard let detailVC = currentViewController as? DetailViewController else {return false}
                    
                    //because case: DetailViewController, I can access it property for adding or modification
                    //let currentViewControllerId = ((self.selectedViewController as! UINavigationController).topViewController as! DetailViewController).projectListIdentifier ?? ""
                    
                    let newStep = NewStepViewController()
                    newStep.uniqueID = detailVC.projectListIdentifier
                    
                    newStep.delegate = detailVC
                    
                    let viewControllers = [
                        "Create New Step": newStep
                    ]
                    
                    configureAddItemAction(newObjectVC: viewControllers)
            
                case "ProjectViewController":
                    
                    guard let  projectVC = currentViewController as? ProjectViewController else {return false}
                    //because new project view controller need preconfiguration
                    //create it out of Dictionary
                    let newProjectViewController = NewProjectViewController()
                     //want to transfer some data
                    newProjectViewController.projectCV = projectVC.projectsCollectionView
                    
                    //Dictionary ["view controller name" : viewController]
                    let viewControllers = [
                        "New Project": newProjectViewController,
                        "Qiuck Camera Note": CameraShot(),
                        "Qiuck Picture Note": CanvasViewController(),
                        "Qiuck Text Note": TextNoteViewController()
                    ]
                    
                    //configure appearance
                    for (_, value) in viewControllers{
                        value.modalTransitionStyle = .coverVertical
                        value.modalPresentationStyle = .overCurrentContext
                    }
                    
                
                    configureAddItemAction(newObjectVC: viewControllers)
                
                case "StepViewController":
                
                    guard let stepVC = currentViewController as? StepViewController else {return false}
                
                    let newStepItemViewController = StepItemViewController()
                    newStepItemViewController.stepID = stepVC.stepID
                    newStepItemViewController.stepItemsTableView = stepVC.stepTableView
                    
                    let viewControllers = [
                        "Create Step Item" : newStepItemViewController
                    ]
                    
                    configureAddItemAction(newObjectVC: viewControllers)
                
                case "CalendarViewController":
                
                    let viewControllers = [
                        "Create New Event": NewEventViewController()
                    ]
                    
                    configureAddItemAction(newObjectVC: viewControllers)
                
                default:
                    
                    break
            }
            
            return false
        }
        return true
    }
    
}

extension CustomTabBarController {
    
    //-------------------------- need to find a better way to do this check --------------------------------
    //check if holiday objects was downloaded
    func downloadHolidayEvents() {
        var holidayArr = [Event]()
        
        events.forEach{
            if let category = $0.category{
                if category == "holiday"{
                    holidayArr.append($0)
                }
            }
        }
        //if no holiday events was founded, send a request to server
        if holidayArr.count == 0{
            getHolidayResults()
        }
    }
    
        
    func getHolidayResults() {
    
        let holidayRequest = HolidayRequest(countryCode: "IT")//Italian Holidays
        holidayRequest.getHolidays {[weak self] result in//weak self prevent any retain cycles
            self?.listOfHolidays = result
        }
    }
    
    //convert Holiday obj to Event obj
    func convertHolidaysToEvents(){
        self.listOfHolidays.forEach{
            let holidayEvent = Event()
            holidayEvent.category = "holiday"
            holidayEvent.title = $0.name
            holidayEvent.date = $0.date.datetime.dateObject
            holidayEvent.descr = $0.description
            ProjectListRepository.instance.createEvent(event: holidayEvent)
        }
    }
}
