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

struct RecentDay {
    // Date represents a given day in a month.
    let date: Date
    //The number to display on the collection view cell.
    let number: String
    //Date string that will be used for comparison
    let dateString: String
}

//this class should contain user activity object accessable to all view controllers and classes
class UserActivitySingleton {
    
    static let shared = UserActivitySingleton()
    
    //a bit trick here
    //because I don't want to deal with optionals everywhere I need to add new item
    //first create an empty object, and then it will be rewritten immediately
    var currentDayActivity = DayActivity()
    
    let calendar = Calendar(identifier: .gregorian)
    
    let selectedDate = Date()
    
    //create user activity object with date
    func createUserActivity(description: String){
        let userActivity = UserActivity()
        userActivity.date = Date()
        userActivity.descr = description
        ProjectListRepository.instance.appendNewItemToDayActivity(dayActivity: currentDayActivity, userActivity: userActivity)
    }
    
    private lazy var dateFormatterNumber: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    private lazy var dateFormatterFullDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter
    }()
    
    //takes day and return an array of days
    func generateDaysInMonth (for baseDate: Date) -> [RecentDay] {
        
        //last 29 days
        let offsetInInitialRow = 29
        // "first day of month" is today
        let firstDayOfMonth = Date()
        
        
        
        //calculate last 30 days from today
        let days: [RecentDay] = (0...29)
            .map { day in
                
                // check day for current or previous month
                let isWithinDisplayedMonth = day >= offsetInInitialRow
                
                // calculate the offset
                let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)
                
                // adds of substructs an offset from Date for new day
                return generateDay(offsetBy: dayOffset, for: firstDayOfMonth)
        }
        
        return days
    }
    
    //Generate Days For Calendar
    func generateDay( offsetBy dayOffset: Int, for baseDate: Date) -> RecentDay {
        
        let date = calendar.date( byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        
        return RecentDay(
            date: date,
            number: self.dateFormatterNumber.string(from: date),
            dateString: self.dateFormatterFullDate.string(from: date)
        )
    }
}



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
    
    //template
    var cellTemplate: DayActivity? {
        didSet{
            if let setting = cellTemplate{
                
                //if object exist, meens app was opened that day
                var str = "Looking!\n\n"
                
                for item in setting.userActivities{
                str += "\(item.descr)\n\n"
                }
                
                listLabel.text = str
            }
        }
    }
    
    let dayOfWeekLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(white: 1, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()
    
    let listLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "This is Dummy text, that \n will be used for developing."
        label.textAlignment = .center
        label.numberOfLines = 0
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
        addSubview(listLabel)
        
        dayOfWeekLabel.translatesAutoresizingMaskIntoConstraints = false
        dayNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        listLabel.translatesAutoresizingMaskIntoConstraints = false
        
        listLabel.topAnchor.constraint(equalTo: dayOfWeekLabel.bottomAnchor, constant: 10).isActive = true
        listLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        listLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        listLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40).isActive = true
        
        dayOfWeekLabel.topAnchor.constraint(equalTo: topAnchor, constant: 13).isActive = true
        dayOfWeekLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        dayOfWeekLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        dayOfWeekLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        dayNumberLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        dayNumberLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: -10).isActive = true
        dayNumberLabel.widthAnchor.constraint(equalToConstant: 64).isActive = true
        dayNumberLabel.heightAnchor.constraint(equalToConstant: 38).isActive = true
    }
    
}
