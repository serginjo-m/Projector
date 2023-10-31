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
    
    var template: ProjectList? {
        didSet{
            if let name = template?.name {
               
                let rectangle = NSString(string: name).boundingRect(with: CGSize(width: self.frame.width - CGFloat(26), height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)], context: nil)

                let rect = CGRect(x: rectangle.origin.x, y: rectangle.origin.y, width: rectangle.width.rounded(.awayFromZero), height: rectangle.height.rounded(.awayFromZero))
                
                projectTitleAnchor.constant = rect.height
                projectName.text = name
                titleShadowSublayer.text = name
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
        let label = UILabel()
        label.text = "Travel to Europe on Motorcycle"
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let titleShadowSublayer: UILabel = {
        let label = UILabel()
        label.text = "Shadow Label"
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let projectImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "interior")
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
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
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
        
    var projectTitleAnchor: NSLayoutConstraint!
    
    func setupViews(){
        
        backgroundColor = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1)
        addSubview(projectImage)
        addSubview(titleShadowSublayer)
        addSubview(projectName)
        
        layer.insertSublayer(gradient, at: 1)
        gradient.frame = CGRect(x: 0, y: 188, width: frame.width, height: frame.height - 188)
        
        addSubview(deleteButton)
        
        deleteButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 11).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -11).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        projectName.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        projectName.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 13).isActive = true
        projectName.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -13).isActive = true
        projectTitleAnchor = projectName.heightAnchor.constraint(equalToConstant: 70)
        projectTitleAnchor.isActive = true
        
        titleShadowSublayer.topAnchor.constraint(equalTo: projectName.topAnchor, constant: 2).isActive = true
        titleShadowSublayer.leadingAnchor.constraint(equalTo: projectName.leadingAnchor, constant: 2).isActive = true
        titleShadowSublayer.widthAnchor.constraint(equalTo: projectName.widthAnchor).isActive = true
        titleShadowSublayer.heightAnchor.constraint(equalTo: projectName.heightAnchor).isActive = true
        
        projectImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        projectImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        projectImage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        projectImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
}
