//
//  TimeLineCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class TimeLineCell: UIView {
    
    var hourString: String
    
    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.text = self.hourString
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: Initialization
    init(hourString: String, frame: CGRect) {
        self.hourString = hourString
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        addSubview(numberLabel)
        numberLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        numberLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        numberLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        numberLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
    }
}
