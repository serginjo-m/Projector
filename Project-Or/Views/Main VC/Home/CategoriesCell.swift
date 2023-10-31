//
//  CategoriesCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 30/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class CategoriesCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool{
        didSet{
            self.backgroundColor = UIColor.lightGray
        }
    }
    
    let cellLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.init(displayP3Red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
        return label
    }()

    func setupViews(){
        
        backgroundColor = UIColor.init(displayP3Red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
        layer.cornerRadius = 11
        
        addSubview(cellLabel)
        
        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cellLabel.topAnchor.constraint(equalTo: topAnchor, constant: 90).isActive = true
        cellLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        cellLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        cellLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
    }
    
}

