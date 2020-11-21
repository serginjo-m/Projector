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
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textColor = UIColor.white
        return label
    }()
    let doneButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "undone"), for: .normal)
        button.setBackgroundImage(UIImage(named: "done"), for: .selected)
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
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    //adds contrast to project title
    let gradient: CAGradientLayer =  {
        let gradient = CAGradientLayer()
        let topColor = UIColor.init(red: 1/255, green: 1/255, blue: 1/255, alpha: 0).cgColor//black transparent
        let middleColor = UIColor.init(red: 1/255, green: 1/255, blue: 1/255, alpha: 0.21).cgColor//black 16% opacity
        let bottomColor = UIColor.init(red: 2/255, green: 2/255, blue: 2/255, alpha: 0.56).cgColor//black 56% opacity
        gradient.colors = [topColor, middleColor, bottomColor]
        gradient.locations = [0.55, 0.75, 1.0]
        return gradient
    }()
    func setupViews(){
        
        //insert gradient
        layer.masksToBounds = true
        

        addSubview(imageView)
        addSubview(deleteButton)
        addSubview(doneButton)
        addSubview(stepNameLabel)
        
        deleteButton.frame = CGRect(x:frame.width - 25, y: 9, width:16, height: 16)
        stepNameLabel.frame = CGRect(x: 9, y: frame.height - 48, width: 149, height: 48)
        doneButton.frame = CGRect(x:10, y: 10, width: 20, height: 20)
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        //gradient
        imageView.layer.insertSublayer(gradient, at: 0)
        gradient.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
}

