//
//  StatisticCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class StatisticCell: UITableViewCell {
    //data template
    var template: ProjectList? {
        didSet{
            
            if let template = template {
                
                if let image = template.selectedImagePathUrl{
                    projectImage.image = retreaveImageForProject(myUrl: image)
                }
                
                projectName.text = template.name
                
                if let money = template.money {
                    moneyNumber.text = "\(money) $"
                }
                if let time = template.time {
                    timeNumber.text = "\(time) h."
                }
                if let fuel = template.fuel {
                    fuelNumber.text = "\(fuel) l."
                }
            }
        }
    }
    
    //return UIImage by URL
    func retreaveImageForProject(myUrl: String) -> UIImage{
        var projectImage: UIImage = UIImage(named: "scheduledStepEvent")!
        let url = URL(string: myUrl)
        let data = try? Data(contentsOf: url!)
        if let imageData = data{
            projectImage = UIImage(data: imageData)!
        }
        return projectImage
    }
    
    let projectImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "river"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let projectName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "No Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let moneyNumber: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0"
        return label
    }()
    
    let timeNumber: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0"
        return label
    }()
    let fuelNumber: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0"
        return label
    }()
    
    let contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.init(white: 0.55, alpha: 1).cgColor
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        setupCell()
    }
    
    func setupCell(){
        
        //view with stack that holds projects values
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.stack(.horizontal, views: moneyNumber, timeNumber, fuelNumber, spacing: 0, distribution: .fillEqually)
        
        //add views
        [contentContainerView, projectImage, projectName, stackView].forEach { (subview) in
            addSubview(subview)
        }
        
        //constraints
        contentContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        contentContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        contentContainerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        contentContainerView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        
        projectImage.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: 10).isActive = true
        projectImage.leftAnchor.constraint(equalTo: contentContainerView.leftAnchor, constant: 10).isActive = true
        projectImage.heightAnchor.constraint(equalToConstant: 48).isActive = true
        projectImage.widthAnchor.constraint(equalToConstant: 48).isActive = true
        
        projectName.topAnchor.constraint(equalTo: projectImage.topAnchor, constant: 0).isActive = true
        projectName.leftAnchor.constraint(equalTo: projectImage.rightAnchor, constant: 18).isActive = true
        projectName.heightAnchor.constraint(equalToConstant: 18).isActive = true
        projectName.rightAnchor.constraint(equalTo: contentContainerView.rightAnchor, constant: -18).isActive = true
        
        stackView.leftAnchor.constraint(equalTo: projectImage.rightAnchor, constant: 18).isActive = true
        stackView.rightAnchor.constraint(equalTo: contentContainerView.rightAnchor, constant: -18).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor, constant: -10).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 17).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
