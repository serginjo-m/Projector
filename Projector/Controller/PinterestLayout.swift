//
//  PinterestLayout.swift
//  Projector
//
//  Created by Serginjo Melnik on 04.11.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {
    
    //This keeps a reference to the delegate
    weak var delegate: PinterestLayoutDelegate?
    
    //configuring the layout: The number of columns and the cell padding
    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 6
    
    /*This is an array to cache the calculated attributes.
    When you call prepare(), you’ll calculate the attributes for all items
    and add them to the cache. When the collection view later requests the
    layout attributes, you can efficiently query the cache instead of recalculating
    them every time.*/
    var cache: [UICollectionViewLayoutAttributes] = []
    //increment contentHeight as you add photos and calculate contentWidth based on the collection view width and its content inset
    private var contentHeight: CGFloat = 0
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    //use both contentWidth and contentHeight from previous steps to calculate the size
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    //Whenever a layout operation is about to take place, UIKit calls this method. It’s opportunity to prepare and perform any calculations required to determine the collection view’s size and the positions of the items.
    override func prepare() {
        
        
        
        //Maybe I should find more elegant solution
        //becouse I have different projects that uses different steps array for CV
        cache = []
        
        
        
        
        //calculate the layout attributes if and the collection view exists
        guard let collectionView = collectionView else {return}
        /*Declare and fill the xOffset array with the x-coordinate for every column based on the column widths. The yOffset array tracks the y-position for every column. You initialize each value in yOffset to 0, since this is the offset of the first item in each column.
        */
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns{
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        //Loop through all the items in the first section since this particular layout has only one section.
        for item in 0..<collectionView.numberOfItems(inSection: 0){
            let indexPath = IndexPath(item: item, section: 0)
            /*Perform the frame calculation. width is the previously calculated cellWidth with the padding between cells removed. Ask the delegate for the height of the photo, then calculate the frame height based on this height and the predefined cellPadding for the top and bottom.If there is no delegate set, use default cell height. You then combine this with the x and y offsets of the current column to create insetFrame used by the attribute.*/
            let photoHeight = delegate?.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath) ?? 180
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            //Create an instance of UICollectionViewLayoutAttributes, set its frame using insetFrame and append the attributes to cache.
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            /*Expand contentHeight to account for the frame of the newly calculated item. Then, advance the yOffset for the current column based on the frame. Finally, advance the column so the next item will be placed in the next column.*/
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
        
    }
    //In this method, you return the layout attributes for all items inside the given rectangle. You return the attributes to the collection view as an array of UICollectionViewLayoutAttributes.
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        //loop through the cache and look for items in the rect
        for attributes in cache{
            if attributes.frame.intersects(rect){
                visibleLayoutAttributes.append(attributes)
            }
        }
        
        return visibleLayoutAttributes
    }
    //This method provides on demand layout information to the collection view. Need to override it and return the layout attributes for the item at the requested indexPath
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
