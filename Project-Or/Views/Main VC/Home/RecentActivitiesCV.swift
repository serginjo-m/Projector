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
   
    lazy var days = UserActivitySingleton.shared.generateDaysInMonth(for: baseDate)
    var collectionViewDataSource: Results<DayActivity>?
   
    private let cellID = "cellId"
    
    var cellColors = [
        UIColor.init(red: 242/255, green: 98/255, blue: 98/255, alpha: 1),//7
        UIColor.init(red: 95/255, green: 74/255, blue: 99/255, alpha: 1),//1
        UIColor.init(red: 191/255, green: 105/255, blue: 128/255, alpha: 1),//2
        UIColor.init(red: 47/255, green: 119/255, blue: 191/255, alpha: 1),//3
        UIColor.init(red: 38/255, green: 166/255, blue: 153/255, alpha: 1),//4
        UIColor.init(red: 255/255, green: 213/255, blue: 87/255, alpha: 1),//5
        UIColor.init(red: 253/255, green: 169/255, blue: 65/255, alpha: 1)//6
    ]

    var daysOfWeek = ["Sa", "Fr", "Th", "We", "Tu", "Mo", "Su"]
    
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
    
    lazy var recentActivitiesCollectionView: UICollectionView = {

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
     
        collectionView.backgroundColor = UIColor.clear
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    func setupRecentActivitiesView(){
        
        addArrangedSubview(recentActivitiesCollectionView)
        
        recentActivitiesCollectionView.dataSource = self
        recentActivitiesCollectionView.delegate = self
        
        recentActivitiesCollectionView.showsHorizontalScrollIndicator = false
        recentActivitiesCollectionView.showsVerticalScrollIndicator = false
        recentActivitiesCollectionView.backgroundColor = UIColor.init(red: 95/255, green: 74/255, blue: 99/255, alpha: 1)
        recentActivitiesCollectionView.layer.cornerRadius = 6
        recentActivitiesCollectionView.layer.masksToBounds = true
        
        recentActivitiesCollectionView.register(RecentActivitiesCell.self, forCellWithReuseIdentifier: cellID)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": recentActivitiesCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": recentActivitiesCollectionView]))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! RecentActivitiesCell
        
        let int = (reversedWeekday + indexPath.row) % 7
        
        cell.backgroundColor = cellColors[int]
        cell.dayNumberLabel.backgroundColor = cellColors[int]
        cell.dayOfWeekLabel.text = daysOfWeek[int]
        let reverseIterNumber = (days.count - indexPath.row) - 1
        cell.dayNumberLabel.text = "\(days[reverseIterNumber].number)"

        cell.listLabel.text = ""

        if let dataSource = collectionViewDataSource{
            for item in dataSource{
                if item.date == days[reverseIterNumber].dateString{
                    cell.cellTemplate = item
                }
            }
        }
        return cell
    }
    
    func scrollBackCollectionView() {
        recentActivitiesCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
    }
}
