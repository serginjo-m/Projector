//
//  BarChartView.swift
//  Projector
//
//  Created by Serginjo Melnik on 04.07.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class BarChartView: UIView{
    
    let barChartController = BarChartController(scrollDirection: .horizontal)
    lazy var barsContainerView: UIView = {
        let view = UIView()
        view.stack(NSLayoutConstraint.Axis.horizontal, views: barChartController.view, spacing: 0)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView(){
        addSubview(barsContainerView)
        barsContainerView.translatesAutoresizingMaskIntoConstraints = false
        barsContainerView.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





