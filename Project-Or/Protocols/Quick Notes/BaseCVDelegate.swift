//
//  BaseCVDelegate.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

protocol BaseCollectionViewDelegate {
    //update after delete
    func updateDatabase()
    // zooming in & zooming out
    func performZoomInForStartingImageView(startingImageView: UIView)
    
    func convertNoteToStep(index: Int, project: ProjectList)
}
