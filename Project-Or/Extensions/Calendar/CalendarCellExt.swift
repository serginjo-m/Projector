//
//  CalendarCellExt.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

extension CalendarCell {
    
    func updateSelectionStatus() {
        guard let day = day else { return }
    
        if day.isSelected {
            applySelectedStyle(isCurrentDate: day.isSelected)
        } else {
            applyDefaultStyle(isWithinDisplayedMonth: day.isWithinDisplayedMonth)
        }
        
        let redColor = UIColor.init(red: 243/255, green: 103/255, blue: 115/255, alpha: 1)
        let greenColor = UIColor.init(red: 53/255, green: 204/255, blue: 117/255, alpha: 1)
        
        topCircleImage.tintColor = .clear
        bottomCircleImage.tintColor = .clear
        
        let containEventHoliday = day.containEvent && day.containHoliday ? true : false
        
        if containEventHoliday{
            topCircleImage.tintColor = redColor
            bottomCircleImage.tintColor = greenColor
        }else if day.containEvent{
            topCircleImage.tintColor = redColor
        }else if day.containHoliday{
            topCircleImage.tintColor = greenColor
        }
    }

    var isSmallScreenSize: Bool {
        let isCompact = traitCollection.horizontalSizeClass == .compact
        let smallWidth = UIScreen.main.bounds.width <= 350
        let widthGreaterThanHeight =
            UIScreen.main.bounds.width > UIScreen.main.bounds.height
        return isCompact && (smallWidth || widthGreaterThanHeight)
    }

    func applySelectedStyle(isCurrentDate: Bool) {
        
        accessibilityTraits.insert(.selected)
        accessibilityHint = nil
        
        numberLabel.textColor = isSmallScreenSize ? .red : .white
        selectionBackgroundView.isHidden = isSmallScreenSize
        selectionBackgroundView.backgroundColor = isCurrentDate ? UIColor.init(displayP3Red: 243/255, green: 103/255, blue: 115/255, alpha: 1) : .black
    }

    func applyDefaultStyle(isWithinDisplayedMonth: Bool) {
        accessibilityTraits.remove(.selected)
        accessibilityHint = "Tap to select"
        
        numberLabel.textColor = isWithinDisplayedMonth ? .black : UIColor.init(displayP3Red: 164/255, green: 180/255, blue: 202/255, alpha: 1)
        selectionBackgroundView.isHidden = true
    }
}
