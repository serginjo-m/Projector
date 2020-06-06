//
//  ClosureViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 24.05.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit

class ClosureViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        var myValue = filterGreaterThanValue(number: 5, numbers: [1, 2, 3, 4, 5, 10])
        print(myValue as Any)
    }
    
    func filterGreaterThanValue(number: Int, numbers: [Int]) -> [Int] {
        return []
    }
    
    
}
