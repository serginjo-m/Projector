//
//  StepTableViewCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 29/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit
//MARK: OK
class StepTableViewCell: UITableViewCell {
    
    //use for zooming delgate
    var stepViewController: StepViewController?
    
    var template: StepItem? {
        didSet {
            guard let template = template else {return}
            itemTitle.text = template.title
            descriptionLabel.text = template.text
        }
    }

    let titleIcon: UIImageView = {
       let image = UIImageView()
        image.image = UIImage(named: "descriptionNote")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let itemTitle: UILabel = {
        let label = UILabel()
        label.text = "Something"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "First of all I need to clean and inspect all surface."
        //label.backgroundColor = UIColor.lightGray
        label.textColor = UIColor.init(white: 0.3, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let backgroundBubble: UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor(displayP3Red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        bg.layer.cornerRadius = 12
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.layer.masksToBounds = true
        return bg
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //turn of change background color on selected cell
        selectionStyle = UITableViewCell.SelectionStyle.none
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoomIn))
        addGestureRecognizer(tap)
        
        addSubview(itemTitle)
        addSubview(titleIcon)
        addSubview(backgroundBubble)
        addSubview(descriptionLabel)
        
        titleIcon.centerYAnchor.constraint(equalTo: itemTitle.centerYAnchor).isActive = true
        titleIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        titleIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        titleIcon.heightAnchor.constraint(equalToConstant: 14).isActive = true
        
        itemTitle.leftAnchor.constraint(equalTo: titleIcon.rightAnchor, constant: 7).isActive = true
        itemTitle.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        itemTitle.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        itemTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        descriptionLabel.topAnchor.constraint(equalTo: itemTitle.bottomAnchor, constant: 20).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        backgroundBubble.topAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -16).isActive = true
        backgroundBubble.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: -16).isActive = true
        backgroundBubble.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16).isActive = true
        backgroundBubble.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 16).isActive = true
    }
    
    //from cell to view controller
    @objc func zoomIn(tapGesture: UITapGestureRecognizer){
        
        guard let stepItem = template, let viewController = stepViewController else { return }
        viewController.performZoomForStartingEventView(stepItem: stepItem, startingView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
