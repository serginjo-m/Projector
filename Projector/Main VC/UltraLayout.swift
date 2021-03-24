//
//  UltraLayout.swift
//  Projector
//
//  Created by Serginjo Melnik on 11.03.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

// The heights are declared as constants outside of the class so they can be easily referenced elsewhere
class UltravisualLayoutConstants {
    // The width of the non-featured cell
    var standardWidth: CGFloat = 54
    // The width of the first visible cell
    var featuredWidth: CGFloat = 54

    //like an observer of click action
    var isClicked = false {
        didSet{
            print("user clicks widget")
        }
    }
}

// MARK: Properties and Variables

class UltravisualLayout: UICollectionViewLayout {
    
    // The amount the user needs to scroll before the featured cell changes
    let dragOffset: CGFloat = 180.0
    
    //------ an array of attributes ? -----------
    var cache: [UICollectionViewLayoutAttributes] = []
    
    // Returns the item index of the currently featured cell
    var featuredItemIndex: Int {
        // Use max to make sure the featureItemIndex is never < 0
        return max(0, Int(collectionView!.contentOffset.x / dragOffset))
    }
    
    // Returns a value between 0 and 1 that represents how close the next cell is to becoming the featured cell
    var nextItemPercentageOffset: CGFloat {
        return (collectionView!.contentOffset.x / dragOffset) - CGFloat(featuredItemIndex)
    }
    
    // Returns the width of the collection view
    var width: CGFloat {
        return collectionView!.bounds.width
    }
    
    // Returns the height of the collection view
    var height: CGFloat {
        return collectionView!.bounds.height
    }
    
    // Returns the number of items in the collection view (defined in collectionView)
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

// MARK: UICollectionViewLayout

extension UltravisualLayout {
    
    // Return the size of all the content in the collection view
    override var collectionViewContentSize : CGSize {
        
        //all content width
        let contentWidth = (CGFloat(numberOfItems) * dragOffset) + (width - dragOffset)
        return CGSize(width: contentWidth, height: height)
    }
    
    
    override func prepare() {
        guard let cv = collectionView else {return}
        
        cache.removeAll(keepingCapacity: false)
        
        let standardWidth = layoutConstraints.standardWidth
        let featuredWidth = layoutConstraints.featuredWidth
        
        var frame = CGRect.zero
        var x: CGFloat = 0
        
        for item in 0..<numberOfItems {
            // Create an index path to the current cell, then create default attributes for it.
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            // Prepare the cell to move left or right. Since the majority of cells will not be featured — there are many more standard cells than the single featured cells — it defaults to the standardWidth
            attributes.zIndex = item
            var width = standardWidth
            
            // Determine the current cell's status — featured, next or standard.
            //In the case of the latter, you do nothing

            if indexPath.item == featuredItemIndex {
                // If the cell is currently in the featured-cell position,
                //calculate the xOffset and use that to derive the new x value for the cell.
                //After that, you set the cell's width to be the featured width
                let xOffset = standardWidth * nextItemPercentageOffset
                
                x = collectionView!.contentOffset.x - xOffset
                width = featuredWidth
            } else if indexPath.item == (featuredItemIndex + 1)
                && indexPath.item != numberOfItems {
                // If the cell is next in line, you start by calculating the largest y could be
                //(in this case, larger than the featured cell) and combine that with a calculated width
                //to end up with the correct value of x, which is 280.0 — the width of the featured cell.
                let maxX = x + standardWidth
                width = standardWidth + max(
                    (featuredWidth - standardWidth) * nextItemPercentageOffset, 0
                )
                x = maxX - width
            }

            // Lastly, set some common elements for each cell, including creating the frame, setting the calculated attributes, and updating the cache values. The very last step is to update x so that it's at the bottom of the last calculated cell so that you can move down the list of cells efficiently
            frame = CGRect(x: x, y: 0, width: width, height: height)
            attributes.frame = frame
            cache.append(attributes)
            x = frame.maxX
        }
        
    }
    
    // Return all attributes in the cache whose frame intersects with the rect passed to the method
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        for attributes in cache {
            
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    // Return true so that the layout is continuously invalidated as the user scrolls
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
