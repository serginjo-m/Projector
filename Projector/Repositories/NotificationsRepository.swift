//
//  NotificationsRepository.swift
//  Projector
//
//  Created by Serginjo Melnik on 09/06/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import Foundation
import UIKit

class NotificationsRepository {
    
    static let shared = NotificationsRepository()//initializer

    //constructs views & VC architecture
    func configureVCStack(category: String, eventDate: Date, stepId: String? = nil, projectId: String? = nil){
        
        guard let window = UIApplication.shared.keyWindow else { return }
        //That is probably how I get all view controllers stack
        let controller = window.rootViewController
        let calendar = Calendar(identifier: .gregorian)
        switch category {
        case "step":
            if let tab = controller as? UITabBarController{
                if let first = tab.viewControllers?.first{
                    if let nav = first as? UINavigationController {
                        nav.viewControllers.removeAll()
                        let mainViewController = ProjectViewController()
                        nav.viewControllers.append(mainViewController)
                        let detailViewController = DetailViewController()
                        detailViewController.delegate = mainViewController
                        if let projectId = projectId {
                            detailViewController.projectListIdentifier = projectId
                        }
                        nav.viewControllers.append(detailViewController)
                        if let stepIdentifier = stepId, let projectIdentifier = projectId {
                            let stepViewController = StepViewController(stepId: stepIdentifier)
                            stepViewController.projectId = projectIdentifier
                            nav.viewControllers.append(stepViewController)
                        }
                        
                    }
                }
            }
            (window.rootViewController as? UITabBarController)?.selectedIndex = 0
        case "event":
            if let tab = controller as? UITabBarController{
                if let second = tab.viewControllers?[1]{
                    if let nav = second as? UINavigationController {
                        nav.viewControllers.removeAll()
                        let calendarViewController = CalendarViewController(baseDate: Date()) { date in
                            //maybe try to open sidebar
                            
                        }
                        //Events data base for calendar
                        calendarViewController.assembleGroupedEvents()
                        //day is need to be current everytime calendar appears &
                        //as date is set, all updateAllPageElements calls
                        calendarViewController.baseDate = Date()
                        calendarViewController.eventsArrayFromDateKey(date: calendar.startOfDay(for: eventDate))
                        nav.viewControllers.append(calendarViewController)
                    }
                }
            }
            (window.rootViewController as? UITabBarController)?.selectedIndex = 1
            
        default:
            break
        }
    }
    //updates tab bar item & app icon badge number
    func updateTabBarItemBudge(){
        //get a defaults category for notification count
        let defaults = UserDefaults(suiteName: "notificationsDefaultsBadgeCount")
        if let defaults = defaults {
            let count: Int = defaults.value(forKey: "count") as! Int
            
            if let window = UIApplication.shared.keyWindow {
                if let tabController = window.rootViewController as? UITabBarController{
                    if let tabItems = tabController.tabBar.items {
                        // In this case we want to modify the badge number of the fifth tab:
                        let tabItem = tabItems[4]
                        
                        if count <= 1 {
                            tabItem.badgeValue = nil
                            UIApplication.shared.applicationIconBadgeNumber = 0
                        }else{
                            tabItem.badgeValue = "\(count - 1)"
                            UIApplication.shared.applicationIconBadgeNumber = count - 1
                        }
                    }
                }
            }
        }
    }
}
