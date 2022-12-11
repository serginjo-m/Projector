//
//  DetailViewPanelExtension.swift
//  Projector
//
//  Created by Serginjo Melnik on 27.01.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

extension DetailViewController {
    
    //show events view
    func showStatisticsDetail(){
        
        //70% of width
        let width = 70 * self.view.frame.width / 100
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 3.0, options: UIView.AnimationOptions.curveEaseInOut, animations: ({
            self.blackView.alpha = 1
            
            self.sideView.frame = CGRect(x: 0, y: 0, width: width, height: self.view.frame.height)
            
        }), completion: nil)
        
    }
    
    //dismiss black view
    @objc func handleDismiss(){
        //reload project details numbers cv
        self.projectNumbersCV.defineProjectsValues()
        self.projectNumbersCV.projectNumbersCollectionView.reloadData()
        
        UIView.animate(withDuration: 0.5) {
            //70% of screen width
            let width = 70 * self.view.frame.width / 100
            
            self.blackView.alpha = 0
            self.sideView.frame = CGRect(x: -self.view.frame.width, y: 0, width: width, height: self.view.frame.height)
        }
    }
}
