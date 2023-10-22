//
//  PopoverMessageView.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class PopoverMessageView: UIView {
    
    var textMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Nothing to Add Here"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textMessageLabel)
        
        self.backgroundColor = UIColor.init(red: 100/255, green: 209/255, blue: 130/255, alpha: 1)
        self.layer.cornerRadius = 11
        self.layer.masksToBounds = true
        
        textMessageLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textMessageLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textMessageLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
