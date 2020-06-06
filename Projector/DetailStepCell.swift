//
//  StepCollectionViewCell.swift
//  Projector
//
//  Created by Serginjo Melnik on 22.04.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit


class StepsCell: UICollectionViewCell{
    
    //initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let stepNameLabel: UILabel = {
        let label = UILabel()
        label.text = "some text"
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        
        label.textColor = UIColor.darkGray
        return label
    }()
    let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setTitleColor(UIColor(displayP3Red: 40/255, green: 114/255, blue: 70/255, alpha: 1), for: .selected)
        button.setBackgroundImage(UIImage(named: "doneNormal"), for: .normal)
        button.setBackgroundImage(UIImage(named: "doneSelected"), for: .selected)
        button.contentHorizontalAlignment = .right
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"removeStep"), for: .normal)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "interior")
        image.layer.cornerRadius = 27
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.borderWidth = 5
        image.layer.borderColor = UIColor(displayP3Red: 211/255, green: 211/255, blue: 211/255, alpha: 1).cgColor
        return image
    }()
    
    let gradientLayer: CAGradientLayer =  {
        let gradient = CAGradientLayer()
        let topColor = UIColor.white.cgColor
        let bottomColor = UIColor(white: 0.95, alpha: 1).cgColor
        gradient.colors = [topColor, bottomColor]
        gradient.locations = [0.0, 1.0]
        return gradient
    }()
    
    func setupViews(){
        
        //insert gradient
        layer.masksToBounds = true
        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        layer.borderWidth = 1
        layer.borderColor = UIColor(displayP3Red: 238/255, green: 238/255, blue: 238/255, alpha: 1).cgColor
        
        addSubview(stepNameLabel)
        addSubview(deleteButton)
        addSubview(doneButton)
        addSubview(imageView)
        
        deleteButton.frame = CGRect(x:frame.width - 25, y: 9, width:16, height: 16)
        stepNameLabel.frame = CGRect(x: 9, y: frame.height - 48, width: 149, height: 48)
        doneButton.frame = CGRect(x:10, y: 10, width: 64, height: 20)
        imageView.frame = CGRect(x: (frame.width - 74) / 2, y: (frame.height - 74) / 2, width: 74, height: 74)
    }
}

