//
//  ProjectNumbersCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 30/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class ProjectNumbersCell: UICollectionViewCell {
    
    var configureCell: NumberCellSetting? {
        didSet{
            if let setting = configureCell{
                configureConstraints(width: setting.imageWidth, height: setting.imageHeight, top: setting.imageTopAnchor, left: setting.imageLeftAnchor)
                backgroundColor = setting.cellColor
                buttonTitleLabel.text = setting.buttonTitle
                buttonBackgroundImage.image = UIImage(named: setting.imageName)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let buttonTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(white: 1, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let buttonBackgroundImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "notes")
        return image
    }()
    
    let categoryValueTitle: UILabel = {
        let label = UILabel()
        label.text = "1234567"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    func setupViews(){
        
        layer.masksToBounds = true
        layer.cornerRadius = 8
        
        addSubview(buttonBackgroundImage)
        addSubview(buttonTitleLabel)
        addSubview(categoryValueTitle)
        
        
        buttonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryValueTitle.translatesAutoresizingMaskIntoConstraints = false
        
        buttonTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
        buttonTitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        buttonTitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        buttonTitleLabel.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        categoryValueTitle.bottomAnchor.constraint(equalTo: buttonTitleLabel.topAnchor, constant: 15).isActive = true
        categoryValueTitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        categoryValueTitle.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        categoryValueTitle.heightAnchor.constraint(equalToConstant: 43).isActive = true
    }
    
    func configureConstraints(width: CGFloat, height: CGFloat, top: CGFloat, left: CGFloat){
        buttonBackgroundImage.frame = CGRect(x: left, y: top, width: width, height: height)
    }
}

