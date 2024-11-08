//
//  NotificationTableViewCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    //MARK: Properties
    var template: Notification? {
        didSet{
            if let object = template {
                
                guard let template = template else {return}

                notificationTitle.text = object.name
                
                var string = "Happen: "
                string += self.dateFormatterFullDate.string(from: object.eventDate)
                createdNotificationDateLabel.text = string
                
                var progressPercentageValue: CGFloat = 1
                //active
                if template.eventDate > Date(){
                    progressPercentageValue = CGFloat(abs(object.startDate.timeIntervalSinceNow) / abs(object.startDate.timeIntervalSince(object.eventDate)))

                    let notificationCalendar = NSCalendar.current
                    let competitionDifference = notificationCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date(), to: object.eventDate)
                    
                    notificationTitle.textColor = UIColor.init(white: 104/255, alpha: 1)
                    createdNotificationDateLabel.textColor = UIColor.init(white: 120/255, alpha: 1)
                    timeRemainingLabel.textColor = UIColor.init(white: 120/255, alpha: 1)
                    timeRemainingLabel.text = convertComponentsToString(dateComponents: competitionDifference)
                    
                    progressBarTrack.backgroundColor = UIColor.init(white: 236/255, alpha: 1)
                    progressBar.backgroundColor = UIColor.init(red: 52/255, green: 210/255, blue: 0, alpha: 1)
                    categoryIcon.image = setImageToCategory(category: object.category, expired: false)
                    
                    backgroundBubble.backgroundColor = .white
                    progressBar.isHidden = false
                    progressBarTrack.isHidden = false
                }else if template.eventDate < Date() && template.complete == false {//not displayed
                    notificationTitle.textColor = .white
                    createdNotificationDateLabel.textColor = UIColor.init(white: 172/255, alpha: 1)
                    backgroundBubble.backgroundColor = UIColor.init(white: 46/255, alpha: 1)
                    timeRemainingLabel.textColor = UIColor.init(white: 172/255, alpha: 1)
                    timeRemainingLabel.text = "Wasn't Displayed Yet!"
                    
                    categoryIcon.image = setImageToCategory(category: object.category, expired: false)
                    progressBar.isHidden = false
                    progressBarTrack.isHidden = false
                } else {//displayed style
                    notificationTitle.textColor = UIColor.init(white: 104/255, alpha: 1)
                    createdNotificationDateLabel.textColor = UIColor.init(white: 120/255, alpha: 1)
                    timeRemainingLabel.textColor = UIColor.init(white: 120/255, alpha: 1)
                    
                    backgroundBubble.backgroundColor = .white
                    progressBar.isHidden = true
                    progressBarTrack.isHidden = true
                    timeRemainingLabel.text = "Displayed"
                    categoryIcon.image = setImageToCategory(category: object.category, expired: true)
                }
                
                categoryIconWidthAnchor?.isActive = false
                categoryIconHeightAnchor?.isActive = false
                progressBarWidthAnchor?.isActive = false
                
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
                
                progressBarWidthAnchor = progressBar.widthAnchor.constraint(equalTo: progressBarTrack.widthAnchor, multiplier: progressPercentageValue)
                
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
        imageView.contentMode = .scaleAspectFill
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
    //icon style
    func setImageToCategory(category: String, expired: Bool) -> UIImage {
        guard let calendarBW = UIImage(named: "calendarIcon"), let calendarColor = UIImage(named: "calendarEventColor"), let projectBW = UIImage(named: "projectIcon"), let projectColor = UIImage(named: "cupColor") else {return UIImage()}
        var image = UIImage()
        
        switch category {
            case "event":
            image = expired ? calendarBW : calendarColor
                return image
            case "step":
            image = expired ? projectBW : projectColor
                return image
            default:
                return image
        }
        
    }
    
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
