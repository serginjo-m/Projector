//
//  CalendarCell.swift
//  Projector
//
//  Created by Serginjo Melnik on 25.12.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit

class CalendarCell: UICollectionViewCell{
    static let reuseIdentifier = String(describing: CalendarCell.self)
    //template
    var day: Day? {
        didSet {
            //check if ...
            guard let day = day else { return }
            //set values
            numberLabel.text = day.number
            //it is like a hint for user
            accessibilityLabel = accessibilityDateFormatter.string(from: day.date)
            //every time day update style
            updateSelectionStatus()
        }
    }
    
    //when user selects cell
    override var isSelected: Bool{
        willSet{
            //change cell selection to true and all other to false
            super.isSelected = newValue
            
            guard let day = day else { return }
            
            if newValue {
                //selected by user style
                applySelectedStyle(isCurrentDate: false)
            } else {
                //current day selection
                if day.isSelected {
                    applySelectedStyle(isCurrentDate: day.isSelected)
                } else {
                    applyDefaultStyle(isWithinDisplayedMonth: day.isWithinDisplayedMonth)
                }
                
            }
        }
        
    }
    
    lazy var selectionBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = UIColor.init(displayP3Red: 243/255, green: 103/255, blue: 115/255, alpha: 1)
        return view
    }()
    
    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    lazy var topCircleImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "redCircle")
        image.image = image.image?.withRenderingMode(.alwaysTemplate)
        image.tintColor = .clear
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var bottomCircleImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "blueCircle")
        image.image = image.image?.withRenderingMode(.alwaysTemplate)
        image.tintColor = .clear
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var accessibilityDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
        return dateFormatter
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        contentView.addSubview(selectionBackgroundView)
        
        contentView.addSubview(numberLabel)
        contentView.addSubview(topCircleImage)
        contentView.addSubview(bottomCircleImage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // This allows for rotations and trait collection
        // changes (e.g. entering split view on iPad) to update constraints correctly.
        // Removing old constraints allows for new ones to be created
        // regardless of the values of the old ones
        NSLayoutConstraint.deactivate(selectionBackgroundView.constraints)
        
        let size = traitCollection.horizontalSizeClass == .compact ?
            min(min(frame.width, frame.height) - 10, 60) : 45
        
        NSLayoutConstraint.activate([
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            numberLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            
            selectionBackgroundView.centerYAnchor.constraint(equalTo: numberLabel.centerYAnchor),
            selectionBackgroundView.centerXAnchor.constraint(equalTo: numberLabel.centerXAnchor),
            selectionBackgroundView.widthAnchor.constraint(equalToConstant: size),
            selectionBackgroundView.heightAnchor.constraint(equalTo: selectionBackgroundView.widthAnchor),
            
            topCircleImage.topAnchor.constraint(equalTo: selectionBackgroundView.bottomAnchor, constant: 4),
            topCircleImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            topCircleImage.widthAnchor.constraint(equalToConstant: 8),
            topCircleImage.heightAnchor.constraint(equalToConstant: 8),
        
            bottomCircleImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            bottomCircleImage.widthAnchor.constraint(equalToConstant: 8),
            bottomCircleImage.heightAnchor.constraint(equalToConstant: 8),
            bottomCircleImage.topAnchor.constraint(equalTo: topCircleImage.bottomAnchor, constant: 4)
        ])
        
        
        selectionBackgroundView.layer.cornerRadius = size / 2
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        layoutSubviews()
    }
}


