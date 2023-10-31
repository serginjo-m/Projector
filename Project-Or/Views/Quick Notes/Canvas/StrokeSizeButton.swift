//
//  StrokeSizeButton.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 29/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class StrokeSizeButton: UIView {
    
    lazy var strokeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    var strokeSizeIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(red: 249/255, green: 65/255, blue: 68/255, alpha: 1)
        view.layer.cornerRadius = 7.5
        view.layer.masksToBounds = true
        return view
    }()
    
    var strokeSizeIndicatorWidthAnchor: NSLayoutConstraint!
    var strokeSizeIndicatorHeightAnchor: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        addSubview(strokeView)
        addSubview(strokeSizeIndicator)
        configureView()
    }
    
    private func configureView(){
        strokeView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        strokeView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        strokeView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        strokeView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        strokeSizeIndicator.centerXAnchor.constraint(equalTo: strokeView.centerXAnchor).isActive = true
        strokeSizeIndicator.centerYAnchor.constraint(equalTo: strokeView.centerYAnchor).isActive = true
        strokeSizeIndicatorWidthAnchor = strokeSizeIndicator.widthAnchor.constraint(equalToConstant: 15)
        strokeSizeIndicatorHeightAnchor = strokeSizeIndicator.heightAnchor.constraint(equalToConstant: 15)
        strokeSizeIndicatorHeightAnchor.isActive = true
        strokeSizeIndicatorWidthAnchor.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
