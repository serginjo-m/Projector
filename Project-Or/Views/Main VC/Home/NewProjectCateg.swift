//
//  CategoriesCollectionView.swift
//  Projector
//
//  Created by Serginjo Melnik on 05.04.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class CategoryCollectionView: UIStackView,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //MARK: Properties
    var categories = ["Learn", "Travel", "Buy", "Build", "Other"]
    
    private let cellID = "cellId"
    
    var categoryName = ""
    
    var colors: [UIColor] = [UIColor.init(red: 90/255, green: 123/255, blue: 232/255, alpha: 1),
                           UIColor.init(red: 32/255, green: 31/255, blue: 29/255, alpha: 1),
                           UIColor.init(red: 235/255, green: 201/255, blue: 79/255, alpha: 1),
                           UIColor.init(red: 236/255, green: 157/255, blue: 65/255, alpha: 1),
                           UIColor.init(red: 227/255, green: 79/255, blue: 70/255, alpha: 1)]
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCategoryView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupCategoryView()
    }
    
    let categoryCollectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clear
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    func setupCategoryView(){

        addArrangedSubview(categoryCollectionView)

        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.showsVerticalScrollIndicator = false
        
        categoryCollectionView.register(CategoriesCell.self, forCellWithReuseIdentifier: cellID)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": categoryCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": categoryCollectionView]))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 82, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CategoriesCell
        cell.cellLabel.text = categories[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        categoryName = categories[indexPath.row]
        
        collectionView.cellForItem(at: indexPath)?.backgroundColor = self.colors[indexPath.item]
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoriesCell {
            cell.cellLabel.textColor = .white
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.init(displayP3Red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoriesCell {
            cell.cellLabel.textColor = UIColor.init(displayP3Red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
        }
    }
}
