//
//  ViewByCategoryCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class ViewByCategoryCell: UICollectionViewCell {
    
    var configureCell: CategoryButtonSetting? {
        didSet{
            if let setting = configureCell{
                
                //constraints func , because elements needs to be positioned differently
                configureConstraints(width: setting.imageWidth, height: setting.imageHeight, top: setting.imageTopAnchor, left: setting.imageLeftAnchor, titleLeft: setting.titleLeftAnchor)
                
                //background color
                backgroundColor = setting.cellColor
                
                //title
                buttonTitleLabel.text = setting.buttonTitle
                
                //image
                buttonBackgroundImage.image = UIImage(named: setting.imageName)
            }
        }
    }
    
    //initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        //layer.cornerRadius = 3
        //layer.masksToBounds = true
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let buttonTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(white: 1, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.numberOfLines = 0
        return label
    }()
    
    let buttonBackgroundImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "notes")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    func setupViews(){
        
        //mask content outside cell
        layer.masksToBounds = true
        layer.cornerRadius = 8
        
        addSubview(buttonTitleLabel)
        addSubview(buttonBackgroundImage)
        
        buttonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonBackgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func configureConstraints(width: CGFloat, height: CGFloat, top: CGFloat, left: CGFloat, titleLeft: CGFloat){
        buttonBackgroundImage.topAnchor.constraint(equalTo: topAnchor, constant: top).isActive = true
        buttonBackgroundImage.leftAnchor.constraint(equalTo: leftAnchor, constant: left).isActive = true
        buttonBackgroundImage.widthAnchor.constraint(equalToConstant: width).isActive = true
        buttonBackgroundImage.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        buttonTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        buttonTitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: titleLeft).isActive = true
        buttonTitleLabel.widthAnchor.constraint(equalToConstant: 71).isActive = true
        buttonTitleLabel.heightAnchor.constraint(equalToConstant: 33).isActive = true
    }
}
