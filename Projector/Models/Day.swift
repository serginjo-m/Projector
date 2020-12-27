//
//  Day.swift
//  Projector
//
//  Created by Serginjo Melnik on 09.12.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
struct Day {
    // Date represents a given day in a month.
    let date: Date
    //The number to display on the collection view cell.
    let number: String
    //Keeps track of whether this date is selected.
    let isSelected: Bool
    //Tracks if this date is within the currently-viewed month
    let isWithinDisplayedMonth: Bool
}
