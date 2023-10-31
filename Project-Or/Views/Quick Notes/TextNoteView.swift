//
//  TextNoteView.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 29/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class TextNoteView: UIView {
    
    var textLabelTopAnchorConstraint: NSLayoutConstraint!
    var textLabelLeadingAnochorConstraint: NSLayoutConstraint!
    var textLabelTrailingAnchorConstraint: NSLayoutConstraint!
    var textLabelBottomAnchorConstraint: NSLayoutConstraint!
    
    var textLabelHeightAnchorConstraint: NSLayoutConstraint!
    var textLabelWidthAnchorConstraint: NSLayoutConstraint!
    var textLabelCenterYAnchorConstraint: NSLayoutConstraint!
    var textLabelCenterXAnchorConstraint: NSLayoutConstraint!
        
    var scrollViewContainer: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    var contentUIView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(text: String, frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        backgroundColor = UIColor.init(white: 229/255, alpha: 1)
        textLabel.text = text

        addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        contentUIView.addSubview(textLabel)
        
        scrollViewContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        scrollViewContainer.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scrollViewContainer.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        let rect = NSString(string: text).boundingRect(with: CGSize(width: frame.width, height: frame.height * 1.2), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25)], context: nil)

        contentUIView.topAnchor.constraint(equalTo: scrollViewContainer.topAnchor).isActive = true
        contentUIView.leftAnchor.constraint(equalTo: scrollViewContainer.leftAnchor).isActive = true
        contentUIView.rightAnchor.constraint(equalTo: scrollViewContainer.rightAnchor).isActive = true
        contentUIView.bottomAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor).isActive = true
        contentUIView.widthAnchor.constraint(equalTo: scrollViewContainer.widthAnchor).isActive = true
        contentUIView.heightAnchor.constraint(equalToConstant: rect.height + 10).isActive = true
        
        textLabelTopAnchorConstraint = textLabel.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 10)
        textLabelLeadingAnochorConstraint = textLabel.leadingAnchor.constraint(equalTo: contentUIView.leadingAnchor, constant: 10)
        textLabelTrailingAnchorConstraint = textLabel.trailingAnchor.constraint(equalTo: contentUIView.trailingAnchor, constant: -10)
        textLabelBottomAnchorConstraint = textLabel.bottomAnchor.constraint(equalTo: contentUIView.bottomAnchor, constant: 10)
        
        textLabelTopAnchorConstraint.isActive = true
        textLabelLeadingAnochorConstraint.isActive = true
        textLabelTrailingAnchorConstraint.isActive = true
        textLabelBottomAnchorConstraint.isActive = true
        
        textLabelWidthAnchorConstraint = textLabel.widthAnchor.constraint(equalTo: widthAnchor)
        textLabelHeightAnchorConstraint = textLabel.heightAnchor.constraint(equalTo: heightAnchor)
        textLabelCenterYAnchorConstraint = textLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        textLabelCenterXAnchorConstraint = textLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
