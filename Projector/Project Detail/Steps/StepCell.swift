//
//  StepCollectionViewCell.swift
//  Projector
//
//  Created by Serginjo Melnik on 22.04.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit

class StepCell: UICollectionViewCell{
    //position options menu next to the selected cell button
    weak var delegate: StepsCollectionViewDelegate?
    
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
        image.clipsToBounds = true
        return image
    }()
//    //adds contrast to project title
//    let gradient: CAGradientLayer =  {
//        let gradient = CAGradientLayer()
//        let topColor = UIColor.init(red: 1/255, green: 1/255, blue: 1/255, alpha: 0).cgColor//black transparent
//        let middleColor = UIColor.init(red: 1/255, green: 1/255, blue: 1/255, alpha: 0.21).cgColor//black 16% opacity
//        let bottomColor = UIColor.init(red: 2/255, green: 2/255, blue: 2/255, alpha: 0.56).cgColor//black 56% opacity
//        gradient.colors = [topColor, middleColor, bottomColor]
//        gradient.locations = [0.55, 0.75, 1.0]
//        return gradient
//    }()

    
    @objc func handleStatus(_ sender: UIButton){
        guard let delegate = self.delegate else {return}
        let button = sender
        delegate.showView(startingUIButton: button)
    }
    
    func setupViews(){
        
        //insert gradient
        layer.masksToBounds = true
        layer.cornerRadius = 5
        backgroundColor = UIColor.init(white: 0.90, alpha: 1)
        
//        gradient.frame = self.bounds

        addSubview(imageView)
        addSubview(optionsButton)
        addSubview(stepNameLabel)
        
//        imageView.layer.insertSublayer(gradient, at: 0)
        
        
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        stepNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7).isActive = true
        stepNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 9).isActive = true
        stepNameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -9).isActive = true
        stepNameLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
    
        optionsButton.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        optionsButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        optionsButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
        optionsButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
}

