//
//  PinterestDelegate.swift
//  Projector
//
//  Created by Serginjo Melnik on 28.10.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import Foundation
import UIKit

// Pinterest Layout Configurations
extension StepsCategoryCollectionView : PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        let step = projectSteps[indexPath.item]
        if step.selectedPhotosArray.count > 0 {
            guard let image = StringToImage.shared.retreaveImageForProject(myUrl: step.selectedPhotosArray[0]) else {return 60}
            return image.size.height
        }
        
        return 60
    }
    
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {

        let step = projectSteps[indexPath.item]
        if step.selectedPhotosArray.count > 0 {
            guard let image = StringToImage.shared.retreaveImageForProject(myUrl: step.selectedPhotosArray[0]) else {return 100}
            return image.size.width
        }
        return 100
    }
}

