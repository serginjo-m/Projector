//
//  ProjectData.swift
//  Projector
//
//  Created by Serginjo Melnik on 16.04.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit



    //Not so sure about creating everytime new class for every collection view, maybe reuse needed

class ProjectData: UIStackView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    //Properties
    //this property need for cells
    private let cellId = "cellId"
    
    //Database
    var project: ProjectList?
    
    //contain projects values
    var projectArray = [String]()
    
    //contains projects description of values
    var projectDescriptionLabels = ["Total Cost", "Budget", "Distance", "Spendings"]
    
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDataView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupDataView()
    }
    
    let dataCollectionView: UICollectionView = {
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
    
    func setupDataView(){
        
        // Add a DataView to the stackView
        addArrangedSubview(dataCollectionView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        dataCollectionView.dataSource = self
        dataCollectionView.delegate = self
        
        //Class is need to be registered in order of using inside
        dataCollectionView.register(DataCell.self, forCellWithReuseIdentifier: cellId)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": dataCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": dataCollectionView]))
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //this stuff is about finding a size of string
        //--------------- here I need to iterate through project values ------------
        //print(projectArray[indexPath.row])
        let item = projectArray[indexPath.row]
        let itemSize = item.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30)])
        
        //becouse if size too small description will be covered
        if itemSize.width < 80 {
            return CGSize(width: 80.0, height: 35.8)
        }
        
        return itemSize
    }
    
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projectArray.count
    }
    
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DataCell
        
        //temporary solution
        cell.valueLabel.text = projectArray[indexPath.row]
        cell.descriptionLabel.text = projectDescriptionLabels[indexPath.row]
        
        // here I assign a specific style to a part of the string
        let smallFont = UIFont.systemFont(ofSize: 15)
        let attrString = NSMutableAttributedString(string: cell.valueLabel.text!)
        
        //becouse distance units is km, perform another configuration
        if cell.descriptionLabel.text == "Distance"{
           attrString.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: smallFont, range: NSMakeRange(cell.valueLabel.text!.count - 2 , 2))
        } else {
            attrString.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: smallFont, range: NSMakeRange(cell.valueLabel.text!.count - 1 , 1))
        }
        //here I add configuration
        cell.valueLabel.attributedText = attrString
        
        return cell
    }
}

class DataCell: UICollectionViewCell{

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
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.text = "300$"
        label.textColor = UIColor.darkGray
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 30.0)
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Cost"
        label.textColor = UIColor.darkGray
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    func setupViews(){
        
        //backgroundColor = UIColor.blue
        addSubview(valueLabel)
        addSubview(descriptionLabel)

        descriptionLabel.frame = CGRect(x: 0, y: 35, width: frame.width, height: 15)
        valueLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: 36)
    }
}
