//
//  ColorPaletteCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 29/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class ColorPaletteCell: UICollectionViewCell{

    //MARK: Cell Properties
    var template: UIColor? {
        didSet{
            guard let unwrappedTemplate = template else {return}
    
            colorButton.backgroundColor = unwrappedTemplate
        }
    }
    
    var colorButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()

    //MARK: Cell Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 8
        layer.masksToBounds = true
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Cell Methods
    func setupViews(){
        
        addSubview(colorButton)
        
        colorButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        colorButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        colorButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        colorButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
