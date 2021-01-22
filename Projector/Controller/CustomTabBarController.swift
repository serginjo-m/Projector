//
//  CustomTabBarController.swift
//  Projector
//
//  Created by Serginjo Melnik on 31.10.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
//Bottom Navigation
class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    //------------------------under construction var -----------------------
    //date as a start point for calendar
    let date = Date()
    
    override func viewDidLoad() {
        
        self.delegate = self
        
        viewControllers = [
            createNavControllerWithTitle(viewController: ProjectViewController(), title: "Home", imageName: "home"),
            createCalendarViewController(),
            createNavControllerWithTitle(viewController: NewProjectViewController(), title: "Add", imageName: "addButton"),
            createNavControllerWithTitle(viewController: UIViewController(), title: "Spendings", imageName: "money"),
            createNavControllerWithTitle(viewController: UIViewController(), title: "Notifications", imageName: "bell")
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
        
            func configureAddItemAction(newObjectVC: UIViewController){
                
                
                //get my add items nav view controller for setting its stack view controllers in func
               // let targetNavController = viewController as! UINavigationController
                
                //ALERT MENU
                let alert = UIAlertController(title: "Select Creation Type", message: "Please select the desired creation type", preferredStyle: .actionSheet)
                
                let action1 = UIAlertAction(title: "Quick Create", style: .default) { (action:UIAlertAction) in
                    self.present(newObjectVC, animated: true, completion: nil)
                    //targetNavController.setViewControllers([newObjectVC], animated: false)
                    //tabBarController.selectedIndex = 2
                }
                
                let action2 = UIAlertAction(title: "Full Create", style: .default) { (action:UIAlertAction) in
                    self.present(newObjectVC, animated: true, completion: nil)
                    //targetNavController.setViewControllers([newObjectVC], animated: false)
                    //tabBarController.selectedIndex = 2
                }
                
                let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
                    // Do nothing
                }
                
                alert.addAction(action1)
                alert.addAction(action2)
                alert.addAction(action3)
                
                present(alert, animated: true, completion: nil)
            }
            
            //perform logic based on last visualized view controller class
            switch lastVCClass {
                case "DetailViewController":
                    
                    guard let detailVC = currentViewController as? DetailViewController else {return false}
                    
                    //becouse case: DetailViewController, I can access it property for adding or modification
                    //let currentViewControllerId = ((self.selectedViewController as! UINavigationController).topViewController as! DetailViewController).projectListIdentifier ?? ""
                    
                    let controller = NewStepViewController()
                    controller.uniqueID = detailVC.projectListIdentifier
                    controller.stepsCV = detailVC.stepsCollectionView
                    //----------------------------------------------------------------------------------------------
                    controller.delegate = detailVC
                    configureAddItemAction(newObjectVC: controller)
            
                case "ProjectViewController":
                    
                    guard let  projectVC = currentViewController as? ProjectViewController else {return false}
                    
                    let newProjectViewController = NewProjectViewController()
                    
                    newProjectViewController.modalTransitionStyle = .coverVertical
                    newProjectViewController.modalPresentationStyle = .overCurrentContext
                     //want to transfer some data
                    newProjectViewController.projectCV = projectVC.projectsCollectionView
                    configureAddItemAction(newObjectVC: newProjectViewController)
                
                case "StepViewController":
                
                    guard let stepVC = currentViewController as? StepViewController else {return false}
                
                    let newStepItemViewController = StepItemViewController()
                    newStepItemViewController.stepID = stepVC.stepID
                    newStepItemViewController.stepItemsTableView = stepVC.stepTableView
                    configureAddItemAction(newObjectVC: newStepItemViewController)
                
                case "CalendarViewController":
                
                    let newEventItemViewController = NewEventViewController()
//                    newEventItemViewController.modalPresentationStyle = .overCurrentContext
                    
                    configureAddItemAction(newObjectVC: newEventItemViewController)
                
                default:
                    
                    break
            }
            
            return false
        }
        return true
    }
    
}
