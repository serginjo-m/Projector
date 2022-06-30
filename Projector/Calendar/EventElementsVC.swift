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

class EventElementsViewController: ElementsViewController, UITableViewDelegate, UITableViewDataSource{
    //MARK: Properties
    //TABLE VIEW CELL IDENTIFIER
    let cellIdentifier = "eventsTableViewCell"
    var timeInterval: TimeInterval?
    var currentDate: Date? {
        didSet{
            if let date =  self.currentDate {
                timeInterval = date.timeIntervalSince1970
            }
        }
    }
    
    
    
    //data for collection view
    var events: [Event] = []
    
    
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
    
    lazy var timelineStack: UIStackView = {
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
    
    //REMOVE ITEM
    @objc func removeItem(button: UIButton){
        UserActivitySingleton.shared.createUserActivity(description: "\(self.events[button.tag].title) event was removed")

        //remove event from database
        ProjectListRepository.instance.deleteEvent(event: self.events[button.tag])
        //remove from table view datasource
        events.remove(at: button.tag)
        //reload tableView
        self.eventsTableView.reloadData()
        
        
        
    }

    //MARK: Constraints
    func setupConstraints(){
        selectedDateLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 38).isActive = true
        selectedDateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        selectedDateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        selectedDateLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        //TODO: This constraints configuration is raw and needs more attention
        scrollViewContainer.topAnchor.constraint(equalTo: selectedDateLabel.bottomAnchor, constant: 25).isActive = true
        scrollViewContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        scrollViewContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        contentUIView.topAnchor.constraint(equalTo: scrollViewContainer.topAnchor).isActive = true
        contentUIView.leftAnchor.constraint(equalTo: scrollViewContainer.leftAnchor).isActive = true
        contentUIView.rightAnchor.constraint(equalTo: scrollViewContainer.rightAnchor).isActive = true
        contentUIView.bottomAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor).isActive = true
        contentUIView.widthAnchor.constraint(equalTo: scrollViewContainer.widthAnchor).isActive = true
        contentUIView.heightAnchor.constraint(equalToConstant: 1440).isActive = true
        
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
        
        let event = events[indexPath.row]
        
        // padding from table view margin or previous event
        cell.prevCellDate = indexPath.row == 0 ? currentDate : events[indexPath.row - 1].endTime
        
        cell.event = event
        
        cell.removeButton.tag = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(removeItem(button:)), for: .touchUpInside)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //table view height
        let tableViewHeight = tableView.frame.height//1440
        // 1 day interval in seconds
        let dailyTimeInterval: Double = 86400
        // cell height
        var height: CGFloat = 0
        // event
        let event = events[indexPath.row]
        // padding from table view margin or previous event
        let eventPadding = indexPath.row == 0 ? currentDate : events[indexPath.row - 1].endTime
        //event.date should always have updated time
        if let endTime = event.endTime{
            //date from which calculates padding
            if let eventPadding = eventPadding {
                //calculate padding from last cell based on timeInterval
                let endTimeInterval = endTime.timeIntervalSince(eventPadding)
                //calculate percentage of interval
                let intervalPercentage = endTimeInterval / dailyTimeInterval
                //convert % to Int
                let heightPercentage = tableViewHeight * intervalPercentage
                //cell height
                height = heightPercentage
            }
        }
        
        return height
    }
}

//MARK: Cell
class EventTableViewCell: UITableViewCell {
    
