//
//  ProgressWidgetCategoryView.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 30/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class ProgressWidgetCategoryView: UIView {
    
    var sectionValueWidthConstraint: NSLayoutConstraint!
    
    var sectionValueNumber = 0 {
        didSet{
            self.sectionValue.labelDisplayLink?.actualValue = Double(sectionValueNumber)
            
            if self.sectionValueNumber < 10 {
                sectionValueWidthConstraint.constant = 14
            }else if self.sectionValueNumber > 9 {
                sectionValueWidthConstraint.constant = 24
            }else if self.sectionValueNumber > 99 {
                sectionValueWidthConstraint.constant = 34
            }
        }
    }
    
    let sectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "TODO:"
        return label
    }()
    
    let sectionValue: CountingLabel = {
        let label = CountingLabel(startValue: 0, actualValue: 0, animationDuration: 2)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "14"
        return label
    }()
    
    var valueBackgroundShape: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = .systemTeal
        return view
    }()
    
    
    init(title: String, color: UIColor, frame: CGRect) {
        super.init(frame: frame)
        
        sectionLabel.text = title
        valueBackgroundShape.backgroundColor = color

        addSubview(sectionLabel)
        addSubview(valueBackgroundShape)
        addSubview(sectionValue)
        
        sectionLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        sectionLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        sectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        sectionLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6).isActive = true
        
        sectionValue.leadingAnchor.constraint(equalTo: sectionLabel.trailingAnchor, constant: 15).isActive = true
        sectionValue.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sectionValue.heightAnchor.constraint(equalToConstant: 14).isActive = true
        sectionValueWidthConstraint = sectionValue.widthAnchor.constraint(equalToConstant: 14)//10
        sectionValueWidthConstraint.isActive = true
        
        valueBackgroundShape.centerYAnchor.constraint(equalTo: sectionValue.centerYAnchor).isActive = true
        valueBackgroundShape.centerXAnchor.constraint(equalTo: sectionValue.centerXAnchor).isActive = true
        valueBackgroundShape.widthAnchor.constraint(equalTo: sectionValue.widthAnchor, constant: 10).isActive = true
        
        valueBackgroundShape.heightAnchor.constraint(equalTo: sectionValue.heightAnchor, constant: 10).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

