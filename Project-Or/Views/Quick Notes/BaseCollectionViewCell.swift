//
//  BaseCollectionViewCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 29/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class BaseCollectionViewCell<U>: UICollectionViewCell {
    
    var delegate: BaseCollectionViewDelegate?
    
    var item: U!
    
    lazy var menuButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.init(white: 217/255, alpha: 1)
        button.layer.cornerRadius = 10
        button.setImage(UIImage(named: "horizontal_dots"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .center
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(menuButton)
        
        menuButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        menuButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        menuButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7).isActive = true
        menuButton.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
    }
    
}

