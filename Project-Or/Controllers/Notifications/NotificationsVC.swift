//
//  NotificationsVC.swift
//  Projector
//
//  Created by Serginjo Melnik on 05.08.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

//MARK: OK
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

    let cellIdentifier = "cellIdentifier"
    
    lazy var notificationTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.init(white: 247/255, alpha: 1)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        return tableView
    }()
        
    let headerContainerView: UIView = {
        let view = NotificationsHeaderImage()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: VCLifecycle
    override func viewDidLoad() {
        view.backgroundColor = UIColor.init(white: 247/255, alpha: 1)
        view.addSubview(headerContainerView)
        view.addSubview(notificationTableView)
        setupConstraints()
    }
    
    //view controller update
    override func viewWillAppear(_ animated: Bool) {
         //once NotificationsVC opened reset all badges
        UserDefaults(suiteName: "notificationsDefaultsBadgeCount")?.set(1, forKey: "count")
        NotificationsRepository.shared.updateTabBarItemBudge(applyBadge: false)
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
        
        ProjectListRepository.instance.updateNotificationCompletionStatus(notification: notification, isComplete: true)
        //depending on notification type, define navigation VC stack
        if notification.category == "step" {
            NotificationsRepository.shared.configureVCStack(category: "step", eventDate: Date(), stepId: notification.stepId, projectId: notification.projectId)
        } else if notification.category == "event" {
            NotificationsRepository.shared.configureVCStack(category: "event", eventDate: notification.eventDate)
        }
    }
    
    //MARK: Constraints
    fileprivate func setupConstraints(){
        
        headerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        headerContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        headerContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        headerContainerView.heightAnchor.constraint(equalToConstant: 192).isActive = true
        
        notificationTableView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: 10).isActive = true
        notificationTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        notificationTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        notificationTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
}
