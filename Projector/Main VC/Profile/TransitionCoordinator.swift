//
//  TransitionCoordinator.swift
//  Projector
//
//  Created by Serginjo Melnik on 19/03/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit
//animation object
class TransitionCoordinator: NSObject, UINavigationControllerDelegate {
   //look at which view controller it’s moving from, along with the one it’s moving to and return an appropriate animation object for the pair
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //return new transition type
        return CircularTransition()
    }
}
