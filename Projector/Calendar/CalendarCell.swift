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
    
    private lazy var selectionBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = UIColor.init(displayP3Red: 243/255, green: 103/255, blue: 115/255, alpha: 1)
        return view
    }()
    
    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private lazy var topCircleImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "redCircle")
        image.image = image.image?.withRenderingMode(.alwaysTemplate)
        image.tintColor = .clear
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var bottomCircleImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "blueCircle")
        image.image = image.image?.withRenderingMode(.alwaysTemplate)
        image.tintColor = .clear
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var accessibilityDateFormatter: DateFormatter = {
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
        
        
        // 1
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

private extension CalendarCell {
    
    //apply different styles based on the selection status
    func updateSelectionStatus() {
        guard let day = day else { return }
        //if day selected apply style else default
        if day.isSelected {
            applySelectedStyle(isCurrentDate: day.isSelected)
        } else {
            applyDefaultStyle(isWithinDisplayedMonth: day.isWithinDisplayedMonth)
        }
        
        let redColor = UIColor.init(red: 243/255, green: 103/255, blue: 115/255, alpha: 1)
        let greenColor = UIColor.init(red: 53/255, green: 204/255, blue: 117/255, alpha: 1)
        
        //reset tint color
        topCircleImage.tintColor = .clear
        bottomCircleImage.tintColor = .clear
        //check for both, so need to use 2 circles
        let containEventHoliday = day.containEvent && day.containHoliday ? true : false
        
        //if both
        if containEventHoliday{
            topCircleImage.tintColor = redColor
            bottomCircleImage.tintColor = greenColor
        }else if day.containEvent{//if event
            topCircleImage.tintColor = redColor
        }else if day.containHoliday{//if holiday
            topCircleImage.tintColor = greenColor
        }
        
    }
    
    // small display size computed property
    var isSmallScreenSize: Bool {
        let isCompact = traitCollection.horizontalSizeClass == .compact
        let smallWidth = UIScreen.main.bounds.width <= 350
        let widthGreaterThanHeight =
            UIScreen.main.bounds.width > UIScreen.main.bounds.height
        
        return isCompact && (smallWidth || widthGreaterThanHeight)
    }
    
    
    
    // isSelected style when user selects cell
    func applySelectedStyle(isCurrentDate: Bool) {
        
        accessibilityTraits.insert(.selected)
        accessibilityHint = nil
        
        numberLabel.textColor = isSmallScreenSize ? .red : .white
        selectionBackgroundView.isHidden = isSmallScreenSize
        selectionBackgroundView.backgroundColor = isCurrentDate ? UIColor.init(displayP3Red: 243/255, green: 103/255, blue: 115/255, alpha: 1) : .black
    }
    
    // Default style
    func applyDefaultStyle(isWithinDisplayedMonth: Bool) {
        accessibilityTraits.remove(.selected)
        accessibilityHint = "Tap to select"
        
        numberLabel.textColor = isWithinDisplayedMonth ? .black : UIColor.init(displayP3Red: 164/255, green: 180/255, blue: 202/255, alpha: 1)
        selectionBackgroundView.isHidden = true
    }
}