    //MARK: Properties
    //margin calculation should start from here
    var prevCellDate: Date?
    var event: Event? {
        didSet{
            
            guard let event = event, let previousCellDate = prevCellDate else {return}

            
            
            //Need to calculate time interval from prev event to start of current event
            if let eventDate =  event.date, let eventEndDate = event.endTime{
                
                //total time interval
                let totalCellTimeInterval = eventEndDate.timeIntervalSince(previousCellDate)
                //interval between events
                let timeIntervalBetweenEvents = eventDate.timeIntervalSince(previousCellDate)
                
                let heightMultiplier: CGFloat = timeIntervalBetweenEvents / totalCellTimeInterval
                
                if heightMultiplier > 0 {
                    backgroundBubbleHeightAnchor?.constant = self.frame.height * (1 - heightMultiplier)
                }else{
                    backgroundBubbleHeightAnchor?.constant = self.frame.height
                }
                
            }
            
            taskLabel.text = event.title
           
            if let image = event.picture{
                eventImageView.retreaveImageUsingURLString(myUrl: image)
                gradientView.isHidden = false
                shadowLabel.isHidden = false
                removeButton.isSelected = false
                descriptionLabel.text = "\n\n\n\n"//adds top spacing to description
                shadowLabel.text = descriptionLabel.text
            }else{
                eventImageView.image = nil
                gradientView.isHidden = true
                shadowLabel.isHidden = true
                removeButton.isSelected = true
                descriptionLabel.text = ""//remove top spacing if there is no image
            }
            
            //define description
            if let description = event.descr{
                descriptionLabel.text! += description
                shadowLabel.text = descriptionLabel.text
            }else{
                descriptionLabel.text = "no description ..."
                shadowLabel.text = descriptionLabel.text
            }

            //description label height
            let rect = NSString(string: descriptionLabel.text!).boundingRect(with: CGSize(width: frame.width , height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)], context: nil)

            //----------------------------------------------------------------------------------------
            //----------------------------- image needs proper sizing --------------------------------
            //----------------------------------------------------------------------------------------

            //configure image height constraint based on description label height
            imageHeightAnchor?.constant = rect.height + 100

            if event.category == "projectStep"{
                descriptionLabel.textColor = .white
                removeButton.backgroundColor = UIColor.init(white: 32/255, alpha: 1)
                eventImageView.isHidden = false
            }else{
                descriptionLabel.textColor = UIColor.init(white: 85/255, alpha: 1)
                removeButton.backgroundColor = UIColor.init(white: 230/255, alpha: 1)
                eventImageView.isHidden = true
            }
            
        }
    }
    
    let taskLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please show me something!"
        return label
    }()
    
    let removeButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setImage(UIImage(named: "big3Dots"), for: .normal)
        button.setImage(UIImage(named: "bigBlack3Dots"), for: .selected)
        button.contentMode = .center
        button.imageView!.contentMode = .scaleAspectFill
        button.backgroundColor = UIColor.init(white: 230/255, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "Description label contains explanation text."
        label.textColor = UIColor.init(white: 85/255, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let shadowLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "Description label contains explanation text."
        label.textColor = UIColor.init(white: 0.2, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    

    let backgroundBubble: UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor.init(white: 241/255, alpha: 1)
        bg.layer.cornerRadius = 12
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.layer.masksToBounds = true
        return bg
    }()

    let eventImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.image = UIImage(named: "workspace")
        imageView.contentMode = .scaleAspectFill

        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let gradientView: GradientView = {
        let topColor = UIColor.init(white: 32/255, alpha: 0)
        let middleColor = UIColor.init(white: 32/255, alpha: 0.68)
        let bottomColor = UIColor.init(white: 32/255, alpha: 1)
        let gradient = GradientView(gradientStartColor: topColor, gradientMiddleColor: middleColor, gradientEndColor: bottomColor)
        gradient.isHidden = true
        gradient.translatesAutoresizingMaskIntoConstraints = false
        return gradient
    }()
    
    var imageHeightAnchor: NSLayoutConstraint?
    var backgroundBubbleHeightAnchor: NSLayoutConstraint?
    
    //MARK: Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(backgroundBubble)
        addSubview(taskLabel)
        addSubview(shadowLabel)
        addSubview(descriptionLabel)
        
        backgroundBubble.addSubview(eventImageView)
        backgroundBubble.addSubview(gradientView)
        backgroundBubble.addSubview(removeButton)
        
        backgroundBubble.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        backgroundBubble.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        backgroundBubble.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        backgroundBubbleHeightAnchor = backgroundBubble.heightAnchor.constraint(equalToConstant: self.frame.height)
        backgroundBubbleHeightAnchor?.isActive = true
        
        //MARK: Constraints
        let constraints = [
            
            taskLabel.topAnchor.constraint(equalTo: backgroundBubble.topAnchor, constant: 15),
            taskLabel.leadingAnchor.constraint(equalTo: backgroundBubble.leadingAnchor, constant: 0),
            taskLabel.heightAnchor.constraint(equalToConstant: 17),
            taskLabel.trailingAnchor.constraint(equalTo: backgroundBubble.trailingAnchor, constant: 0),
            
            descriptionLabel.topAnchor.constraint(equalTo: taskLabel.bottomAnchor, constant: 0),
            descriptionLabel.leadingAnchor.constraint(equalTo: backgroundBubble.leadingAnchor, constant: 0),
            descriptionLabel.bottomAnchor.constraint(equalTo: backgroundBubble.bottomAnchor, constant: 0),
            descriptionLabel.trailingAnchor.constraint(equalTo: backgroundBubble.trailingAnchor, constant: 0),
            
            shadowLabel.topAnchor.constraint(equalTo: taskLabel.bottomAnchor, constant: 0),
            shadowLabel.leadingAnchor.constraint(equalTo: backgroundBubble.leadingAnchor, constant: 0),
            shadowLabel.bottomAnchor.constraint(equalTo: backgroundBubble.bottomAnchor, constant: 0),
            shadowLabel.trailingAnchor.constraint(equalTo: backgroundBubble.trailingAnchor, constant: 0),
            
            gradientView.topAnchor.constraint(equalTo: backgroundBubble.topAnchor, constant: 0),
            gradientView.bottomAnchor.constraint(equalTo: backgroundBubble.bottomAnchor, constant: 0),
            gradientView.leftAnchor.constraint(equalTo: backgroundBubble.leftAnchor, constant: 0),
            gradientView.rightAnchor.constraint(equalTo: backgroundBubble.rightAnchor, constant: 0),
            
            removeButton.topAnchor.constraint(equalTo: backgroundBubble.topAnchor, constant: 0),
            removeButton.rightAnchor.constraint(equalTo: backgroundBubble.rightAnchor, constant: 0),
            removeButton.widthAnchor.constraint(equalToConstant: 30),
            removeButton.bottomAnchor.constraint(equalTo: backgroundBubble.bottomAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)

        
        eventImageView.topAnchor.constraint(equalTo: backgroundBubble.topAnchor, constant: 0).isActive = true
        eventImageView.leadingAnchor.constraint(equalTo: backgroundBubble.leadingAnchor, constant: 0).isActive = true
        eventImageView.trailingAnchor.constraint(equalTo: backgroundBubble.trailingAnchor, constant: 0).isActive = true

        imageHeightAnchor = eventImageView.heightAnchor.constraint(equalToConstant: 100)
        imageHeightAnchor?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
