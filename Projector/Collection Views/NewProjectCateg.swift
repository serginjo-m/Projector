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
    //categories array
    var categories = ["TRAVEL", "FINANCE", "LEARNING", "FUN", "OTHER"]
    
    //this property need for cells
    private let cellID = "cellId"
    
    //here I want to have an actual category selected by user
    var categoryName = ""
    
    
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCategoryView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupCategoryView()
    }
    
    
    //here creates a horizontal collectionView inside stackView
    let categoryCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        collectionView.backgroundColor = UIColor.clear
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    func setupCategoryView(){
        // Add a collectionView to the stackView
        addArrangedSubview(categoryCollectionView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        
        //Class is need to be registered in order of using inside
        categoryCollectionView.register(CategoriesCell.self, forCellWithReuseIdentifier: cellID)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": categoryCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": categoryCollectionView]))
    }
    
    
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //here we don't need to use view.frame.height becouse our CategoryCell have it
        return CGSize(width: 82, height: frame.height)
    }
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return categories.count
    }
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CategoriesCell
        cell.cellLabel.text = categories[indexPath.row]
        return cell
    }
    
    //turn cells to be selectable
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    //action when user selects the cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //set a projects category name
        categoryName = categories[indexPath.row]
        
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
    }
}

class CategoriesCell: UICollectionViewCell {
    
    //initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 3
        //layer.masksToBounds = true
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //good approach
    //change color for cell selected state
    override var isSelected: Bool{
        didSet{
            self.backgroundColor = UIColor.purple
        }
    }
    
    let cellLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textColor = UIColor.white
        
        return label
    }()

    func setupViews(){
        //background color of cells
        backgroundColor = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1)
        
        addSubview(cellLabel)
        
        cellLabel.frame = CGRect(x: 0, y: 15, width: frame.width , height: 35.0)
    }
    
}

