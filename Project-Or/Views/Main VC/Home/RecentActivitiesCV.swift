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
   
    
    let baseDate = Date()
    //an array of days
    lazy var days = UserActivitySingleton.shared.generateDaysInMonth(for: baseDate)
    
    //data source
    var collectionViewDataSource: Results<DayActivity>?
    
    //this property need for cells
    private let cellID = "cellId"
    // colors for 7 days
    var cellColors = [
        UIColor.init(red: 242/255, green: 98/255, blue: 98/255, alpha: 1),//7
        UIColor.init(red: 95/255, green: 74/255, blue: 99/255, alpha: 1),//1
        UIColor.init(red: 191/255, green: 105/255, blue: 128/255, alpha: 1),//2
        UIColor.init(red: 47/255, green: 119/255, blue: 191/255, alpha: 1),//3
        UIColor.init(red: 38/255, green: 166/255, blue: 153/255, alpha: 1),//4
        UIColor.init(red: 255/255, green: 213/255, blue: 87/255, alpha: 1),//5
        UIColor.init(red: 253/255, green: 169/255, blue: 65/255, alpha: 1)//6
    ]
    
    //reversed days of week

    var daysOfWeek = ["Sa", "Fr", "Th", "We", "Tu", "Mo", "Su"]
    
    
    //last item weekday
    lazy var reversedWeekday = 7 - (Calendar.current.component(.weekday, from: days.last!.date))
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRecentActivitiesView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupRecentActivitiesView()
    }
    
    var visualLayoutConstraints = UltravisualLayoutConstants()
    
    lazy var layout: UltravisualLayout = {
        let layout = UltravisualLayout(layoutConstraints: self.visualLayoutConstraints)
        return layout
    }()
    
    //here creates a horizontal collectionView inside stackView
    lazy var recentActivitiesCollectionView: UICollectionView = {

       
        //because every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
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
        //this color is not so important, because CV need to fill everything
        recentActivitiesCollectionView.backgroundColor = UIColor.init(red: 95/255, green: 74/255, blue: 99/255, alpha: 1)
        recentActivitiesCollectionView.layer.cornerRadius = 6
        recentActivitiesCollectionView.layer.masksToBounds = true
        
        //Class is need to be registered in order of using inside
        recentActivitiesCollectionView.register(RecentActivitiesCell.self, forCellWithReuseIdentifier: cellID)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": recentActivitiesCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": recentActivitiesCollectionView]))
        
    }
    
    
    
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
  
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! RecentActivitiesCell
        
        //loop through array of 7 colors & 7 weekdays multiple times
        let int = (reversedWeekday + indexPath.row) % 7
        
        cell.backgroundColor = cellColors[int]
        cell.dayNumberLabel.backgroundColor = cellColors[int]
        //day of week
        cell.dayOfWeekLabel.text = daysOfWeek[int]
        //day number
        
        let reverseIterNumber = (days.count - indexPath.row) - 1
    
        cell.dayNumberLabel.text = "\(days[reverseIterNumber].number)"
        //take action list clear before doing iterations
        cell.listLabel.text = ""
        //at first run data source is empty
        if let dataSource = collectionViewDataSource{
            //not so efficient but...., for small amount of items
            for item in dataSource{
                if item.date == days[reverseIterNumber].dateString{
                    cell.cellTemplate = item
                }
            }
        }
        return cell
    }
    //scrolls back collection view after ...
    func scrollBackCollectionView() {
        recentActivitiesCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
    }
}
