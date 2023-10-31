//
//  SectionHeaderView.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 29/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit
//MARK: OK
class SectionHeaderView: UIView {
    
    let sectionTitle: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(white: 55/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "This is dummy text for debug purpose only"
        label.backgroundColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    let sectionIndexLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(white: 55/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "!"
        return label
    }()
    
    let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 224/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 11
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var menuButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.init(white: 217/255, alpha: 1)
        button.layer.cornerRadius = 10
        button.setImage(UIImage(named: "horizontal_dots"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .center
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    func setupView(){
        
        
        addSubview(circleView)
        addSubview(sectionTitle)
        addSubview(sectionIndexLabel)
        addSubview(menuButton)
        
        
        circleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 13).isActive = true
        circleView.centerYAnchor.constraint(equalTo: sectionTitle.centerYAnchor).isActive = true
        circleView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        circleView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        
        sectionTitle.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 15).isActive = true
        sectionTitle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sectionTitle.trailingAnchor.constraint(equalTo: menuButton.leadingAnchor, constant: -15).isActive = true
        sectionTitle.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        sectionIndexLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor).isActive = true
        sectionIndexLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor).isActive = true
        sectionIndexLabel.heightAnchor.constraint(equalTo: circleView.heightAnchor).isActive = true
        sectionIndexLabel.widthAnchor.constraint(equalTo: circleView.widthAnchor).isActive = true
        
        menuButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        menuButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        menuButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        menuButton.centerYAnchor.constraint(equalTo: sectionTitle.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

