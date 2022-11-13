//
//  StepItemZoomingView.swift
//  Projector
//
//  Created by Serginjo Melnik on 09/11/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import Foundation
import UIKit

class StepItemZoomingView: UIView {

    var stepItem: StepItem
    
    var dismissView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "closeButton"))
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isUserInteractionEnabled = true
        image.alpha = 0
        return image
    }()
    
    lazy var removeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.setImage(UIImage(named: "binIcon"), for: .normal)
        button.backgroundColor = UIColor.init(displayP3Red: 255/255, green: 224/255, blue: 224/255, alpha: 1)
        button.alpha = 0
        return button
    }()
    
    lazy var editButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 6
        button.setImage(UIImage(named: "editIcon"), for: .normal)
        button.backgroundColor = UIColor.init(displayP3Red: 198/255, green: 250/255, blue: 211/255, alpha: 1)
        button.alpha = 0
        return button
    }()
    
    let titleIcon: UIImageView = {
       let image = UIImageView()
        image.image = UIImage(named: "descriptionNote")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var title: UILabel = {
        let label = UILabel()
        label.text = "Something"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    var thinUnderline: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 175/255, alpha: 1)
        return view
    }()
    
    //scrollable version of description label
    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.boldSystemFont(ofSize: 20)
        textView.isEditable = false
        textView.textColor = .darkGray
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
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
    
    
    
    var dismissButtonRightPaddingAnchor: NSLayoutConstraint!
    
    //active
    var bubbleBottomAnchor: NSLayoutConstraint!
    var bubbleTopAnchor: NSLayoutConstraint!
    var iconLeftAnchor: NSLayoutConstraint!
    var titleTopAnchor: NSLayoutConstraint!
    var descriptionHeightAnchor: NSLayoutConstraint!
    var descriptionTopAnchor: NSLayoutConstraint!
    
    //unActive
    var bubbleTopLabelAnchor: NSLayoutConstraint!
    var bubbleBottomLabelAnchor: NSLayoutConstraint!
    var iconLeftCompactAnchor: NSLayoutConstraint!
    var descriptionBottomAnchor: NSLayoutConstraint!
    
    init(stepItem: StepItem, frame: CGRect) {
        self.stepItem = stepItem
        super.init(frame: frame)
        
        configureViewDisplay()
        
    }
    
    func configureViewDisplay(){
        
        
        self.backgroundColor = .clear
        
        addSubview(backgroundBubble)
        addSubview(titleIcon)
        addSubview(dismissView)
        addSubview(removeButton)
        addSubview(editButton)
        addSubview(title)
        addSubview(thinUnderline)
        addSubview(descriptionLabel)
        addSubview(descriptionTextView)
        
        
        titleIcon.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        iconLeftAnchor = titleIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 22)
        iconLeftAnchor.isActive = true
        titleIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        titleIcon.heightAnchor.constraint(equalToConstant: 14).isActive = true
        iconLeftCompactAnchor = titleIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        
        title.leftAnchor.constraint(equalTo: titleIcon.rightAnchor, constant: 7).isActive = true
        titleTopAnchor = title.topAnchor.constraint(equalTo: topAnchor, constant: 83)
        titleTopAnchor.isActive = true
        title.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        title.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        thinUnderline.leadingAnchor.constraint(equalTo: titleIcon.leadingAnchor).isActive = true
        thinUnderline.heightAnchor.constraint(equalToConstant: 1).isActive = true
        thinUnderline.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22).isActive = true
        thinUnderline.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
        
        removeButton.topAnchor.constraint(equalTo: topAnchor, constant: 22).isActive = true
        removeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22).isActive = true
        removeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        removeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        editButton.topAnchor.constraint(equalTo: topAnchor, constant: 22).isActive = true
        editButton.leadingAnchor.constraint(equalTo: removeButton.trailingAnchor, constant: 22).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        editButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        dismissView.topAnchor.constraint(equalTo: topAnchor, constant: 26).isActive = true
        dismissButtonRightPaddingAnchor = dismissView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -26)// -26
        dismissButtonRightPaddingAnchor.isActive = true
        dismissView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        dismissView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        
        //description
        descriptionTopAnchor = descriptionLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 30)
        descriptionTopAnchor.isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        
        let rect = NSString(string: stepItem.text).boundingRect(with: CGSize(width: frame.width - 32, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)], context: nil)
        
        descriptionHeightAnchor = descriptionLabel.heightAnchor.constraint(equalToConstant: rect.height + 20)
        descriptionHeightAnchor.isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        descriptionBottomAnchor = descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30)//
        
        //bubble
        bubbleTopAnchor = backgroundBubble.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        bubbleTopAnchor.isActive = true
        backgroundBubble.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: -16).isActive = true
        
        backgroundBubble.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 16).isActive = true
        
        bubbleTopLabelAnchor = backgroundBubble.topAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -16)//*
        bubbleBottomLabelAnchor = backgroundBubble.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16)//*
        bubbleBottomAnchor = backgroundBubble.bottomAnchor.constraint(equalTo: bottomAnchor)
        bubbleBottomAnchor.isActive = true
        
        descriptionTextView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
        descriptionTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        descriptionTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
