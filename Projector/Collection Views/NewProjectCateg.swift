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
    var categories = ["Learn", "Travel", "Buy", "Build", "Other"]
    
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
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.lightGray
    }
    //makes cells deselectable
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    //define color of deselected cell
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.init(displayP3Red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
    }
}

class CategoriesCell: UICollectionViewCell {
    
    //initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //good approach
    //change color for cell selected state
    override var isSelected: Bool{
        didSet{
//            self.backgroundColor = UIColor.purple
        }
    }
    
    let cellLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.init(displayP3Red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
        return label
    }()

    func setupViews(){
        //background color of cells
        backgroundColor = UIColor.init(displayP3Red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
        layer.cornerRadius = 11
        //layer.masksToBounds = true
        
        addSubview(cellLabel)
        
        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cellLabel.topAnchor.constraint(equalTo: topAnchor, constant: 90).isActive = true
        cellLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        cellLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        cellLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
    }
    
}

