//
//  StatisticsVC.swift
//  Projector
//
//  Created by Serginjo Melnik on 04.07.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import Realm

class StatisticsViewController: UIViewController{
    
    let barChartView = BarChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(barChartView)
        
        setupConstraints()
    }
    
    private func setupConstraints(){
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        
        barChartView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        barChartView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        barChartView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        barChartView.heightAnchor.constraint(equalToConstant: 182).isActive = true
    }
}
