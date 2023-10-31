//
//  CanvasNotesCollectionViewControllerExt.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 29/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

extension CanvasNotesCollectionViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(items[indexPath.item].height)
    }
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(items[indexPath.item].width)
    }
}
