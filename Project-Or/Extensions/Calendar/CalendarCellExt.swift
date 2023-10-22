//
//  CalendarCellExt.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

extension CalendarCell {
    
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
