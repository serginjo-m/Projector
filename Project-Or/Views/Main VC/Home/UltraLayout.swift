//
//  UltraLayout.swift
//  Projector
//
//  Created by Serginjo Melnik on 11.03.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

class UltravisualLayoutConstants {

    var standardWidth: CGFloat = 54

    var featuredWidth: CGFloat = 54

    var isSelected = true
}

class UltravisualLayout: UICollectionViewLayout {
    
    let dragOffset: CGFloat = 180.0
    
    var cache: [UICollectionViewLayoutAttributes] = []
    
    var featuredItemIndex: Int {
        return max(0, Int(collectionView!.contentOffset.x / dragOffset))
    }

    var nextItemPercentageOffset: CGFloat {
        return (collectionView!.contentOffset.x / dragOffset) - CGFloat(featuredItemIndex)
    }
    
    var width: CGFloat {
        return collectionView!.bounds.width
    }
    
    var height: CGFloat {
        return collectionView!.bounds.height
    }
    
    var numberOfItems: Int {
        return collectionView!.numberOfItems(inSection: 0)
    }
    
    var layoutConstraints: UltravisualLayoutConstants
    
    init(layoutConstraints: UltravisualLayoutConstants) {
        self.layoutConstraints = layoutConstraints
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UltravisualLayout {
    
    override var collectionViewContentSize : CGSize {
        let contentWidth = (CGFloat(numberOfItems) * dragOffset) + (width - dragOffset)
        return CGSize(width: contentWidth, height: height)
    }
    
    override func prepare() {
        
        cache.removeAll(keepingCapacity: false)
        
        let standardWidth = (self.width - layoutConstraints.featuredWidth) / 6
        let featuredWidth = layoutConstraints.featuredWidth
        
        var frame = CGRect.zero
        var x: CGFloat = 0
        
        for item in 0..<numberOfItems {
            
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.zIndex = item
            var width = standardWidth
            
            if indexPath.item == featuredItemIndex {
                
                let xOffset = standardWidth * nextItemPercentageOffset
                
                x = collectionView!.contentOffset.x - xOffset
                width = featuredWidth
            } else if indexPath.item == (featuredItemIndex + 1)
                && indexPath.item != numberOfItems {
                
                let maxX = x + standardWidth
                width = standardWidth + max(
                    (featuredWidth - standardWidth) * nextItemPercentageOffset, 0
                )
                x = maxX - width
            }
            
            frame = CGRect(x: x, y: 0, width: width, height: height)
            attributes.frame = frame
            cache.append(attributes)
            x = frame.maxX
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        for attributes in cache {

            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attrs = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        attrs?.alpha = 1.0
        return attrs
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attrs = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        attrs?.alpha = 1.0
        return attrs
    }
        
}

