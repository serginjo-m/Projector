//
//  StatisticsContainer.swift
//  Projector
//
//  Created by Serginjo Melnik on 20.07.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

//container for total category values
class StatisticContainer: UIView {
    let imageIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let categoryNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(image: String, categoryText: String, number: String, units: String) {
        super.init(frame: .zero)
        
        imageIcon.image = UIImage(named: image)
        categoryNameLabel.text = categoryText
        numberLabel.text = number + units
        //view configurations
        setupView()
    }
    
    func setupView(){
        addSubview(imageIcon)
        addSubview(categoryNameLabel)
        addSubview(numberLabel)
        
        imageIcon.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        imageIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        imageIcon.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        imageIcon.heightAnchor.constraint(equalToConstant: 54).isActive = true
        
        categoryNameLabel.topAnchor.constraint(equalTo: imageIcon.bottomAnchor, constant: 10).isActive = true
        categoryNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        categoryNameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        categoryNameLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        numberLabel.topAnchor.constraint(equalTo: categoryNameLabel.bottomAnchor, constant: 5).isActive = true
        numberLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        numberLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        numberLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

