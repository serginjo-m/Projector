//
//  NotificationsVC.swift
//  Projector
//
//  Created by Serginjo Melnik on 05.08.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift


class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    var notifications: Results<Notification> {
        get{
           return ProjectListRepository.instance.getNotificationNotes()
        }
        set{
            //update....
        }
    }
    
    var items: [Notification] = []
    
    //cell identifier
    let cellIdentifier = "cellIdentifier"
    //TABLE VIEW
    lazy var notificationTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.init(white: 247/255, alpha: 1)
        return tableView
    }()
    
    //scroll view container
    //container for all items on the page
    var scrollViewContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    var contentUIView: UIView = {
        let view  = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let headerContainerView: UIView = {
        let view = NotificationsHeaderImage()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    //MARK: VCLifecycle
    override func viewDidLoad() {
        
        view.backgroundColor = UIColor.init(white: 247/255, alpha: 1)
        
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        contentUIView.addSubview(headerContainerView)
        contentUIView.addSubview(notificationTableView)
       
        setupConstraints()
    }
    
    //view controller update point :)
    override func viewWillAppear(_ animated: Bool) {

        //once NotificationsVC opened reset all badges
        UserDefaults(suiteName: "notificationsDefaultsBadgeCount")?.set(1, forKey: "count")
        NotificationsRepository.shared.updateTabBarItemBudge()
        //update VC database
        updateNotifications()
    }
    
    //MARK: Methods
    fileprivate func updateNotifications (){
        
        //fetch notifications
        notifications = ProjectListRepository.instance.getNotificationNotes()
        
        //clear old notifications
        items.removeAll()
        
        //filter results, by date descending
        items = notifications.sorted(by: { (a, b) in return a.eventDate > b.eventDate })
        
        notificationTableView.reloadData()
        
    }
   

    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  items.count > 0{
            return items.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as? NotificationTableViewCell else {
            fatalError( "The dequeued cell is not an instance of NotificationTableViewCell." )
        }
       
        cell.selectionStyle = .none
        
        cell.template = items[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = items[indexPath.row]
        //depending on notification type define navigation VC stack
        if notification.category == "step" {
            NotificationsRepository.shared.configureVCStack(category: "step", eventDate: Date(), stepId: notification.stepId, projectId: notification.projectId)
        } else if notification.category == "event" {
            NotificationsRepository.shared.configureVCStack(category: "event", eventDate: notification.eventDate)
        }
    }
    
    //MARK: Constraints
    fileprivate func setupConstraints(){
        
        scrollViewContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        scrollViewContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        scrollViewContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        contentUIView.topAnchor.constraint(equalTo: scrollViewContainer.topAnchor).isActive = true
        contentUIView.leftAnchor.constraint(equalTo: scrollViewContainer.leftAnchor).isActive = true
        contentUIView.rightAnchor.constraint(equalTo: scrollViewContainer.rightAnchor).isActive = true
        contentUIView.bottomAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor).isActive = true
        contentUIView.widthAnchor.constraint(equalTo: scrollViewContainer.widthAnchor).isActive = true
        contentUIView.heightAnchor.constraint(equalToConstant: 1500).isActive = true
        
        headerContainerView.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 20).isActive = true
        headerContainerView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        headerContainerView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        headerContainerView.heightAnchor.constraint(equalToConstant: 192).isActive = true
        
        notificationTableView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: 10).isActive = true
        notificationTableView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        notificationTableView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        notificationTableView.bottomAnchor.constraint(equalTo: contentUIView.bottomAnchor, constant: 0).isActive = true
        
    }
    
}

