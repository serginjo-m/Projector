//
//  EventElementsVC.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import Foundation
import RealmSwift

class EventElementsView: ElementsView, UITableViewDelegate, UITableViewDataSource{
    //MARK: Properties
    //TABLE VIEW CELL IDENTIFIER
    let cellIdentifier = "eventsTableViewCell"
    //CalendarViewConroller -> EventElementsView -> EventTableViewCell -> performZoomForStartingEventView()
    var calendarViewController: CalendarViewController?
    //need for tableViewCell height calculations
    var timeInterval: TimeInterval?
    //if opened day is current day, perform some configurations
    let calendar = Calendar(identifier: .gregorian)
    var currentDate: Date? {
        didSet{
            if let date =  self.currentDate {
                //required for tableView timeInterval calculations
                timeInterval = date.timeIntervalSince1970
                //check if day is a current day
                if date == calendar.startOfDay(for: Date()){
                    let timeIntervalFromSunrise = abs(date.timeIntervalSinceNow)
                    let totalDayTimeInterval: Double = 86400
                    let percentageOfPassedDay = timeIntervalFromSunrise / totalDayTimeInterval
                    let topAnchorConstant: CGFloat = eventsTableView.frame.height * percentageOfPassedDay
                    
                    //TODO: Need to adjust timeLine, currentLine, and events properly (+5)
                    currentTimeLineViewTopAnchor?.constant = topAnchorConstant
                    //if user open current date side panel, table view scrolls to current time point
                    scrollViewContainer.setContentOffset(CGPoint(x: 0, y: topAnchorConstant - 200), animated: false)
                }else{
                    currentTimeLineViewTopAnchor?.constant = -20
                    // if day is not current day side panel scrolls to begin
                    scrollViewContainer.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                }
                //set timeLine indicator to current time
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                currentTimeLabel.text = dateFormatter.string(from: Date())
            }
        }
    }
    
    //data for collection view
    var events: [[Event]] = []
    
