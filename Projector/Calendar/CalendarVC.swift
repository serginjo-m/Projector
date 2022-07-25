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
    
    //events list
    var events: Results<Event> {
        get {
            return ProjectListRepository.instance.getEvents()
        }
    }
    
    //----------------------------------- Should be improved ---------------------------------------------
    //------------------------- for multiple countries it can be multiple years --------------------------
    //a year, when holidays was downloaded
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
    
    
    //events dictionary grouped by date
    var groupedEventDictionary = [ Date : [Event]]()
    
    
    //transparent black view that covers all content
    //IMPORTANT:
    //here I can add gesture recognizer because lazy var
    lazy var blackView: UIView = {
        let view = UIView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.25)
        view.alpha = 0
        return view
    }()
    
    //------------------------- a bit trick because of constraint error ---------------------------
    //need to give a valid frame to event elements when initialize it
    //so error "Unable to simultaneously satisfy constraints" is gone
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
    //hold dimension of event view displayed in side panel before zoomimg it to full dimension
    var startingFrame: CGRect?
    //background behind full dimension event, after it zooms in
    var zoomBackgroundView: UIView?
    //need to hide it before animation starts
    var startingEventView: UIView?
    
    //MARK: Properties
    let cellID = "cellId"
    //Creates new calendar
    let calendar = Calendar(identifier: .gregorian)
    //date selected by user
    private var selectedDate: Date
    //current date
    
    var baseDate: Date {
        didSet {
            //update page elements
            updateAllPageElements()
            
        }
    }
    
    //NotificationViewController can request to display date from notification
    var dateToDisplay: Date?
    
    //an array of days
    private lazy var days = generateDaysInMonth(for: baseDate)
    
    //represents the number of weeks in the currently-displayed month
    private var numberOfWeeksInBaseDate: Int {
        return calendar.range(of: .weekOfMonth, in: .month, for: baseDate)?.count ?? 0
    }
    //once selected date changed need to pass closure
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
        
        //because every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
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
        
        view.addSubview(blackView)
        view.addSubview(eventElements)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        
        calendarCollectionView.showsHorizontalScrollIndicator = false
        calendarCollectionView.showsVerticalScrollIndicator = false
        
        //Class is need to be registered in order of using inside
        calendarCollectionView.register(CalendarCell.self, forCellWithReuseIdentifier: cellID)
        
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        calendarCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Events data base for calendar
        assembleGroupedEvents()
        //day is need to be current everytime calendar appears &
        //as date is set, all updateAllPageElements calls
        baseDate = Date()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let unwrappedDateToDisplay = dateToDisplay {
            //define day events data base
            eventsArrayFromDateKey(date: unwrappedDateToDisplay)
            //calendar in background
            self.baseDate = unwrappedDateToDisplay
            //reset request 
            dateToDisplay = nil
        }
    }
    
    private func updateAllPageElements(){
        //return an array of days
        days = generateDaysInMonth(for: baseDate)
        //reload everytime
        calendarCollectionView.reloadData()
        //set header base date
        headerView.baseDate = baseDate
    }
    //creates Dictionary and ....
    func assembleGroupedEvents(){
        //[ Date : [Event]]
        groupedEventDictionary = Dictionary(grouping: events) { (event) -> Date in
            // roll back to start of day so time no metter
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
    
        //define day events data base
        eventsArrayFromDateKey(date: day.date)
    }
    
    //calculate size of EACH cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = Int(collectionView.frame.width / 7)
        
        return CGSize(width: width, height: 70)
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
        
        //test date like a Dictionary[key] in groupedDictionary to find out is there an event
        var dateWithEvent = false
        var dateWithHoliday = false
        
        
        //check for holidays when user view different year from year when holidays was downloaded
        let calendar = Calendar(identifier: .gregorian)
        let ymd = calendar.dateComponents([.year, .month, .day], from: date)
        
        if let year = ymd.year, let month = ymd.month, let day = ymd.day{
            //check if year is different
            if year != downloadedHolidaysYear{
                //calculate what difference is
                let yearDifference =  downloadedHolidaysYear - year
                            
                let dateComponents = DateComponents(year: year + yearDifference , month: month, day: day)
                let holidayDate = calendar.date(from: dateComponents)
                
                if let unwrappedHolidayDate = holidayDate{
                    //ckeck for holiday in given day-month in database for different year
                    groupedEventDictionary[unwrappedHolidayDate]?.forEach{
                        //pick holidays only inside array, not user events
                        if $0.category == "holiday"{
                            dateWithHoliday = true
                        }
                    }
                }
            }
           
        }
        
        //iterate through an array of events, to test category
        groupedEventDictionary[date]?.forEach{
            
            if $0.category == "holiday"{
                dateWithHoliday = true
            }else if $0.category != "holiday"{
                //all user events like calendar event(nil) or step event(projectStep) must have red circle
                dateWithEvent = true
            }
        }
        
        return Day( date: date, number: self.dateFormatter.string(from: date), isSelected: calendar.isDate(date, inSameDayAs: selectedDate), isWithinDisplayedMonth: isWithinDisplayedMonth,  containEvent: dateWithEvent, containHoliday: dateWithHoliday)
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
    
    //custom zooming logic
    func performZoomForStartingEventView(event: Event, startingEventView: UIView){
        //save reference to the View() , so it can be used later
        self.startingEventView = startingEventView
        //hide view
        self.startingEventView?.isHidden = true
        
        
        //casting view to EventBubbleView, so I can use its params
        guard let unwEventBubbleView = startingEventView as? EventBubbleView,
              //it is a whole view frame
              let unwStartingFrame = startingEventView.superview?.convert(startingEventView.frame, to: nil) else {return}
                
        //bubble view padding from cell
        let bubblePadding: CGFloat = 6
        //bubble frame
        let bubbleFrame = CGRect(x: unwStartingFrame.origin.x, y: unwStartingFrame.origin.y, width: unwStartingFrame.width - bubblePadding, height: unwStartingFrame.height)
        
        //bubbleView is a little bit thinner
        startingFrame = bubbleFrame
        
        //expanded view size should start from small
        let zoomingView = ZoomingView(event: event, frame: bubbleFrame)
        //dismiss is not a button. It is a view
        zoomingView.dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))
        zoomingView.descriptionLabel.font = unwEventBubbleView.descriptionLabel.font
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            //black transpared background
            self.zoomBackgroundView = UIView(frame: keyWindow.frame)
          
            zoomBackgroundView?.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
            zoomBackgroundView?.alpha = 0
            keyWindow.addSubview(zoomBackgroundView!)
            //add expanded event view body
            keyWindow.addSubview(zoomingView)

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
                zoomingView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width * 0.75, height: keyWindow.frame.height * 0.57)
                self.zoomBackgroundView?.alpha = 0.5
                zoomingView.titleLeadingAnchor.constant = 22
                zoomingView.dismissView.alpha = 1
                zoomingView.removeButton.alpha = 1
                zoomingView.editButton.alpha = 1
                zoomingView.clockImageView.alpha = 1
                zoomingView.thinUnderline.alpha = 1
                zoomingView.eventLink.alpha = 1
                zoomingView.linkUnderline.alpha = 1
                zoomingView.layoutIfNeeded()
                //wherever view is, make view pleced in the center of window
                zoomingView.center = keyWindow.center
            } completion: { (completed: Bool) in
                //do something here later .....
            }
        }
        
        
        
    }
    // zoom out logic
    @objc func zoomOut(tapGesture: UITapGestureRecognizer){
        //extract view from tap gesture
        if let zoomOutView = tapGesture.view?.superview{
            //corner configuration
            zoomOutView.layer.cornerRadius = 11
            zoomOutView.clipsToBounds = true
            //zoom out animation
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
                //back to initial size
                zoomOutView.frame = self.startingFrame!
                //set back to transparent background
                self.zoomBackgroundView?.alpha = 0
                
                if let zoom = zoomOutView as? ZoomingView{
                    
                    zoom.titleTopAnchor.constant = 12
                    zoom.titleLeadingAnchor.constant = 8
                    zoom.titleTrailingAnchor.constant = -8
                    zoom.eventTimeLeadingAnchor.constant = 8
                    zoom.eventTimeTopAnchor.constant = 0
                    zoom.descriptionLabelTopAnchor.constant = 0
                    zoom.darkViewHeightAnchor.constant = 42
                    
                    if let startingView = self.startingEventView as? EventBubbleView {
                        
                        zoom.title.font = startingView.taskLabel.font
                        zoom.descriptionLabel.font = startingView.descriptionLabel.font
                        zoom.titleHeightAnchor.constant = startingView.taskLabelHeightConstant
                        zoom.eventTimeHeightAnchor.constant = startingView.timeLabelHeightConstant
                        zoom.descriptionLabelHeightAnchor.constant = startingView.descriptionLabelHeightConstant
                        
                        if startingView.descriptionLabel.isHidden == true{
                            zoom.descriptionLabel.alpha = 0
                        }
                        if startingView.timeLabel.isHidden == true{
                            zoom.eventTimeLabel.alpha = 0
                        }
                        
                        zoom.layoutIfNeeded()
                    }
                    
                    zoom.dismissView.alpha = 0
                    zoom.removeButton.alpha = 0
                    zoom.editButton.alpha = 0
                    zoom.clockImageView.alpha = 0
                    zoom.thinUnderline.alpha = 0
                    zoom.eventLink.alpha = 0
                    zoom.linkUnderline.alpha = 0
                }
                zoomOutView.layoutIfNeeded()
            } completion: { (completed: Bool) in
                //remove temporary created view from superview
                zoomOutView.removeFromSuperview()
                //show back original event (bubble) view
                self.startingEventView?.isHidden = false
            }
            
        }
    }
}
