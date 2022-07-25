//
//  EventElementsVC.swift
//  Projector
//
//  Created by Serginjo Melnik on 06.01.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
//because I need to reuse it inside SidePanelView
class ElementsViewController: UIView {
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTableView(){
        
    }
}

class TimeLineCell: UIView {
    
    var hourString: String
    
    //MARK: Initialization
    init(hourString: String, frame: CGRect) {
        self.hourString = hourString
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.text = self.hourString
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupView(){
        addSubview(numberLabel)
        numberLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        numberLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        numberLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        numberLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
    }
}

class EventElementsView: ElementsViewController, UITableViewDelegate, UITableViewDataSource{
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

//different event sizes need different display style
enum EventBubbleStyle {
    case halfWidth
    case fullSize
    case thin
    case short
    case small
}

//MARK:  Bubble
//Event view is so complicated, that it needs it own class
class EventBubbleView: UIView {
    //event object
    var event: Event
    //gives a style to based on size calculations
    var style: EventBubbleStyle
    //view constraints configurations immidiately require view sizes
    var rect: CGSize
    
    let backgroundBubble: UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor.init(white: 241/255, alpha: 1)
        bg.layer.cornerRadius = 11
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.layer.masksToBounds = true
        return bg
    }()
    
    lazy var taskLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = event.category == "projectStep" ? .white : .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = event.title
        label.numberOfLines = 0
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.isHidden = event.category == "projectStep" ? true : false
        label.numberOfLines = 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let startTimeString = dateFormatter.string(from: event.date ?? Date())
        let endTimeString = dateFormatter.string(from: event.endTime ?? Date())
        label.text = "\(startTimeString) - \(endTimeString)"
        return label
    }()
   
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = event.descr
        label.isHidden = event.category == "projectStep" ? true : false
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        if let pictureURL =  event.picture  {
            imageView.retreaveImageUsingURLString(myUrl: pictureURL)
        }else{
            imageView.image = UIImage(named: "smile")//<---- probably need to have a default image
        }
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = event.category == "projectStep" ? false : true
        return imageView
    }()
    lazy var gradientView: GradientView = {
        let topColor = UIColor.init(white: 32/255, alpha: 1)
        let middleColor = UIColor.init(white: 32/255, alpha: 1)
        let bottomColor = UIColor.init(white: 32/255, alpha: 1)
        let gradient = GradientView(gradientStartColor: topColor, gradientMiddleColor: middleColor, gradientEndColor: bottomColor)
        gradient.isHidden = event.category == "projectStep" ? false : true
        gradient.translatesAutoresizingMaskIntoConstraints = false
        return gradient
    }()
    
    lazy var shadowLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = event.title
        label.numberOfLines = 0
