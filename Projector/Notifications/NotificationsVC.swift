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
    
    
    //cell identifier
    let cellIdentifier = "cellIdentifier"
    //TABLE VIEW
    let notificationTableView = UITableView()
    
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
    
    
    
    override func viewDidLoad() {
        
        view.backgroundColor = UIColor.init(white: 247/255, alpha: 1)
        
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        contentUIView.addSubview(headerContainerView)
        contentUIView.addSubview(notificationTableView)
       
        //TABLE VIEW CONFIGURATION
        configureStepTableView()
        
        setupConstraints()
    }
    
    //TABLE VIEW CONFIGURATION
    private func configureStepTableView(){
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        notificationTableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        notificationTableView.separatorStyle = .none
        notificationTableView.translatesAutoresizingMaskIntoConstraints = false
        notificationTableView.backgroundColor = UIColor.init(white: 247/255, alpha: 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    let arr = ["Project title", "this should be very long string for test of flexibility of our cell based on"]
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as? NotificationTableViewCell else {
            fatalError( "The dequeued cell is not an instance of NotificationTableViewCell." )
        }
       
        cell.selectionStyle = .none
        
        
//        var string = "Lorem Ipsum"
//
//
//        if indexPath.row == 1 {
//            string += "\n\n\n\n"
//        }
//
//        cell.notificationTitle.text = string
        
        return cell
    }
    
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
        label.textColor = UIColor.init(white: 168/255, alpha: 1)
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
        label.font = UIFont.systemFont(ofSize: 11)
        label.text = "1 day left"
        label.textColor = UIColor.init(white: 168/255, alpha: 1)
        return label
    }()
    
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
        categoryIcon.widthAnchor.constraint(equalToConstant: 22),
        categoryIcon.heightAnchor.constraint(equalToConstant: 32),
        
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
        progressBar.widthAnchor.constraint(equalTo: progressBarTrack.widthAnchor, multiplier: 0.65),
            
        timeRemainingLabel.topAnchor.constraint(equalTo: progressBarTrack.bottomAnchor, constant: 14),
        timeRemainingLabel.leftAnchor.constraint(equalTo: notificationTitle.leftAnchor, constant: 0),
        timeRemainingLabel.heightAnchor.constraint(equalToConstant: 13),
        timeRemainingLabel.rightAnchor.constraint(equalTo: progressBarTrack.rightAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
