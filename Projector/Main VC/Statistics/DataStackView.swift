//
//  DataStackView.swift
//  Projector
//
//  Created by Serginjo Melnik on 22.06.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

//Contain counting values and they description
class DataStackView: UIStackView {
    //Category
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.init(red: 104/255, green: 104/255, blue: 104/255, alpha: 1)
        return label
    }()
    // color of shape
    let circleImage: UIImageView = {
        let image = UIImageView()
        return image
    }()
    // actual value
    var countingLabel: CountingLabel?
    
    //MARK: Initialization
    init(frame: CGRect, dataCategory: String, startValue: Double, actualValue: Double, animationDuration: Double, imageName: String, units: String) {
        self.categoryLabel.text = dataCategory
        self.circleImage.image = UIImage(named: imageName)
        self.countingLabel = CountingLabel(startValue: startValue, actualValue: actualValue, animationDuration: animationDuration, units: units)
        super.init(frame: frame)
        setupStackView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
    }
    
    func setupStackView(){
        //unwrap optional animating number
        guard let animNumber = countingLabel else { return }
        animNumber.font = UIFont.boldSystemFont(ofSize: 20)
        animNumber.textAlignment = .left
        addSubview(categoryLabel)
        addSubview(animNumber)
        addSubview(circleImage)
        
        //Constraints
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        animNumber.translatesAutoresizingMaskIntoConstraints = false
        circleImage.translatesAutoresizingMaskIntoConstraints = false
        
        animNumber.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 0).isActive = true
        animNumber.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        animNumber.widthAnchor.constraint(equalToConstant: 105).isActive = true
        animNumber.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        circleImage.centerYAnchor.constraint(equalTo: animNumber.centerYAnchor, constant: 0).isActive = true
        circleImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        circleImage.widthAnchor.constraint(equalToConstant: 8).isActive = true
        circleImage.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        categoryLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        categoryLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        categoryLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        categoryLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
}

