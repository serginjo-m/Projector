//
//  ExpindingReminder.swift
//  Projector
//
//  Created by Serginjo Melnik on 18.08.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

class ExpandingReminder: UIView {
    
    //notification model
    var notification: Notification?
    
    let reminderTitle: UILabel = {
        let label = UILabel()
        label.text = "Set a Reminder?"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.init(white: 42/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 1
        return label
    }()
    
    lazy var reminderExpandButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.init(red: 53/255, green: 204/255, blue: 117/255, alpha: 1)
        button.addTarget(self, action: #selector(didTapExpandButton), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let reminderExpandIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "crossIcon")?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "This is date"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.init(white: 42/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.isHidden = true
        return label
    }()
    
    let dateLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 163/255, alpha: 1)
        view.isHidden = true
        return view
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = UIDatePicker.Mode.date
        picker.backgroundColor = .clear
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        picker.isHidden = true
        return picker
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "This is time"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.init(white: 42/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.isHidden = true
        return label
    }()
    
    let timeLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 163/255, alpha: 1)
        view.isHidden = true
        return view
    }()
    
    let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = UIDatePicker.Mode.time
        picker.backgroundColor = .clear
        picker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
        picker.isHidden = true
        return picker
    }()
    
    let applyReminderButton: UIButton = {
        let button = UIButton()
        button.setTitle("Apply", for: .normal)
        button.setTitleColor(UIColor.init(white: 61/255, alpha: 1) , for: .normal)
        button.setTitleColor(UIColor.init(white: 120/255, alpha: 1) , for: .disabled)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(named: "applyButton"), for: .normal)
        
        button.addTarget(self, action: #selector(didTapApplyButton), for: .touchUpInside)
        
        button.adjustsImageWhenHighlighted = false
       
        button.isHidden = true
        button.isEnabled = false
        return button
    }()
    
    //expand
    let didTapExpandCompletionHandler: (() -> Void)
    //apply reminder
    let didTapApplyCompletionHandler: (() -> Void)
    
    init(didTapExpandCompletionHandler: @escaping (() -> Void), didTapApplyCompletionHandler: @escaping (() -> Void)){
        
        self.didTapExpandCompletionHandler = didTapExpandCompletionHandler
        self.didTapApplyCompletionHandler = didTapApplyCompletionHandler
        
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    @objc func didTapExpandButton() {
        
        //hide or reveal all reminder form
        hideRevealContent(active: applyReminderButton.isSelected)
        
        //animate from parent
        didTapExpandCompletionHandler()
    }
    
    @objc func didTapApplyButton(button: UIButton) {
        
        //if apply create an instance of Notification object
        self.notification = Notification()
        //hide or reveal all reminder form
        hideRevealContent(active: applyReminderButton.isSelected)
        
        //IMPORTANT: indicates that user confirmed reminder !!!!
        applyReminderButton.isSelected = true
        
        //unwrap optionals
        if let dateString = dateLabel.text, let timeString = timeLabel.text, let notification = self.notification {
            
            //define string for reminderTitle label
            var string = ""
            //because when time is set it changes string to shorter than 12 characters :) (a bit ....)
            if timeString.count < 12 {
                //set date & time to label
                string = "Reminder: \(dateString) \(timeString)"
                
                //nofify that time is applied
                notification.eventTime = true
                //take date from date picker
                let date = datePicker.date
                
                //time
                let components = Calendar.current.dateComponents([.hour, .minute], from: timePicker.date)
                if let hour = components.hour, let minute = components.minute{
                    //final event date notification formated from date picker(date) & time picker (time only)
                    notification.eventDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date)!
                }
            }else{
                //only date applied
                string = "Reminder: \(dateString)"
                notification.eventDate = datePicker.date
            }
            
            //title contain two colors
            reminderTitle.textColor = UIColor.init(red: 95/255, green: 178/255, blue: 130/255, alpha: 1)
            reminderTitle.attributedText = prepareMutableString(
                string: string,
                fontSize: 15,
                color: UIColor.init(red: 20/255, green: 129/255, blue: 66/255, alpha: 1),
                location: 10,
                numberValue: string.count - 10)
        }
        
        //call parent func
        didTapApplyCompletionHandler()
    }
    
    
    //hide or reveal content
    fileprivate func hideRevealContent(active: Bool){
        
        //else block runs when reminder applied & user try to remove it
        guard  active == false else {
            
            //expect call here only from expand button & while apply == true
            //so before unblock set all to default value
            applyReminderButton.isEnabled = false
            self.reminderTitle.text = "Set a Reminder?"
            self.reminderTitle.textColor = UIColor.init(white: 42/255, alpha: 1)
            self.dateLabel.text = "This is date"
            self.timeLabel.text = "This is time"
            self.datePicker.date = Date()
            self.timePicker.date = Date()
            backgroundColor = UIColor.init(white: 239/255, alpha: 1)
            
            //remove previously created notification object
            self.notification = nil
    
            
            //rotate icon 45 degrees
            reminderExpandIcon.transform = reminderExpandIcon.transform.rotated(by: CGFloat(Double.pi/4))
            
            return
            
        }
        
        //hide views for compact view mode & reveal for full mode
        [self.dateLabel, self.dateLine, self.datePicker, self.timeLabel, self.timeLine, self.timePicker, self.applyReminderButton].forEach {
            $0.isHidden = !$0.isHidden
        }
    }
    
    //configure attributed string
    fileprivate func prepareMutableString(string: String, fontSize: CGFloat, color: UIColor, location: Int, numberValue: Int) -> NSMutableAttributedString{
        
        let mutableString = NSMutableAttributedString(string: string, attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontSize)])
        
        
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: location, length: numberValue))
        
        return mutableString
    }
    
    func setupView(){
        
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        backgroundColor = UIColor.init(white: 239/255, alpha: 1)
        layer.cornerRadius = 6
        layer.masksToBounds = true
        
        addSubview(reminderTitle)
        addSubview(reminderExpandButton)
        addSubview(reminderExpandIcon)
        addSubview(dateLabel)
        addSubview(dateLine)
        addSubview(datePicker)
        addSubview(timeLabel)
        addSubview(timeLine)
        addSubview(timePicker)
        addSubview(applyReminderButton)
        
        dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        dateLine.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 6).isActive = true
        dateLine.leftAnchor.constraint(equalTo: dateLabel.leftAnchor, constant: 0).isActive = true
        dateLine.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        dateLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
        datePicker.topAnchor.constraint(equalTo: dateLine.bottomAnchor, constant: 8).isActive = true
        datePicker.leftAnchor.constraint(equalTo: dateLine.leftAnchor, constant: 0).isActive = true
        datePicker.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        timeLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 26).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        timeLine.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 6).isActive = true
        timeLine.leftAnchor.constraint(equalTo: timeLabel.leftAnchor, constant: 0).isActive = true
        timeLine.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        timeLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        timePicker.topAnchor.constraint(equalTo: timeLine.bottomAnchor, constant: 8).isActive = true
        timePicker.leftAnchor.constraint(equalTo: timeLine.leftAnchor, constant: 0).isActive = true
        timePicker.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        timePicker.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        applyReminderButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        applyReminderButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 40).isActive = true
        applyReminderButton.widthAnchor.constraint(equalToConstant: 125).isActive = true
        applyReminderButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        reminderTitle.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        reminderTitle.leftAnchor.constraint(equalTo: leftAnchor, constant:  19).isActive = true
        reminderTitle.rightAnchor.constraint(equalTo: rightAnchor, constant:  -46).isActive = true
        reminderTitle.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        reminderExpandButton.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        reminderExpandButton.rightAnchor.constraint(equalTo: rightAnchor, constant:  -12).isActive = true
        reminderExpandButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
        reminderExpandButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        reminderExpandIcon.centerXAnchor.constraint(equalTo: reminderExpandButton.centerXAnchor, constant: 0).isActive = true
        reminderExpandIcon.centerYAnchor.constraint(equalTo: reminderExpandButton.centerYAnchor, constant: 0).isActive = true
        reminderExpandIcon.heightAnchor.constraint(equalToConstant: 13).isActive = true
        reminderExpandIcon.widthAnchor.constraint(equalToConstant: 13).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //date picker action
    @objc func dateChanged(_ sender: UIDatePicker) {

        //date
        let components = Calendar.current.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: sender.date)
        //configure date label from date components
        if let day = components.day, let month = components.month, let year = components.year, let weekday = components.weekday {
            let weekDayString = dayOfWeekLetter(for: weekday)
            let monthStr = monthString(for: month)
            dateLabel.text = ("\(weekDayString), \(day) \(monthStr) \(year)")
        }
        //unblock apply button
        applyReminderButton.isEnabled = true
    }
    
    //start time picker action
    @objc func timeChanged(_ sender: UIDatePicker) {
        //time
        let components = Calendar.current.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: sender.date)
        //configure time label from date components
        if let hour = components.hour, let minute = components.minute{
            timeLabel.text = "at \(hour):\(minute)"
        }
    }
    
   
    
    private func dayOfWeekLetter(for dayNumber: Int) -> String {
        switch dayNumber {
        case 1:
            return "Sun"
        case 2:
            return "Mon"
        case 3:
            return "Tue"
        case 4:
            return "Wed"
        case 5:
            return "Thu"
        case 6:
            return "Fri"
        case 7:
            return "Sat"
        default:
            return ""
        }
    }
    
    private func monthString(for monthNumber: Int) -> String {
        switch monthNumber {
        case 1:
            return "Jan"
        case 2:
            return "Feb"
        case 3:
            return "Mar"
        case 4:
            return "Apr"
        case 5:
            return "May"
        case 6:
            return "Jun"
        case 7:
            return "Jul"
        case 8:
            return "Aug"
        case 9:
            return "Sep"
        case 10:
            return "Oct"
        case 11:
            return "Nov"
        case 12:
            return "Dec"
        default:
            return ""
        }
    }
}


