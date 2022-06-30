//
//  ExpindingReminder.swift
//  Projector
//
//  Created by Serginjo Melnik on 18.08.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

class ExpandingReminder: UIView {
    
    //MARK: Variables
    //---> call from init or apply button
    //notification model
    var notification: Notification? {
        didSet{//can be set from database during page init or from reminder
            //convert reminder to active state
            //---> calls from init or when tap apply button
            setReminderToActiveState()
            //unwrap optional value
            if let notification = self.notification {
                //because name can only be defined by previously saved in database reminder
                if notification.name.isEmpty == false{
                    //hold inside var, because I know that object saved to database & should be removed if user
                    self.notificationId = notification.id
                }
            }
        }
    }
    
    //saved to realm Notification object id, so it can be removed when user do so
    //----> creates by didSet notification variable
    var notificationId: String?
    
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
    
    let largeReminderTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "Set a Reminder Date & Time"
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.init(white: 42/255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 15)
        label.isHidden = true
        return label
    }()
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = UIDatePicker.Mode.date
        picker.clipsToBounds = true
        picker.contentHorizontalAlignment = .left
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        picker.isHidden = true
        return picker
    }()
   
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "Time"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.init(white: 42/255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 15)
        label.isHidden = true
        return label
    }()
    
    lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = UIDatePicker.Mode.time
        picker.clipsToBounds = true
        picker.contentHorizontalAlignment = .left
        picker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
        picker.isHidden = true
        return picker
    }()
    
    lazy var applyReminderButton: UIButton = {
        let button = UIButton()
        button.setTitle("Apply", for: .normal)
        button.setTitleColor(UIColor.init(white: 61/255, alpha: 1) , for: .normal)
        button.setTitleColor(UIColor.init(white: 120/255, alpha: 1) , for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(named: "applyButton"), for: .normal)
        button.addTarget(self, action: #selector(didTapApplyButton), for: .touchUpInside)
        button.adjustsImageWhenHighlighted = false
        button.isHidden = true
        button.isEnabled = false
        return button
    }()
    
    //MARK: Initialization
    //expand
    //handle animate based on applyButton.isSelected
    let didTapExpandCompletionHandler: (() -> Void)
    //apply reminder
    let didTapApplyCompletionHandler: (() -> Void)
    
    init(didTapExpandCompletionHandler: @escaping (() -> Void), didTapApplyCompletionHandler: @escaping (() -> Void)){
        
        self.didTapExpandCompletionHandler = didTapExpandCompletionHandler
        self.didTapApplyCompletionHandler = didTapApplyCompletionHandler
        
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    //MARK: Methods
    //-----> call from expand button
    @objc func didTapExpandButton() {
        
        //hide or reveal all reminder form
        //----> calls when apply or expand
        hideRevealContent(active: applyReminderButton.isSelected)
        
        //animate from parent (constraints)
        didTapExpandCompletionHandler()
    }
    
    //apply button function
    @objc func didTapApplyButton(button: UIButton) {
        
        //hide or reveal all reminder form
        //----> calls when apply or expand
        hideRevealContent(active: applyReminderButton.isSelected)
        
        //if apply create an instance of Notification object
        self.notification = Notification()
        
        //call parent function
        didTapApplyCompletionHandler()
    }
    
    //reminder final string
    //-----> call from notification didSet --> setReminderToActiveState --> to here
    fileprivate func setReminderString() {
        
        guard let notification = self.notification else {return}
        
//            set Notification event date
//            if user specified reminder time
            if timePicker.isSelected == true{
                //notify that time is applied
                notification.eventTime = true
                //take date from date picker
                let date = datePicker.date
                //time
                let components = Calendar.current.dateComponents([.hour, .minute], from: timePicker.date)
                if let hour = components.hour, let minute = components.minute{
                    //final event date notification formated from date picker(date) & time picker (time only)
                    notification.eventDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date)!
                }
            }else if datePicker.isSelected == true{//if date without time point
                notification.eventDate = datePicker.date
            }
            
            //final string
            var string = "Reminder: "
            //check which date should be taken
            let date = timePicker.isSelected ? timePicker.date : datePicker.date
        
            let components = Calendar.current.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: date)
                if let day = components.day, let month = components.month, let year = components.year, let weekday = components.weekday, let hour = components.hour, let minute = components.minute {
                    
                    let weekDayString = dayOfWeekLetter(for: weekday)
                    let monthStr = monthString(for: month)
                    string += ("\(weekDayString), \(day) \(monthStr) \(year) ")
                    
                    if timePicker.isSelected{
                        string += "at \(hour):\(minute)"
                    }
            }
        
            //first title color
            reminderTitle.textColor = UIColor.init(red: 95/255, green: 178/255, blue: 130/255, alpha: 1)
            //second part with diff color
            reminderTitle.attributedText = prepareMutableString(
                string: string,
                fontSize: 15,
                color: UIColor.init(red: 20/255, green: 129/255, blue: 66/255, alpha: 1),
                location: 10,
                numberValue: string.count - 10)
            
    }
    
    //convert reminder to active state
    //---> call from notification didSet
    func setReminderToActiveState(){
        
        //IMPORTANT: indicates that user confirmed reminder !!!!
        applyReminderButton.isSelected = true
        //unwrap optional value
        if let notification = self.notification {
            //green color
            backgroundColor = UIColor.init(red: 211/255, green: 250/255, blue: 227/255, alpha: 1)
            //convert Notification event date to reminder title string
            setReminderString()
            
            //edit mode requires plus icon transformation when view controller is init
            if notification.stepId.isEmpty == false{
                reminderExpandIcon.transform = reminderExpandIcon.transform.rotated(by: CGFloat(Double.pi/4))
            }
        }
    }
    
    
    //hide or reveal content
    //------> call from expand button or apply button
    fileprivate func hideRevealContent(active: Bool){
        
        //else block executes when reminder applied & user try to remove it
        guard  active == false else {
            
            //remove previously created notification object,
            self.notification = nil
            
            //remove notification object from data base, if it exist
            if let id = self.notificationId{
                //get object by id
                if let reminderObject = ProjectListRepository.instance.getNotification(id: id) {
                    //remove object
                    ProjectListRepository.instance.deleteNotificationNote(note: reminderObject)
                }
            }
            
            //expect call here only from expand button & while apply == true
            //so before unblock set all views to default value
            self.reminderTitle.text = "Set a Reminder?"
            self.reminderTitle.textColor = UIColor.init(white: 42/255, alpha: 1)
            self.datePicker.date = Date()
            self.timePicker.date = Date()
            self.datePicker.isSelected = false
            self.timePicker.isSelected = false
            self.applyReminderButton.isEnabled = false
            //reminder background to gray color
            backgroundColor = UIColor.init(white: 239/255, alpha: 1)
            
            //rotate icon 45 degrees
            reminderExpandIcon.transform = reminderExpandIcon.transform.rotated(by: CGFloat(Double.pi/4))
            
            return
        }
        
        //hide views for compact view mode & reveal for full mode
        [self.largeReminderTitle, self.dateLabel, self.datePicker, self.timeLabel, self.timePicker, self.applyReminderButton].forEach {
            $0.isHidden = !$0.isHidden
        }
    }
    
    //configure attributed string
    fileprivate func prepareMutableString(string: String, fontSize: CGFloat, color: UIColor, location: Int, numberValue: Int) -> NSMutableAttributedString{
        
        let mutableString = NSMutableAttributedString(string: string, attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontSize)])
        
        
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: location, length: numberValue))
        
        return mutableString
    }
    
    
    
    //date picker action
    @objc func dateChanged(_ sender: UIDatePicker) {
        datePicker.isSelected = true
        //unblock apply button
        applyReminderButton.isEnabled = true
    }
    
    //start time picker action
    @objc func timeChanged(_ sender: UIDatePicker) {
        timePicker.isSelected = true
        //unblock apply button
        applyReminderButton.isEnabled = true
    }
    
    //MARK: Constraints
    func setupView(){
        
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        backgroundColor = UIColor.init(white: 239/255, alpha: 1)
        layer.cornerRadius = 6
        layer.masksToBounds = true
        
        addSubview(reminderTitle)
        addSubview(largeReminderTitle)
        addSubview(reminderExpandButton)
        addSubview(reminderExpandIcon)
        addSubview(dateLabel)
        addSubview(datePicker)
        addSubview(timeLabel)
        addSubview(timePicker)
        addSubview(applyReminderButton)
        
        largeReminderTitle.topAnchor.constraint(equalTo: topAnchor, constant: 45).isActive = true
        largeReminderTitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        largeReminderTitle.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        largeReminderTitle.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        datePicker.topAnchor.constraint(equalTo: largeReminderTitle.bottomAnchor, constant: 64).isActive = true
        datePicker.leftAnchor.constraint(equalTo: leftAnchor, constant: 17).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 35).isActive = true
        datePicker.widthAnchor.constraint(equalToConstant: 170).isActive = true

        timePicker.topAnchor.constraint(equalTo: datePicker.topAnchor, constant: 0).isActive = true
        timePicker.leftAnchor.constraint(equalTo: datePicker.rightAnchor, constant: 0).isActive = true
        timePicker.heightAnchor.constraint(equalToConstant: 35).isActive = true
        timePicker.widthAnchor.constraint(equalToConstant: 110).isActive = true
        
        applyReminderButton.leftAnchor.constraint(equalTo: timePicker.rightAnchor, constant: 0).isActive = true
        applyReminderButton.topAnchor.constraint(equalTo: timePicker.topAnchor, constant: 0).isActive = true
        applyReminderButton.widthAnchor.constraint(equalToConstant: 66).isActive = true
        applyReminderButton.heightAnchor.constraint(equalToConstant: 35).isActive = true


        dateLabel.bottomAnchor.constraint(equalTo: datePicker.topAnchor, constant: -10).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: datePicker.leftAnchor, constant: 11).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: datePicker.rightAnchor, constant: -11).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
    
        timeLabel.bottomAnchor.constraint(equalTo: timePicker.topAnchor, constant: -10).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: timePicker.leftAnchor, constant: 11).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: timePicker.rightAnchor, constant: -11).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
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


