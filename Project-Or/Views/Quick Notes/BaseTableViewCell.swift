//
//  BaseTableViewCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 30/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    var template: ProjectList? {
        didSet{
            if let template = template {
                if let image = template.selectedImagePathUrl{
                    projectImage.image = retreaveImageForProject(myUrl: image)
                }
                projectName.text = template.name
            }
        }
    }
    
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
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "No Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    let contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 1, alpha: 0.15)
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

        [contentContainerView, projectImage, projectName].forEach { (subview) in
            addSubview(subview)
        }

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
        projectName.rightAnchor.constraint(equalTo: contentContainerView.rightAnchor, constant: -18).isActive = true
        projectName.bottomAnchor.constraint(equalTo: projectImage.bottomAnchor).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
