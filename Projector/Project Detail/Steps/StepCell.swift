//
//  StepCollectionViewCell.swift
//  Projector
//
//  Created by Serginjo Melnik on 22.04.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit


class StepCell: UICollectionViewCell{
    
    var template: ProjectStep? {
        didSet{
            guard let unwrappedTemplate = template else {return}
            
            stepNameLabel.text = unwrappedTemplate.name
            
            if unwrappedTemplate.selectedPhotosArray.count > 0 {
                //call Singelton
                imageView.image = StringToImage.shared.retreaveImageForProject(myUrl: unwrappedTemplate.selectedPhotosArray[0])
            }
            
        }
    }
    
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
        label.textColor = UIColor.init(white: 1, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var statusButton: UIButton = {
        let button = UIButton()
        button.setTitle("Status", for: .normal)
        button.setTitleColor(.brown, for: .normal)
        button.contentHorizontalAlignment = .right
        button.adjustsImageWhenHighlighted = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.addTarget(self, action: #selector(handleStatus), for: .touchUpInside)
        return button
    }()

//    let deleteButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(named:"removeStep"), for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.isUserInteractionEnabled = true
//        return button
//    }()

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

    
    @objc func handleStatus(){
        print("status has changed")
    }
    
    func setupViews(){
        
        //insert gradient
        layer.masksToBounds = true
        layer.cornerRadius = 5
        backgroundColor = UIColor.init(white: 0.90, alpha: 1)
        
        gradient.frame = self.bounds

        addSubview(imageView)
//        addSubview(deleteButton)
        addSubview(statusButton)
        addSubview(stepNameLabel)
        imageView.layer.insertSublayer(gradient, at: 0)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        stepNameLabel.translatesAutoresizingMaskIntoConstraints = false
        statusButton.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        stepNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7).isActive = true
        stepNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 9).isActive = true
        stepNameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -9).isActive = true
        stepNameLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
//        deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: 9).isActive = true
//        deleteButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -9).isActive = true
//        deleteButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
//        deleteButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        statusButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        statusButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -19).isActive = true
        statusButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        statusButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
}

