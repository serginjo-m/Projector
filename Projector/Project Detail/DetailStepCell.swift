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
        image.contentMode = .scaleAspectFit
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
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //calculation is so slow, not very happy with that
        //NEED TO IMPROVE IT!!!!!
        gradient.frame = self.bounds
    }
    
    func setupViews(){
        
        //insert gradient
        layer.masksToBounds = true
        backgroundColor = .brown

        addSubview(imageView)
        addSubview(deleteButton)
        addSubview(doneButton)
        addSubview(stepNameLabel)
        imageView.layer.insertSublayer(gradient, at: 0)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        stepNameLabel.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        stepNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        stepNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 9).isActive = true
        stepNameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -9).isActive = true
        stepNameLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: 9).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -9).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        doneButton.topAnchor.constraint(equalTo: topAnchor, constant: 9).isActive = true
        doneButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 9).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
}

