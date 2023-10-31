//
//  SectionCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 29/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit
//MARK: OK
class SectionCell: UITableViewCell {
    
    let sectionNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        setupCell()
    }
    
    
    func setupCell(){
        addSubview(sectionNameLabel)
        
        sectionNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sectionNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        sectionNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        sectionNameLabel.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