    let selectedDateLabel: UILabel = {
        let label = UILabel()
        label.text = "This is Date"
        label.backgroundColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
   
    //container for all items on the page
    var scrollViewContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    //container inside scroll view, that holds all views
    var contentUIView: UIView = {
        let view  = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let currentTimeLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(red: 243/255, green: 103/255, blue: 115/255, alpha: 1)
        return view
    }()
    let currentTimeBG: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 243/255, green: 103/255, blue: 115/255, alpha: 1)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        
        label.textAlignment = .center
        label.text = "20:43"
        label.textColor = .white
        return label
    }()
    
    //TABLE VIEW
    lazy var eventsTableView: UITableView = {//<------------ TABLE VIEW is HERE!
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.register(EventTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        return tableView
    }()
    
    var timelineStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        stack.axis = .vertical
        return stack
    }()
    
    
    
    //MARK: Methods
    //parent already has this function and call to it, so the only thing I need is to override it!
    override func setupTableView(){
        backgroundColor = .white
        
        for number in 1...24{
            configureTimeline(number: number)
        }
        
        
        addSubview(selectedDateLabel)
        addSubview(scrollViewContainer)
        
        scrollViewContainer.addSubview(contentUIView)
        contentUIView.addSubview(timelineStack)
        contentUIView.addSubview(eventsTableView)
        contentUIView.addSubview(currentTimeLineView)
        contentUIView.addSubview(currentTimeBG)
        contentUIView.addSubview(currentTimeLabel)
        //configure views constraints
        setupConstraints()
    }
    
    fileprivate func configureTimeline(number: Int){
        
        var text = ""
        
        if number <= 10{
            text = "0\(number - 1):00"
        }else{
            text = "\(number - 1):00"
        }
        
        let timeLineCell = TimeLineCell(hourString: text, frame: CGRect.zero)
        timelineStack.addArrangedSubview(timeLineCell)
    }
    
    //move to visible area or hide it. It depends from selected day. If it is current day......
    var currentTimeLineViewTopAnchor: NSLayoutConstraint?
    //MARK: Constraints
    func setupConstraints(){
        selectedDateLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 38).isActive = true
        selectedDateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        selectedDateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        selectedDateLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        scrollViewContainer.topAnchor.constraint(equalTo: selectedDateLabel.bottomAnchor, constant: 25).isActive = true
        scrollViewContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        scrollViewContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true

        //Here is so many constraints, because it won't scrolls without it
        contentUIView.topAnchor.constraint(equalTo: scrollViewContainer.topAnchor).isActive = true
        contentUIView.leadingAnchor.constraint(equalTo: scrollViewContainer.leadingAnchor).isActive = true
        contentUIView.widthAnchor.constraint(equalTo: scrollViewContainer.widthAnchor).isActive = true
        contentUIView.bottomAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor).isActive = true
        contentUIView.trailingAnchor.constraint(equalTo: scrollViewContainer.trailingAnchor).isActive = true
        //It is exactly 1440 because I want that 1 hour is 60px height (24 * 60)
        contentUIView.heightAnchor.constraint(equalToConstant: 1440).isActive = true
        
        currentTimeLineView.leadingAnchor.constraint(equalTo: contentUIView.leadingAnchor).isActive = true
        currentTimeLineView.trailingAnchor.constraint(equalTo: contentUIView.trailingAnchor).isActive = true
        currentTimeLineView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        currentTimeLineViewTopAnchor = currentTimeLineView.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: -20)
        currentTimeLineViewTopAnchor?.isActive = true
        
        currentTimeBG.centerYAnchor.constraint(equalTo: currentTimeLineView.centerYAnchor).isActive = true
        currentTimeBG.leadingAnchor.constraint(equalTo: currentTimeLineView.leadingAnchor, constant: 10).isActive = true
        currentTimeBG.heightAnchor.constraint(equalToConstant: 22).isActive = true
        currentTimeBG.widthAnchor.constraint(equalToConstant: 56).isActive = true
        
        currentTimeLabel.topAnchor.constraint(equalTo: currentTimeBG.topAnchor).isActive = true
        currentTimeLabel.leadingAnchor.constraint(equalTo: currentTimeBG.leadingAnchor).isActive = true
        currentTimeLabel.trailingAnchor.constraint(equalTo: currentTimeBG.trailingAnchor).isActive = true
        currentTimeLabel.bottomAnchor.constraint(equalTo: currentTimeBG.bottomAnchor).isActive = true

        timelineStack.topAnchor.constraint(equalTo: contentUIView.topAnchor).isActive = true
        timelineStack.bottomAnchor.constraint(equalTo: contentUIView.bottomAnchor).isActive = true
        timelineStack.leftAnchor.constraint(equalTo: contentUIView.leftAnchor).isActive = true
        timelineStack.widthAnchor.constraint(equalTo: contentUIView.widthAnchor, multiplier: 0.23).isActive = true
        
        eventsTableView.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant:  0).isActive = true
        eventsTableView.leadingAnchor.constraint(equalTo: timelineStack.trailingAnchor, constant:  0).isActive = true
        eventsTableView.widthAnchor.constraint(equalTo: contentUIView.widthAnchor, multiplier: 0.77).isActive = true
        eventsTableView.bottomAnchor.constraint(equalTo: contentUIView.bottomAnchor, constant: 0).isActive = true

    }
    
    //MARK: Table view section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = events.count
        return count
    }
    
    //cell configuration
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as? EventTableViewCell else {
            fatalError( "The dequeued cell is not an instance of EventTableViewCell." )
        }
        
        let eventsArr = events[indexPath.row]
        
        //for first item padding point is a table view bound
        if indexPath.row == 0 {
           //calculation from current date always give 0
            cell.prevCellDate = currentDate
            
        }else{
            //sort prev cell events by date
            let prevEvents = events[indexPath.row - 1]
            //take last item, because it's laterest one, so it will be a start point for current cell
            if let lastItem = prevEvents.last, let endTime = lastItem.endTime{
                cell.prevCellDate = endTime
            }else{
                //just in case something went wrong
                cell.prevCellDate = currentDate
            }
        }
        //CalendarViewConroller -> EventElementsView -> EventTableViewCell -> performZoomForStartingEventView()
        cell.calendarVC = calendarViewController
        cell.events = eventsArr
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let currentDate = currentDate else {return 0}
        //current events array
        let currentEvents = events[indexPath.row]
        //table view height
        let tableViewHeight = tableView.frame.height//1440
        // 1 day interval in seconds
        let dailyTimeInterval: Double = 86400
        // cell height to return
        var height: CGFloat = 0
        
        
        // padding from table view margin or previous event
        var eventPadding = Date()
        
        //for first item padding point is a table view bound
        if indexPath.row == 0 {
           //calculation from current date always give 0
            eventPadding = currentDate
            
        }else{
            //sort prev cell events by date
            let previousEvent = events[indexPath.row - 1]
            //take last item, because it's latest one, so it will be a start point for current cell
            if let lastItem = previousEvent.last, let endTime = lastItem.endTime{
                eventPadding = endTime
            }else{
                //just in case something went wrong
                eventPadding = currentDate
            }
        }
        
        if let lastItem = currentEvents.last, let endTime = lastItem.endTime{
            //calculate padding from last cell based on timeInterval
            let endTimeInterval = endTime.timeIntervalSince(eventPadding)
            //calculate percentage of interval
            let intervalPercentage = endTimeInterval / dailyTimeInterval
            //convert % to Int
            let heightPercentage = tableViewHeight * intervalPercentage
            //cell height
            height = heightPercentage
        }
        
        return height
    }
}
