//
//  ProjectCell.swift
//  Projector
//
//  Created by Serginjo Melnik on 08/05/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import Foundation
import UIKit

class ProjectCell: UICollectionViewCell{
    
    //It'll be like a template for our cell
    var template: ProjectList? {
        //didSet uses for logic purposes!
        didSet{
            
            if let name = template?.name {
                projectName.text = name
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 8
        layer.masksToBounds = true
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    let projectName:UILabel = {
        let pn = UILabel()
        pn.text = "Travel to Europe on Motorcycle"
        pn.textAlignment = NSTextAlignment.left
        pn.font = UIFont.boldSystemFont(ofSize: 15)
        pn.textColor = UIColor.white
        pn.numberOfLines = 3
        return pn
    }()
    
    let projectImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "interior")
        image.contentMode = .scaleAspectFill
        return image
    }()
    //adds contrast to project title
    let gradient: CAGradientLayer =  {
        let gradient = CAGradientLayer()
        let topColor = UIColor.init(red: 1/255, green: 1/255, blue: 1/255, alpha: 0).cgColor//black transparent
        let middleColor = UIColor.init(red: 1/255, green: 1/255, blue: 1/255, alpha: 0.16).cgColor//black 16% opacity
        let bottomColor = UIColor.init(red: 2/255, green: 2/255, blue: 2/255, alpha: 0.56).cgColor//black 56% opacity
        gradient.colors = [topColor, middleColor, bottomColor]
        gradient.locations = [0.0, 0.5, 1.0]
        return gradient
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"projectRemoveButton"), for: .normal)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    func setupViews(){
        
        
        backgroundColor = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1)
        
        //deleteButton.frame = CGRect(x:frame.width - 25, y: 9, width:16, height: 16)
        
        addSubview(projectImage)
        addSubview(projectName)
        
        
        //gradient under project title
        layer.insertSublayer(gradient, at: 2)
        gradient.frame = CGRect(x: 0, y: 188, width: frame.width, height: frame.height - 188)
        
        addSubview(deleteButton)
        
        projectName.translatesAutoresizingMaskIntoConstraints = false
        projectImage.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        deleteButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 11).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -11).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        projectName.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        projectName.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 13).isActive = true
        projectName.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        projectName.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        projectImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        projectImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        projectImage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        projectImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
    }
}
