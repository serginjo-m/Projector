//
//  CalendarVC.swift
//  Projector
//
//  Created by Serginjo Melnik on 09.12.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//
import UIKit
import RealmSwift
import Foundation
import os
import Photos

class CalendarViewController: UIViewController, UICollectionViewDelegate{
    
    
    //MARK: Properties
    let cellID = "cellId"
    //Creates new calendar
    let calendar = Calendar(identifier: .gregorian)
    //date selected by user
    private var selectedDate: Date
    //current date
    private var baseDate: Date {
        didSet {
            days = generateDaysInMonth(for: baseDate)
            calendarCollectionView.reloadData()
            headerView.baseDate = baseDate
        }
    }
    
    private lazy var days = generateDaysInMonth(for: baseDate)
    
    private var numberOfWeeksInBaseDate: Int {
        return calendar.range(of: .weekOfMonth, in: .month, for: baseDate)?.count ?? 0
    }
    
    private let selectedDateChanged: ((Date) -> Void)
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    //here creates a horizontal collectionView inside stackView
    let calendarCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        //spacing
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.isScrollEnabled = false
        
        collectionView.backgroundColor = .white
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private lazy var headerView = CalendarHeaderView ()
    
    private lazy var footerView = CalendarFooterView(
        didTapLastMonthCompletionHandler: { [weak self] in
            guard let self = self else { return }
            
            self.baseDate = self.calendar.date(
                byAdding: .month,
                value: -1,
                to: self.baseDate
                ) ?? self.baseDate
        },
        didTapNextMonthCompletionHandler: { [weak self] in
            guard let self = self else { return }
            
            self.baseDate = self.calendar.date(
                byAdding: .month,
                value: 1,
                to: self.baseDate
                ) ?? self.baseDate
    })
    
    
    //MARK: Methods
    func setupCalendarCollectionView(){
        
        // Add a collectionView to the stackView
        view.addSubview(calendarCollectionView)
        view.addSubview(headerView)
        view.addSubview(footerView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        
        calendarCollectionView.showsHorizontalScrollIndicator = false
        calendarCollectionView.showsVerticalScrollIndicator = false
        
        //Class is need to be registered in order of using inside
        calendarCollectionView.register(CalendarCell.self, forCellWithReuseIdentifier: cellID)
        
        //CollectionView constraints
        //NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": calendarCollectionView]))
        
        //NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-85-[v0]-180-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": calendarCollectionView]))
    }
    
    // MARK: Initializers
    init(baseDate: Date, selectedDateChanged: @escaping ((Date) -> Void) ) {
        //what is the diff btwn selectedDate....
        self.selectedDate = baseDate
        //.... and baseDate
        self.baseDate = baseDate
        self.selectedDateChanged = selectedDateChanged
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        definesPresentationContext = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
        view.backgroundColor = .white
        setupCalendarCollectionView()
        
        headerView.baseDate = baseDate
        setupConstraints()
        
    }
    
    func setupConstraints(){
        headerView.translatesAutoresizingMaskIntoConstraints = false
        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 85).isActive = true
        
        calendarCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        calendarCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        calendarCollectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        calendarCollectionView.bottomAnchor.constraint(equalTo: footerView.topAnchor, constant: 0).isActive = true
        
        footerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        footerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        footerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        calendarCollectionView.reloadData()
    }
}


extension CalendarViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let day = days[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CalendarCell
        cell.day = day
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = days[indexPath.row]
        selectedDateChanged(day.date)
    }
    //calculate size of EACH cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(collectionView.frame.width / 7)
        let height = Int(collectionView.frame.height) / numberOfWeeksInBaseDate
        return CGSize(width: width, height: height)
    }
}

extension CalendarViewController {
    //accept Date and return MonthMetadata object
    func monthMetadata(for baseDate: Date) throws -> MonthMetadata{
        //asks calendar for the number of days in basedate's month. return first day
        guard
            let numberOfDaysInMonth = calendar.range(
                of: .day,
                in: .month,
                for: baseDate)?.count,
            let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate))
            
            else{
                throw CalendarDataError.metadataGeneration
        }
        
        //which day of the week first day of month falls on
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        return MonthMetadata(
            numberOfDays: numberOfDaysInMonth,
            firstDay: firstDayOfMonth,
            firstDayWeekday: firstDayWeekday)
        
    }
    
    //takes day and return an array of days
    func generateDaysInMonth (for baseDate: Date) -> [Day] {
        //calls metadata function for object
        guard let metadata = try? monthMetadata(for: baseDate) else {
            fatalError("An error occurred when generating the metadata for \(baseDate)")
        }
        //extract values from object
        let numberOfDaysInMonth = metadata.numberOfDays
        let offsetInInitialRow = metadata.firstDayWeekday
        let firstDayOfMonth = metadata.firstDay
        
        //adds extra bit to begining of month if needed
        var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
            .map { day in
                // check day for current or previous month
                let isWithinDisplayedMonth = day >= offsetInInitialRow
                
                // calculate the offset
                let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)
                
                // adds of substructs an offset from Date for new day
                return generateDay(offsetBy: dayOffset, for: firstDayOfMonth, isWithinDisplayedMonth: isWithinDisplayedMonth)
        }
        
        days += generateStartOfNextMonth(using: firstDayOfMonth)
        
        return days
    }
    
    // 7 : Generate Days For Calendar
    func generateDay( offsetBy dayOffset: Int, for baseDate: Date, isWithinDisplayedMonth: Bool) -> Day {
        
        let date = calendar.date( byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        
        return Day( date: date, number: self.dateFormatter.string(from: date), isSelected: calendar.isDate(date, inSameDayAs: selectedDate), isWithinDisplayedMonth: isWithinDisplayedMonth)
    }
    
    // add extra bit to the end of the month, if needed
    func generateStartOfNextMonth(using firstDayOfDisplayedMonth: Date) -> [Day] {
        // retreave the last day of month
        guard
            let lastDayInMonth = calendar.date(
                byAdding: DateComponents(month: 1, day: -1),
                to: firstDayOfDisplayedMonth)
            else {
                return []
        }
        
        // calculate num of days for extra bit, if needed
        let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
        guard additionalDays > 0 else {
            return []
        }
        
        // from Range<Int> to an array of days
        let days: [Day] = (1...additionalDays).map { generateDay(offsetBy: $0, for: lastDayInMonth, isWithinDisplayedMonth: false)}
        
        return days
    }
    
    enum CalendarDataError: Error {
        case metadataGeneration
    }
}



