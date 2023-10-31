//
//  StepImageCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class StepImageCell: UICollectionViewCell{
    
    var template: String? {
        didSet{
            guard let unwrappedTemplate = template else {return}
            //realy like this new approach
            stepImage.retreaveImageUsingURLString(myUrl: unwrappedTemplate)
        }
    }
    
    var stepImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "interior")
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 8
        layer.masksToBounds = true
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        backgroundColor = UIColor.lightGray
        
        addSubview(stepImage)
        stepImage.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        stepImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        stepImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        stepImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
    }
}
