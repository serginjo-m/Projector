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
//MARK: OK
class CalendarViewController: UIViewController, UICollectionViewDelegate{
    //MARK: Properties
    var events: Results<Event> {
        get {
            return ProjectListRepository.instance.getEvents()
        }
    }
    
    var downloadedHolidaysYear: Int {
        get{
            let holidays = ProjectListRepository.instance.getHolidays()
            if holidays.count > 0{
                if let item = holidays.first{
                    return item.year
                }
            }
            return 0
        }
    }
    
    var groupedEventDictionary = [ Date : [Event]]()
    
    lazy var blackView: UIView = {
        let view = UIView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.25)
        view.alpha = 0
        return view
    }()
    
    //valid frame, fixes constraints error
    lazy var eventElements : EventElementsView = {
        
        let eventElementViewController = EventElementsView()
        //Zoom logic
        //CalendarViewConroller -> EventElementsView -> EventTableViewCell -> performZoomForStartingEventView()
        eventElementViewController.calendarViewController = self
        //80% of width
        let width = 80 * self.view.frame.width / 100
        eventElementViewController.frame = CGRect(x: -self.view.frame.width, y: 0, width: width, height: self.view.frame.height)
        return eventElementViewController
    }()
    var startingFrame: CGRect?
    var zoomBackgroundView: UIView?
    var startingEventView: UIView?

    let cellID = "cellId"
    let calendar = Calendar(identifier: .gregorian)
    var selectedDate = Date()
    var baseDate: Date {
        didSet {
            //update page elements
            updateAllPageElements()
        }
    }
    
    //NotificationViewController requests to display date from notification
    var dateToDisplay: Date?
    //an array of days
    lazy var days = generateDaysInMonth(for: baseDate)
    //represents the number of weeks in the currently-displayed month
    var numberOfWeeksInBaseDate: Int {
        return calendar.range(of: .weekOfMonth, in: .month, for: baseDate)?.count ?? 0
    }
    //once selected date changed need to pass closure
    let selectedDateChanged: ((Date) -> Void)
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    let calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    lazy var headerView = CalendarHeaderView ()
    
    lazy var footerView = CalendarFooterView(
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
    
    // MARK: Initializers
    init(baseDate: Date, selectedDateChanged: @escaping ((Date) -> Void) ) {
        self.selectedDate = baseDate
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
    
    //MARK: VC Lifecycle
    override func viewDidLoad() {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
        
        view.backgroundColor = .white
        
        setupCalendarCollectionView()
        
        headerView.baseDate = baseDate
        setupConstraints()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        calendarCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //database update
        self.assembleGroupedEvents()
        
        //if sidebar is visible, perform update
        if eventElements.frame.origin.x >= 0.0 {
            guard let currentDate = self.eventElements.currentDate else {return}
            self.updateCalendarContent(date: currentDate)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let unwrappedDateToDisplay = dateToDisplay {
            //define day events database
            eventsArrayFromDateKey(date: unwrappedDateToDisplay)
            //calendar in background
            self.baseDate = unwrappedDateToDisplay
            //reset a request
            dateToDisplay = nil
        }else{
            baseDate = Date()
            selectedDate = Date()
        }
    }
    
    //MARK: Methods
    func setupCalendarCollectionView(){
        view.addSubview(calendarCollectionView)
        view.addSubview(headerView)
        view.addSubview(footerView)
        view.addSubview(blackView)
        view.addSubview(eventElements)
        
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        calendarCollectionView.showsHorizontalScrollIndicator = false
        calendarCollectionView.showsVerticalScrollIndicator = false
        calendarCollectionView.register(CalendarCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    func updateAllPageElements(){
        //return an array of days
        days = generateDaysInMonth(for: baseDate)
        //reload
        calendarCollectionView.reloadData()
        //set a header base date
        headerView.baseDate = baseDate
    }
    
    func assembleGroupedEvents(){
        //[ Date : [Event]]
        groupedEventDictionary = Dictionary(grouping: events) { (event) -> Date in
            // roll back, to the start of the day so time no matter
            return calendar.startOfDay(for: event.date!)
        }
    }
    
    
    func setupConstraints(){
        headerView.translatesAutoresizingMaskIntoConstraints = false
        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 78).isActive = true
        
        calendarCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        calendarCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        calendarCollectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10).isActive = true
        calendarCollectionView.bottomAnchor.constraint(equalTo: footerView.topAnchor, constant: 0).isActive = true
        
        footerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        footerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        footerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
    }
}