//        label.backgroundColor = .systemGreen
        label.isHidden = event.category == "projectStep" ? false : true
        return label
    }()
    
    //save configurations for expanded event view
    var taskLabelHeightConstant: CGFloat = 1
    var taskLabelTopAnchorConstant: CGFloat = 12
    var timeLabelHeightConstant: CGFloat = 30
    var descriptionLabelHeightConstant: CGFloat = 0    
    
    //MARK: Initialization
    init(style: EventBubbleStyle, event: Event, viewHeight: CGFloat, viewWidth: CGFloat, frame: CGRect) {
        self.event = event
        self.style = style
        self.rect = CGSize(width: viewWidth, height: viewHeight)
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func calculateRectForLabel(size: CGFloat, text: String) -> CGRect{
        //description label height
        let rectangle = NSString(string: text).boundingRect(with: CGSize(width: rect.width - CGFloat(22), height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: size)], context: nil)

        //rounded away from zero original values
        let rect = CGRect(x: rectangle.origin.x, y: rectangle.origin.y, width: rectangle.width.rounded(.awayFromZero), height: rectangle.height.rounded(.awayFromZero))
        
        return rect
    }
    
    func setupView(){
        
        self.clipsToBounds = true
        
        switch style {
            
        //it so small, that can't realy visualize anything, apart from bubble view
        case .small:
            
            taskLabel.isHidden = true
            descriptionLabel.isHidden = true
            shadowLabel.isHidden = true
            timeLabel.isHidden = true
            //because if it visible it has 12px padding from top by default
            taskLabelTopAnchorConstant = 0
        //can show only title and bubble view
        case .short://events.count > 2 == .thin, viewHeight <= 60 == .short
            taskLabel.font = UIFont.boldSystemFont(ofSize: 14)
            shadowLabel.font = UIFont.boldSystemFont(ofSize: 14)

            let titleHeight = calculateRectForLabel(size: 14, text: taskLabel.text!).height
            taskLabelHeightConstant = titleHeight <= rect.height - 12 ? titleHeight : rect.height - 24
            descriptionLabel.isHidden = true
            timeLabel.isHidden = true
        //can include anything. The only one thing, fonts must be into small size
        case .thin://events.count > 2 == .thin, viewHeight <= 60 == .short
            
            taskLabel.font = UIFont.boldSystemFont(ofSize: 14)
            shadowLabel.font = UIFont.boldSystemFont(ofSize: 14)
            descriptionLabel.font = UIFont.systemFont(ofSize: 14)
            
            taskLabelHeightConstant = calculateRectForLabel(size: 14, text: taskLabel.text!).height + CGFloat(10)
            timeLabelHeightConstant = calculateRectForLabel(size: 14, text: timeLabel.text!).height + CGFloat(10)
            descriptionLabelHeightConstant = calculateRectForLabel(size: 14, text: descriptionLabel.text!).height
        //default style. Here I can show everything
        case .fullSize://by default it is .fullSize
            
            taskLabel.font = UIFont.boldSystemFont(ofSize: 16)
            shadowLabel.font = UIFont.boldSystemFont(ofSize: 16)
            descriptionLabel.font = UIFont.systemFont(ofSize: 16)
            taskLabelHeightConstant = calculateRectForLabel(size: 16, text: taskLabel.text!).height
            descriptionLabelHeightConstant = calculateRectForLabel(size: 16, text: descriptionLabel.text!).height
        //this style can visualize anything. But I should be accurate with view height
        case .halfWidth://by default it is .fullSize
            
            taskLabel.font = UIFont.boldSystemFont(ofSize: 16)
            shadowLabel.font = UIFont.boldSystemFont(ofSize: 16)
            descriptionLabel.font = UIFont.systemFont(ofSize: 16)
            taskLabelHeightConstant = calculateRectForLabel(size: 16, text: taskLabel.text!).height + CGFloat(10)
            let descriptionTextHeight: CGFloat = calculateRectForLabel(size: 16, text: descriptionLabel.text!).height
            let titleLabelTopAnchorSpace: CGFloat = -15
            let availableHeight: CGFloat = rect.height - taskLabelHeightConstant - timeLabelHeightConstant - titleLabelTopAnchorSpace
            descriptionLabelHeightConstant = descriptionTextHeight > availableHeight ? availableHeight : descriptionTextHeight
        }
                        
        addSubview(backgroundBubble)
        addSubview(shadowLabel)
        addSubview(taskLabel)
        addSubview(timeLabel)
        addSubview(descriptionLabel)

        backgroundBubble.addSubview(eventImageView)
        backgroundBubble.addSubview(gradientView)

        backgroundBubble.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        backgroundBubble.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        backgroundBubble.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6).isActive = true//-10
        backgroundBubble.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        taskLabel.topAnchor.constraint(equalTo: backgroundBubble.topAnchor, constant: taskLabelTopAnchorConstant).isActive = true
        taskLabel.leadingAnchor.constraint(equalTo: backgroundBubble.leadingAnchor, constant: 8).isActive = true
        taskLabel.heightAnchor.constraint(equalToConstant: taskLabelHeightConstant).isActive = true
        taskLabel.trailingAnchor.constraint(equalTo: backgroundBubble.trailingAnchor, constant: -8).isActive = true
        
        timeLabel.topAnchor.constraint(equalTo: taskLabel.bottomAnchor, constant: 0).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: backgroundBubble.leadingAnchor, constant: 8).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: backgroundBubble.trailingAnchor, constant: -8).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: timeLabelHeightConstant).isActive = true
        
        descriptionLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 0).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: taskLabel.leadingAnchor).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: descriptionLabelHeightConstant).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: taskLabel.trailingAnchor).isActive = true

        shadowLabel.topAnchor.constraint(equalTo: taskLabel.topAnchor, constant: 1).isActive = true
        shadowLabel.leadingAnchor.constraint(equalTo: taskLabel.leadingAnchor, constant: 1).isActive = true
        shadowLabel.heightAnchor.constraint(equalToConstant: taskLabelHeightConstant).isActive = true
        shadowLabel.trailingAnchor.constraint(equalTo: taskLabel.trailingAnchor, constant: 1).isActive = true
        
        gradientView.topAnchor.constraint(equalTo: taskLabel.topAnchor, constant: -30).isActive = true
        gradientView.leftAnchor.constraint(equalTo: backgroundBubble.leftAnchor, constant: 0).isActive = true
        gradientView.rightAnchor.constraint(equalTo: backgroundBubble.rightAnchor, constant: 0).isActive = true
        gradientView.heightAnchor.constraint(equalTo: taskLabel.heightAnchor, constant: 42).isActive = true
        
        
        eventImageView.topAnchor.constraint(equalTo: backgroundBubble.topAnchor, constant: 0).isActive = true
        eventImageView.leadingAnchor.constraint(equalTo: backgroundBubble.leadingAnchor, constant: 0).isActive = true
        eventImageView.trailingAnchor.constraint(equalTo: backgroundBubble.trailingAnchor, constant: 0).isActive = true
        eventImageView.bottomAnchor.constraint(equalTo: backgroundBubble.bottomAnchor).isActive = true
    }
}

//MARK: Event TableView Cell
class EventTableViewCell: UITableViewCell {
    
