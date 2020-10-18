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
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        //spacing...
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
    
    func setupRecentActivitiesView(){
        
        // Add a collectionView to the stackView
        addArrangedSubview(recentActivitiesCollectionView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        recentActivitiesCollectionView.dataSource = self
        recentActivitiesCollectionView.delegate = self
        
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
        return CGSize(width: 54, height: frame.height)
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
