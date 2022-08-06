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
                        let calendarViewController = (nav.viewControllers.first as? CalendarViewController)
                        if let calendarVC = calendarViewController {
                            //notification date
                            let notificationDate = calendar.startOfDay(for: eventDate)
                            //set notification date that should be displayed after VC did appear
                            calendarVC.dateToDisplay = notificationDate
                        }
                        
                    }
                }
                //switch to calendar
                tab.selectedIndex = 1
            }
            
        default:
            break
        }
    }
    
    //updates tab bar item & app icon badge number
    func updateTabBarItemBudge(applyBadge: Bool){

        if let window = UIApplication.shared.keyWindow {
                if let tabController = window.rootViewController as? UITabBarController{
                    if let tabItems = tabController.tabBar.items {
                        // In this case we want to modify the badge number of the fifth tab:
                        let tabItem = tabItems[4]
                        
                        //apply badge or remove?
                        if applyBadge{
                            tabItem.badgeValue = "1"
                        }else{
                            tabItem.badgeValue = nil
                            UIApplication.shared.applicationIconBadgeNumber = 0
                        }
                    }
                }
            }

    }
}
