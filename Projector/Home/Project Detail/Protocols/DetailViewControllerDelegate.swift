//
//  DetailViewControllerDelegate.swift
//  Projector
//
//  Created by Serginjo Melnik on 14.10.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import Foundation
import UIKit
//calls functions from MainViewController
protocol DetailViewControllerDelegate: AnyObject {
    //this function is reload mainVC project data
    func reloadTableView()//<----------------- this is the first target
    //General func for retreaving image by URL (BECAUSE Realm can't save images)
    func retreaveImageForProject(myUrl: String) -> UIImage//<------- ImageView has an extension for this! Even with cache
    //access nav controller for segue
    func pushToViewController(controllerType: Int)
}
