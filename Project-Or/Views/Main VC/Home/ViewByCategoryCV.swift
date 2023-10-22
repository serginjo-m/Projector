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

class ViewByCategoryCollectionView: UIStackView,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    //this property need for cells
    private let cellID = "cellId"
    
    //most for reload data
    weak var delegate: DetailViewControllerDelegate?
    
    // cell settings
    let cellSettingsArray: [CategoryButtonSetting] = {
        return [
            CategoryButtonSetting(
                imageName: "camera",
                cellColor: UIColor.init(red: 251/255, green: 137/255, blue: 181/255, alpha: 1),
                buttonTitle: "PHOTO NOTES",
                imageWidth: 76,
                imageHeight: 58,
                imageTopAnchor: 6,
                imageLeftAnchor: -12,
                titleLeftAnchor: 65
            ),
            CategoryButtonSetting(
                imageName: "colorPalete",
                cellColor:UIColor.init(red: 36/255, green: 140/255, blue: 232/255, alpha: 1),
                buttonTitle: "PICTURE NOTES",
                imageWidth: 113,
                imageHeight: 85,
                imageTopAnchor: 9,
                imageLeftAnchor: -61,
                titleLeftAnchor: 55
            ),
            CategoryButtonSetting(
                imageName: "letters",
                cellColor: UIColor.init(red: 255/255, green: 213/255, blue: 87/255, alpha: 1),
                buttonTitle: "TEXT NOTES",
                imageWidth: 48,
                imageHeight: 39,
                imageTopAnchor: 15,
                imageLeftAnchor: 8,
                titleLeftAnchor: 65
            )
        ]
    }()
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewByCategoryView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupViewByCategoryView()
    }
    
    //here creates a horizontal collectionView inside stackView
    let viewByCategoryCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        //spacing...
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //layout.itemSize = CGSize(width: 120, height: 45)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        
        //because every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        collectionView.backgroundColor = UIColor.clear
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    func setupViewByCategoryView(){
        
        // Add a collectionView to the stackView
        addArrangedSubview(viewByCategoryCollectionView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        viewByCategoryCollectionView.dataSource = self
        viewByCategoryCollectionView.delegate = self
        
        viewByCategoryCollectionView.showsHorizontalScrollIndicator = false
        viewByCategoryCollectionView.showsVerticalScrollIndicator = false
        
        //Class is need to be registered in order of using inside
        viewByCategoryCollectionView.register(ViewByCategoryCell.self, forCellWithReuseIdentifier: cellID)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": viewByCategoryCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": viewByCategoryCollectionView]))
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //here we don't need to use view.frame.height because our CategoryCell have it
        return CGSize(width: 125, height: frame.height)
    }
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ViewByCategoryCell
        
        
        //here is IMPORTANT part, when I pass settings for every cell
        cell.configureCell = cellSettingsArray[indexPath.row]
        
        return cell
        
    }
    
    //turn cells to be selectable
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    //action when user selects the cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //push to category items view controller
        self.delegate?.pushToViewController(controllerType: indexPath.row)
        
        //that is how I can call a selected cell !!!
//        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.red
    }
    //makes cells deselectable
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    //define color of deselected cell
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1)
    }
    
}
