//
//  ExpindingReminder.swift
//  Projector
//
//  Created by Serginjo Melnik on 18.08.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

class ExpandingReminder: UIView {
    
    //MARK: Properties
    var notification: Notification? {
        didSet{
            setReminderToActiveState()
            
            if let notification = self.notification {
            
                if notification.name.isEmpty == false{
                
                    self.notificationId = notification.id
                }
            }
        }
    }
    
    var notificationId: String?
    
    let reminderTitle: UILabel = {
        let label = UILabel()
        label.text = "Set a reminder?"
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
        label.text = "Set a reminder date & time"
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
    let didTapExpandCompletionHandler: (() -> Void)
    
    let didTapApplyCompletionHandler: (() -> Void)
    
    let presentAlertView: (() -> Void)
    
    init(didTapExpandCompletionHandler: @escaping (() -> Void), didTapApplyCompletionHandler: @escaping (() -> Void), presentAlertView: @escaping (() -> Void)){
        
        self.presentAlertView = presentAlertView
        self.didTapExpandCompletionHandler = didTapExpandCompletionHandler
        self.didTapApplyCompletionHandler = didTapApplyCompletionHandler
        
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    //MARK: Methods
    @objc func didTapExpandButton() {
        
        if #available(iOS 13.0, *) {
            if NotificationManager.shared.settings?.authorizationStatus == .authorized{
            }else if NotificationManager.shared.settings?.authorizationStatus == .notDetermined{
            }else{
                presentAlertView()
                return
            }
        } else {
            //
        }
        
        hideRevealContent(active: applyReminderButton.isSelected)
        didTapExpandCompletionHandler()
    }
    
    @objc func didTapApplyButton(button: UIButton) {
    
        hideRevealContent(active: applyReminderButton.isSelected)
        
        self.notification = Notification()
        
        didTapApplyCompletionHandler()
    }
    
    
    fileprivate func setReminderString() {
        
        guard let notification = self.notification else {return}
        
            if timePicker.isSelected == true{

                notification.eventTime = true

                let date = datePicker.date

                let components = Calendar.current.dateComponents([.hour, .minute], from: timePicker.date)
                if let hour = components.hour, let minute = components.minute{
                
                    notification.eventDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date)!
                }
            }else if datePicker.isSelected == true{
                notification.eventDate = datePicker.date
            }
        
            var string = "Reminder: "
            
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
        
        
            reminderTitle.textColor = UIColor.init(red: 95/255, green: 178/255, blue: 130/255, alpha: 1)
        
            reminderTitle.attributedText = prepareMutableString(
                string: string,
                fontSize: 15,
                color: UIColor.init(red: 20/255, green: 129/255, blue: 66/255, alpha: 1),
                location: 10,
                numberValue: string.count - 10)
            
    }
    
    func setReminderToActiveState(){
    
        applyReminderButton.isSelected = true

        if let notification = self.notification {

            backgroundColor = UIColor.init(red: 211/255, green: 250/255, blue: 227/255, alpha: 1)

            setReminderString()
            
            if notification.stepId.isEmpty == false{
                reminderExpandIcon.transform = reminderExpandIcon.transform.rotated(by: CGFloat(Double.pi/4))
            }
        }
    }
    
    fileprivate func hideRevealContent(active: Bool){
    
        guard  active == false else {
        
            self.notification = nil
            
            if let id = self.notificationId{

                if let reminderObject = ProjectListRepository.instance.getNotification(id: id) {

                    if #available(iOS 13.0, *) {
                        NotificationManager.shared.removeScheduledNotification(taskId: reminderObject.id)
                    }

                    ProjectListRepository.instance.deleteNotificationNote(note: reminderObject)
                }
            }
            self.reminderTitle.text = "Set a Reminder?"
            self.reminderTitle.textColor = UIColor.init(white: 42/255, alpha: 1)
            self.datePicker.date = Date()
            self.timePicker.date = Date()
            self.datePicker.isSelected = false
            self.timePicker.isSelected = false
            self.applyReminderButton.isEnabled = false

            backgroundColor = UIColor.init(white: 239/255, alpha: 1)

            reminderExpandIcon.transform = reminderExpandIcon.transform.rotated(by: CGFloat(Double.pi/4))
            return
        }
        
        [self.largeReminderTitle, self.dateLabel, self.datePicker, self.timeLabel, self.timePicker, self.applyReminderButton].forEach {
            $0.isHidden = !$0.isHidden
        }
    }
    
    fileprivate func prepareMutableString(string: String, fontSize: CGFloat, color: UIColor, location: Int, numberValue: Int) -> NSMutableAttributedString{
        
        let mutableString = NSMutableAttributedString(string: string, attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontSize)])
        
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: location, length: numberValue))
        
        return mutableString
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        datePicker.isSelected = true
        applyReminderButton.isEnabled = true
    }
    
    @objc func timeChanged(_ sender: UIDatePicker) {
        timePicker.isSelected = true
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


