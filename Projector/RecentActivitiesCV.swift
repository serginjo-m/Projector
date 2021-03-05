//
//  RecentActivitiesCV.swift
//  Projector
//
//  Created by Serginjo Melnik on 05.10.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

// The heights are declared as constants outside of the class so they can be easily referenced elsewhere
struct UltravisualLayoutConstants {
    struct Cell {
        // The height of the non-featured cell
        static let standardHeight: CGFloat = 100
        // The height of the first visible cell
        static let featuredHeight: CGFloat = 280
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
        return max(0, Int(collectionView!.contentOffset.y / dragOffset))
    }
    
    // Returns a value between 0 and 1 that represents how close the next cell is to becoming the featured cell
    var nextItemPercentageOffset: CGFloat {
        return (collectionView!.contentOffset.y / dragOffset) - CGFloat(featuredItemIndex)
    }
    
    // Returns the width of the collection view
    var width: CGFloat {
        return collectionView!.bounds.width
    }
    
    // Returns the height of the collection view
    var height: CGFloat {
        return collectionView!.bounds.height
    }
    
    // Returns the number of items in the collection view
    var numberOfItems: Int {
        return collectionView!.numberOfItems(inSection: 0)
    }
}

// MARK: UICollectionViewLayout

extension UltravisualLayout {
    // Return the size of all the content in the collection view
    override var collectionViewContentSize : CGSize {
        let contentHeight = (CGFloat(numberOfItems) * dragOffset) + (height - dragOffset)
        return CGSize(width: width, height: contentHeight)
    }
    
    override func prepare() {
        cache.removeAll(keepingCapacity: false)
        
        let standardHeight = UltravisualLayoutConstants.Cell.standardHeight
        let featuredHeight = UltravisualLayoutConstants.Cell.featuredHeight
        
        var frame = CGRect.zero
        var y: CGFloat = 0
        
        for item in 0..<numberOfItems {
            // 1
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            // 2
            attributes.zIndex = item
            var height = standardHeight
            
            // 3
            if indexPath.item == featuredItemIndex {
                // 4
                let yOffset = standardHeight * nextItemPercentageOffset
                y = collectionView!.contentOffset.y - yOffset
                height = featuredHeight
            } else if indexPath.item == (featuredItemIndex + 1)
                && indexPath.item != numberOfItems {
                // 5
                let maxY = y + standardHeight
                height = standardHeight + max(
                    (featuredHeight - standardHeight) * nextItemPercentageOffset, 0
                )
                y = maxY - height
            }
            
            // 6
            frame = CGRect(x: 0, y: y, width: width, height: height)
            attributes.frame = frame
            cache.append(attributes)
            y = frame.maxY
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

class RecentActivitiesCollectionView: UIStackView,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    //this property need for cells
    private let cellID = "cellId"
    // colors for 7 days
    var cellColors = [
        UIColor.init(red: 95/255, green: 74/255, blue: 99/255, alpha: 1),
        UIColor.init(red: 191/255, green: 105/255, blue: 128/255, alpha: 1),
        UIColor.init(red: 47/255, green: 119/255, blue: 191/255, alpha: 1),
        UIColor.init(red: 38/255, green: 166/255, blue: 153/255, alpha: 1),
        UIColor.init(red: 255/255, green: 213/255, blue: 87/255, alpha: 1),
        UIColor.init(red: 253/255, green: 169/255, blue: 65/255, alpha: 1),
        UIColor.init(red: 242/255, green: 98/255, blue: 98/255, alpha: 1)
    ]
    
    var daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
    // dummy date, need improvements
    var dayNumbers = [24, 25, 26, 27, 28, 29, 30]
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRecentActivitiesView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupRecentActivitiesView()
    }
    
    //here creates a horizontal collectionView inside stackView
    let recentActivitiesCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UltravisualLayout()
        
        //changing default direction of scrolling
//        layout.scrollDirection = .horizontal
//
//        //spacing...
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        //layout.itemSize = CGSize(width: 120, height: 45)
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
//
        
        
        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clear
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    func setupRecentActivitiesView(){
        
        
        
        // Add a collectionView to the stackView
        addArrangedSubview(recentActivitiesCollectionView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        recentActivitiesCollectionView.dataSource = self
        recentActivitiesCollectionView.delegate = self
        
        recentActivitiesCollectionView.showsHorizontalScrollIndicator = false
        recentActivitiesCollectionView.showsVerticalScrollIndicator = false
        
        
        
        //style configurations
        //this color is not so important, becouse CV need to fill everything
        recentActivitiesCollectionView.backgroundColor = UIColor.init(red: 95/255, green: 74/255, blue: 99/255, alpha: 1)
        recentActivitiesCollectionView.layer.cornerRadius = 6
        recentActivitiesCollectionView.layer.masksToBounds = true
        
        //Class is need to be registered in order of using inside
        recentActivitiesCollectionView.register(RecentActivitiesCell.self, forCellWithReuseIdentifier: cellID)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": recentActivitiesCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": recentActivitiesCollectionView]))
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //here we don't need to use view.frame.height becouse our CategoryCell have it
        return CGSize(width: frame.height/2, height: frame.height )
    }
    
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //here I need num based on ...
        return 7
    }
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! RecentActivitiesCell
        //define day color
        cell.backgroundColor = cellColors[indexPath.row]
        //day of week
        cell.dayOfWeekLabel.text = daysOfWeek[indexPath.row]
        //day number
        cell.dayNumberLabel.text = String(dayNumbers[indexPath.row])
        return cell
    }
    
    // Need to perform action when user select cell
    
    /*turn cells to be selectable
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    //action when user selects the cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //that is how I can call a selected cell !!!
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.red
    }
    //makes cells deselectable
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    //define color of deselected cell
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1)
    }*/
    
}

class RecentActivitiesCell: UICollectionViewCell {
    
    //initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        //layer.cornerRadius = 3
        //layer.masksToBounds = true
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let dayOfWeekLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(white: 1, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    }()
    
    let dayNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(white: 1, alpha: 0.28)
        label.font = UIFont.boldSystemFont(ofSize: 50)
        
        return label
    }()
    
    func setupViews(){
        //mask content outside cell
        layer.masksToBounds = true
        
        addSubview(dayOfWeekLabel)
        addSubview(dayNumberLabel)
        
        dayOfWeekLabel.translatesAutoresizingMaskIntoConstraints = false
        dayNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dayOfWeekLabel.topAnchor.constraint(equalTo: topAnchor, constant: 13).isActive = true
        dayOfWeekLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        dayOfWeekLabel.widthAnchor.constraint(equalToConstant: 13).isActive = true
        dayOfWeekLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        dayNumberLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        dayNumberLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: -10).isActive = true
        dayNumberLabel.widthAnchor.constraint(equalToConstant: 64).isActive = true
        dayNumberLabel.heightAnchor.constraint(equalToConstant: 38).isActive = true
    }
    
}
