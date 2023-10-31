//
//  StepCollectionViewCell.swift
//  Projector
//
//  Created by Serginjo Melnik on 22.04.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit

class StepCell: UICollectionViewCell{
    
    weak var delegate: StepsCollectionViewDelegate?
    
    var template: ProjectStep? {
        didSet{
            guard let unwrappedTemplate = template else {return}
            
            stepNameLabel.text = unwrappedTemplate.name
            stepNameShadow.text = stepNameLabel.text
            
            if unwrappedTemplate.selectedPhotosArray.count > 0 {
                
                imageView.retreaveImageUsingURLString(myUrl: unwrappedTemplate.selectedPhotosArray[0])
            }else{
                imageView.image = nil
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
    
    let stepNameShadow: UILabel = {
        let label = UILabel()
        label.text = "some text"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textColor = UIColor.init(white: 0, alpha: 0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var optionsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.init(white: 1, alpha: 0.82)
        button.layer.cornerRadius = 10
        button.setImage(UIImage(named: "3dots"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .center
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleStatus(_:)), for: .touchUpInside)
        return button
    }()
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "scheduledStepEvent")
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    @objc func handleStatus(_ sender: UIButton){
        guard let delegate = self.delegate else {return}
        let button = sender
        delegate.showView(startingUIButton: button)
    }
    
    func setupViews(){
        
        layer.masksToBounds = true
        layer.cornerRadius = 5
        backgroundColor = UIColor.init(white: 0.80, alpha: 1)
        
        addSubview(imageView)
        addSubview(optionsButton)
        addSubview(stepNameShadow)
        addSubview(stepNameLabel)
        
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        stepNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7).isActive = true
        stepNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 9).isActive = true
        stepNameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -9).isActive = true
        stepNameLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        stepNameShadow.topAnchor.constraint(equalTo: stepNameLabel.topAnchor, constant: 2).isActive = true
        stepNameShadow.leadingAnchor.constraint(equalTo: stepNameLabel.leadingAnchor, constant: 2).isActive = true
        stepNameShadow.trailingAnchor.constraint(equalTo: stepNameLabel.trailingAnchor, constant: 2).isActive = true
        stepNameShadow.bottomAnchor.constraint(equalTo: stepNameLabel.bottomAnchor, constant: 2).isActive = true
    
        optionsButton.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        optionsButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        optionsButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
        optionsButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
}

