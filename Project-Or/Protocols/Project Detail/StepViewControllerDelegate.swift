//
//  StepViewControllerDelegate.swift
//  Projector
//
//  Created by Serginjo Melnik on 28.10.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}