    //margin calculation should start from here
    var prevCellDate: Date?
    //CalendarViewConroller -> EventElementsView -> EventTableViewCell -> performZoomForStartingEventView()
    var calendarVC: CalendarViewController?
    
    var events: [Event] = [] {
        didSet{
            //clear cell for case deque cell reuse something
            subviews.forEach { $0.removeFromSuperview() }
            //creates views based on events number            
            for number in 1...events.count{
                //configure event view and give it a sequent number
                configureBubbleViews(number: number)
            }
        }
    }
    
   
    
    //MARK: Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func configureBubbleViews(number: Int){
        
        var bubbleStyle: EventBubbleStyle = EventBubbleStyle.fullSize
        //------------- new approach here: first declare var and then unwrap it for value. Something?
        
        //current event interval, that should be unwraped, because it optional, but it calculates inside Event
        var currentEventInterval = TimeInterval()
        //total TimeInterval for each cell is the same. So every event must calculate padding and size from it...
        var totalCellTimeInterval = TimeInterval()
        //TimeInterval from prev cell to current event
        var topEndTimeInterval = TimeInterval()
        //unwrap optionals
        if let lastEvent = events.last,
            let lastEndTime = lastEvent.endTime,
            let prevDate = prevCellDate,
            let intervalForCurrentEvent = events[number - 1].eventTimeInterval,
            let currentEventStartDate = events[number - 1].date
        {
            //TimeInterval for entire cell
            totalCellTimeInterval = lastEndTime.timeIntervalSince(prevDate)
            //unwrap optional Event TimeInterval for future calculations
            currentEventInterval = intervalForCurrentEvent
            //TimeInterval from last cell (Event) to current event
            topEndTimeInterval = currentEventStartDate.timeIntervalSince(prevDate)
        }
        
        //calculate eventBubbleView height percentage of entire cell height
        let heightPercentage = currentEventInterval / totalCellTimeInterval
        //calculate height value based on percentage
        let viewHeight: CGFloat = frame.height * heightPercentage
        //calculate distance percentage from last event to current event inside cell
        let topEndPaddingPercentage = topEndTimeInterval / totalCellTimeInterval
        //value  calculation based on percentage of entire cell height
        let viewTopPadding = frame.height * topEndPaddingPercentage
        //left padding calculation
        let constant = (frame.width / CGFloat(events.count)) * CGFloat(number - 1)
        //view width
        let viewWidth = frame.width / CGFloat(events.count)
        
        // .small
        if viewHeight <= 30{
            bubbleStyle = .small
        }
        // .short
        if  viewHeight <= 180 && viewHeight >= 30 {
            bubbleStyle = .short
        }
        // .thin
        if events.count > 2 && viewHeight >= 180{
            bubbleStyle = .thin
        }
        // .halfWidth
        if events.count == 2 && viewHeight >= 180{
            bubbleStyle = .halfWidth
        }
                
        //creates event view
        let eventBubbleView = EventBubbleView(style: bubbleStyle ,event: events[number - 1], viewHeight: viewHeight, viewWidth: viewWidth, frame: CGRect.zero)
        
        //add zoom in function to bubble view
        eventBubbleView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoomIn))
        eventBubbleView.addGestureRecognizer(tap)
        eventBubbleView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(eventBubbleView)
        
        eventBubbleView.widthAnchor.constraint(equalToConstant: viewWidth).isActive = true
        eventBubbleView.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
        eventBubbleView.topAnchor.constraint(equalTo: topAnchor, constant: viewTopPadding).isActive = true
        eventBubbleView.leftAnchor.constraint(equalTo: leftAnchor, constant:  constant).isActive = true
    }
    
    @objc func zoomIn(tapGesture: UITapGestureRecognizer){
        //Really good trick
        //Extract view object from tap gesture
        let bubbleView = tapGesture.view as? EventBubbleView
        guard let bubble = bubbleView, let calendarViewController = calendarVC else {return}
        calendarViewController.performZoomForStartingEventView(event: bubble.event ,startingEventView: bubble)
    }
}


//MARK: Gradient
//gradient inside view so it can use constraints
class GradientView: UIView {
    
    private let gradient : CAGradientLayer = CAGradientLayer()
    private let gradientStartColor: UIColor
    private let gradientMiddleColor: UIColor
    private let gradientEndColor: UIColor
    
    init(gradientStartColor: UIColor, gradientMiddleColor: UIColor, gradientEndColor: UIColor) {
        self.gradientStartColor = gradientStartColor
        self.gradientMiddleColor = gradientMiddleColor
        self.gradientEndColor = gradientEndColor
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradient.frame = self.bounds
        gradient.locations = [0.0, 0.3, 0.6]
    }
    
    override public func draw(_ rect: CGRect) {
        gradient.frame = self.bounds
        gradient.colors = [gradientEndColor.cgColor, gradientMiddleColor.cgColor, gradientStartColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 0, y: 0)
        if gradient.superlayer == nil {
            layer.insertSublayer(gradient, at: 0)
        }
    }
}