class NotificationTableViewCell: UITableViewCell {
    
    
    //MARK: Properties
    var template: Notification? {
        didSet{
            if let object = template {
                notificationTitle.text = object.name
                
                
                    var string = "Happen: "
                    string += self.dateFormatterFullDate.string(from: object.eventDate)
                    createdNotificationDateLabel.text = string
                
                
                categoryIcon.image = setImageToCategory(category: object.category)
                
                let percentageValue = CGFloat(abs(object.startDate.timeIntervalSinceNow) / abs(object.startDate.timeIntervalSince(object.eventDate)))
                
                
                    let notificationCalendar = NSCalendar.current

                    let competitionDifference = notificationCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date(), to: object.eventDate)
                    
                    timeRemainingLabel.text = convertComponentsToString(dateComponents: competitionDifference)
                
                
                //constraints update approach
                categoryIconWidthAnchor?.isActive = false
                categoryIconHeightAnchor?.isActive = false
                progressBarWidthAnchor?.isActive = false
                
                //icon size
                switch object.category{
                    case "event":
                        categoryIconWidthAnchor = categoryIcon.widthAnchor.constraint(equalToConstant: 21)
                        categoryIconHeightAnchor = categoryIcon.heightAnchor.constraint(equalToConstant: 21)
                    case "step":
                        categoryIconWidthAnchor = categoryIcon.widthAnchor.constraint(equalToConstant: 22)
                        categoryIconHeightAnchor = categoryIcon.heightAnchor.constraint(equalToConstant: 32)
                    default:
                        categoryIconWidthAnchor = categoryIcon.widthAnchor.constraint(equalToConstant: 21)
                        categoryIconHeightAnchor = categoryIcon.heightAnchor.constraint(equalToConstant: 21)
                }
                
                //progress
                progressBarWidthAnchor = progressBar.widthAnchor.constraint(equalTo: progressBarTrack.widthAnchor, multiplier: percentageValue)
                
                progressBarWidthAnchor?.isActive = true
                categoryIconWidthAnchor?.isActive = true
                categoryIconHeightAnchor?.isActive = true
                
            }
        }
    }
    
    var progressBarWidthAnchor: NSLayoutConstraint?
    var categoryIconWidthAnchor: NSLayoutConstraint?
    var categoryIconHeightAnchor: NSLayoutConstraint?
    
    private lazy var dateFormatterFullDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd / MMM / yyyy HH:mm"
        return dateFormatter
    }()
    
    let categoryIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "projectIcon"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let backgroundBubble: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()
    
    let notificationTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Project Title"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.init(white: 104/255, alpha: 1)
        label.numberOfLines = 0
        return label
    }()
    
    let createdNotificationDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.init(white: 120/255, alpha: 1)
        label.text = "08 / 08 / 2021 18:31"
        return label
    }()
    
    let progressBarTrack: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 3
        view.backgroundColor = UIColor.init(white: 236/255, alpha: 1)
        return view
    }()
    
    let progressBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 3
        view.backgroundColor = UIColor.init(red: 52/255, green: 210/255, blue: 0, alpha: 1)
        return view
    }()
    
    let timeRemainingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "1 day left"
        label.textColor = UIColor.init(white: 120/255, alpha: 1)
        return label
    }()
    
    //MARK: Methods
    //return image by category string
    func setImageToCategory(category: String) -> UIImage {
        
        switch category {
            case "event":
                return UIImage(named: "calendarIcon")!
            case "step":
                return UIImage(named: "projectIcon")!
            default:
                return UIImage(named: "calendarIcon")!
        }
        
    }
    
    //time to event string
    func convertComponentsToString(dateComponents: DateComponents) -> String {
        var string = ""
        
        if let years = dateComponents.year {
            if years > 0 {
                string += "\(years)y "
            }
        }
        if let months = dateComponents.month{
            if months > 0{
                string += "\(months)mth "
            }
        }
        if let days = dateComponents.day{
            if days > 0{
                string += "\(days)d "
            }
        }
        if let hours = dateComponents.hour{
            if hours > 0 {
                string += "\(hours)h "
            }
        }
        if let minutes = dateComponents.minute{
            if minutes > 0{
                string += "\(minutes)min "
            }
        }
        string += "left"
        
        return string
    }
    
    //MARK: Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.init(white: 247/255, alpha: 1)
        addSubview(categoryIcon)
        addSubview(backgroundBubble)
        addSubview(notificationTitle)
        addSubview(createdNotificationDateLabel)
        addSubview(progressBarTrack)
        addSubview(progressBar)
        addSubview(timeRemainingLabel)
        
        let constraints = [
            
        notificationTitle.topAnchor.constraint(equalTo: topAnchor, constant: 30),
        notificationTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 66),
        notificationTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22),
        notificationTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -104),
        
        backgroundBubble.topAnchor.constraint(equalTo: notificationTitle.topAnchor, constant: -22),
        backgroundBubble.leadingAnchor.constraint(equalTo: notificationTitle.leadingAnchor, constant: -22),
        backgroundBubble.trailingAnchor.constraint(equalTo: notificationTitle.trailingAnchor, constant: 22),
        backgroundBubble.bottomAnchor.constraint(equalTo: notificationTitle.bottomAnchor, constant: 96),
        
        categoryIcon.centerYAnchor.constraint(equalTo: backgroundBubble.centerYAnchor, constant: 0),
        categoryIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
        
        
        createdNotificationDateLabel.topAnchor.constraint(equalTo: notificationTitle.bottomAnchor, constant: 9),
        createdNotificationDateLabel.heightAnchor.constraint(equalToConstant: 17),
        createdNotificationDateLabel.leftAnchor.constraint(equalTo: notificationTitle.leftAnchor, constant: 0),
        createdNotificationDateLabel.rightAnchor.constraint(equalTo: backgroundBubble.rightAnchor, constant: -35),
        
        progressBarTrack.topAnchor.constraint(equalTo: createdNotificationDateLabel.bottomAnchor, constant: 15),
        progressBarTrack.rightAnchor.constraint(equalTo: backgroundBubble.rightAnchor, constant: -22),
        progressBarTrack.leftAnchor.constraint(equalTo: backgroundBubble.leftAnchor, constant: 22),
        progressBarTrack.heightAnchor.constraint(equalToConstant: 6),
        
        progressBar.topAnchor.constraint(equalTo: progressBarTrack.topAnchor, constant: 0),
        progressBar.leftAnchor.constraint(equalTo: progressBarTrack.leftAnchor, constant: 0),
        progressBar.heightAnchor.constraint(equalToConstant: 6),
    
            
        timeRemainingLabel.topAnchor.constraint(equalTo: progressBarTrack.bottomAnchor, constant: 14),
        timeRemainingLabel.leftAnchor.constraint(equalTo: notificationTitle.leftAnchor, constant: 0),
        timeRemainingLabel.heightAnchor.constraint(equalToConstant: 13),
        timeRemainingLabel.rightAnchor.constraint(equalTo: progressBarTrack.rightAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        //update approach
        categoryIconWidthAnchor = categoryIcon.widthAnchor.constraint(equalToConstant: 22)
        categoryIconHeightAnchor = categoryIcon.heightAnchor.constraint(equalToConstant: 32)
        progressBarWidthAnchor = progressBar.widthAnchor.constraint(equalTo: progressBarTrack.widthAnchor, multiplier: 0.65)
        categoryIconWidthAnchor?.isActive = true
        categoryIconHeightAnchor?.isActive = true
        progressBarWidthAnchor?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
