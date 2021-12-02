//
//  NewStepCategory.swift
//  Projector
//
//  Created by Serginjo Melnik on 27.04.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class NewStepCategory:UIStackView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    //Properties
    //this property need for cells
    private let cellId = "cellId"
    
    //contains unsorted categories
    var stepCategories = ["todo", "inProgress", "done", "blocked"]
    //uses for sort categories by num of letters in word
    var counts = [String: Int]()
    //array for sorted strings
    var sortedCategories = [String]()
    //category selected by user
    var selectedCategory = "todo"
    
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
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //layout.itemSize = CGSize(width: 120, height: 45)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clear
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    func setupCategoryView(){
        //create dictionary based on numb of letters in categories
        for word in stepCategories {
            counts[word] = word.count
        }
        //first sort by value and than extract keys
        sortedCategories = counts.sorted{$0.value > $1.value}.map{$0.key}
        
        // Add a DataView to the stackView
        addArrangedSubview(categoryCollectionView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        
        //Class is need to be registered in order of using inside
        categoryCollectionView.register(NewStepCategoryCell.self, forCellWithReuseIdentifier: cellId)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": categoryCollectionView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": categoryCollectionView]))
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = sortedCategories[indexPath.row]
        var itemSize = item.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)])
        itemSize.width += 15
        itemSize.height += 5
        return itemSize
    }
    
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stepCategories.count
    }
    
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NewStepCategoryCell
        cell.categoryLabel.text = sortedCategories[indexPath.row]
        if cell.isSelected == true{
            cell.layer.backgroundColor = UIColor.yellow.cgColor
        }else{
            cell.layer.backgroundColor = UIColor.clear.cgColor
        }
        return cell
    }
    
    //turn cells to be selectable
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    //action when user selects the cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //set a projects category name
        selectedCategory = sortedCategories[indexPath.row]
        //that is how I can call a selected cell !!!
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.green
    }
    //makes cells deselectable
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    //define color of deselected cell
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.clear
    }
}

class NewStepCategoryCell: UICollectionViewCell{
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
 /*
    //change color for cell selected state
    override var isSelected: Bool{
        didSet{
            self.backgroundColor = UIColor.yellow
        }
    }
  */
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "default"
        //label.backgroundColor = UIColor.yellow
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.darkGray
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        return label
    }()
    
    func setupViews(){
        addSubview(categoryLabel)
        
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            categoryLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            categoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            categoryLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            categoryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
        ]
        
        NSLayoutConstraint.activate(constraints)

    }
}
