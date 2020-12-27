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
        view.backgroundColor = .red
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
        
        // 2
        NSLayoutConstraint.activate([
            
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            selectionBackgroundView.centerYAnchor.constraint(equalTo: numberLabel.centerYAnchor),
            selectionBackgroundView.centerXAnchor.constraint(equalTo: numberLabel.centerXAnchor),
            selectionBackgroundView.widthAnchor.constraint(equalToConstant: size),
            selectionBackgroundView.heightAnchor.constraint(equalTo: selectionBackgroundView.widthAnchor),
            
            
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
        selectionBackgroundView.backgroundColor = isCurrentDate ? .red : .black
    }
    
    // Default style
    func applyDefaultStyle(isWithinDisplayedMonth: Bool) {
        accessibilityTraits.remove(.selected)
        accessibilityHint = "Tap to select"
        
        numberLabel.textColor = isWithinDisplayedMonth ? .black : .darkGray
        selectionBackgroundView.isHidden = true
    }
}
