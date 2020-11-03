//
//  CustomTabBarController.swift
//  Projector
//
//  Created by Serginjo Melnik on 31.10.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        viewControllers = [
            createNavControllerWithTitle(viewController: ProjectViewController(), title: "Home", imageName: "home"),
            createNavControllerWithTitle(viewController: UIViewController(), title: "Calendar", imageName: "calendarIcon"),
            createNavControllerWithTitle(viewController: CreateViewController(), title: "Add", imageName: "addButton"),
            createNavControllerWithTitle(viewController: UIViewController(), title: "Spendings", imageName: "money"),
            createNavControllerWithTitle(viewController: UIViewController(), title: "Notifications", imageName: "bell")
        ]
    }
    
    private func createNavControllerWithTitle(viewController: UIViewController, title: String, imageName: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: viewController)
        navController.setNavigationBarHidden(true, animated: false)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
    }
}
