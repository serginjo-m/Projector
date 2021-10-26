//
//  EditViewControllerDelegate.swift
//  Projector
//
//  Created by Serginjo Melnik on 14.10.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import Foundation
import UIKit

//Many protocols in app? is it good? ---------------------------------------
//reload views after changings(add or edit object)
protocol EditViewControllerDelegate: class{
    // assign all necessary data to objects  in detailVC
    func performAllConfigurations()
    //reload mainVC TV & detailVC CV after make changes to stepsCV
    func reloadViews()
}

