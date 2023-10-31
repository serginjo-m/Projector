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
    
    private let cellID = "cellId"
    
    weak var delegate: DetailViewControllerDelegate?
    
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
    
    let viewByCategoryCollectionView: UICollectionView = {
    
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    func setupViewByCategoryView(){
        
        addArrangedSubview(viewByCategoryCollectionView)
        
        viewByCategoryCollectionView.dataSource = self
        viewByCategoryCollectionView.delegate = self
        viewByCategoryCollectionView.showsHorizontalScrollIndicator = false
        viewByCategoryCollectionView.showsVerticalScrollIndicator = false
        viewByCategoryCollectionView.register(ViewByCategoryCell.self, forCellWithReuseIdentifier: cellID)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": viewByCategoryCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": viewByCategoryCollectionView]))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 125, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ViewByCategoryCell

        cell.configureCell = cellSettingsArray[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.pushToViewController(controllerType: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1)
    }
}
