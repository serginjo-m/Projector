//
//  NewEventViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 27.12.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//


import UIKit
import RealmSwift
import Foundation
import os
import Photos


class NewEventViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //---------------------------- temporary solution --------------------------------------
    //there I can have many options, because event can last more then 1 day or a couple of hours
    //MARK: Properties
    
    //start & end time can be different from datePicker Date()
    //so I use function to format the same Date() for all
    var eventDate = Date()
    var eventStart: Date?
    var eventEnd: Date?
    //project step events need some configuration
    var stepId: String?
    var projectId: String?
    //quick notes save image url here
    var pictureUrl: String?
    
    private lazy var dateFormatterFullDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter
    }()
    
    //update event needs some information about event
    var event: Event?
    //unique project id for updating
    var eventId: String? {
        didSet{
            if let eventId = eventId {
                let currentEvent = ProjectListRepository.instance.getEvent(id: eventId)
                self.event = currentEvent
                guard let unwCurrentEvent = currentEvent else {return}
                if let projectIdentifier = unwCurrentEvent.projectId, let stepIdentifier = unwCurrentEvent.stepId{
                    self.stepId = stepIdentifier
                    self.projectId = projectIdentifier
                }
                
            }
        }
    }
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        
        button.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
       
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        return button
    }()
    
    let viewControllerTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Create New Event"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "okButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    var imageHolderView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "newEventDefault")
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 11
        view.clipsToBounds = true
        return view
    }()
        
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.attributedPlaceholder = NSAttributedString(string: "Title",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 96/255, alpha: 1)])
        textField.font = UIFont.boldSystemFont(ofSize: 22)
        
        return textField
    }()
    
    let lineUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(displayP3Red: 216/255, green: 216/255, blue: 216/255, alpha: 1)
        return view
    }()
    
    let dateTitle: UILabel = {
        let label = UILabel()
        label.text = "  Date"
        label.textColor = UIColor.init(white: 96/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    let startTimeTitle: UILabel = {
        let label = UILabel()
        label.text = "  Start"
        label.textColor = UIColor.init(white: 96/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    let endTimeTitle: UILabel = {
        let label = UILabel()
        label.text = "  End"
        label.textColor = UIColor.init(white: 96/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.contentHorizontalAlignment = .left
        picker.datePickerMode = UIDatePicker.Mode.date
        
        picker.clipsToBounds = true
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    
    lazy var startTimePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = UIDatePicker.Mode.time
        picker.contentHorizontalAlignment = .left
        picker.clipsToBounds = true
        picker.addTarget(self, action: #selector(startTimeChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    lazy var endTimePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = UIDatePicker.Mode.time
        picker.contentHorizontalAlignment = .left
        picker.clipsToBounds = true
        picker.date = formatTimeBasedDate(date: eventDate, anticipateHours: 1, anticipateMinutes: 0)
        picker.addTarget(self, action: #selector(endTimeChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    lazy var titleStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dateTitle, startTimeTitle, endTimeTitle])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        return stack
    }()
    
    lazy var pickerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [datePicker, startTimePicker, endTimePicker])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        return stack
    }()
    
    let reminderTitle: UILabel = {
        let label = UILabel()
        label.text = "Add a Reminder"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.init(white: 96/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .left
        return label
    }()
    
    lazy var reminderSwitch: UISwitch = {
        let swtch = UISwitch()
        swtch.translatesAutoresizingMaskIntoConstraints = false
        if let eventObject = self.event {
            swtch.isOn = eventObject.reminder != nil ? true : false
        }
        swtch.addTarget(self, action: #selector(switchChangedValue), for: .valueChanged)
        return swtch
    }()
    
    let descriptionTitle: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = UIColor.init(white: 96/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .left
        return label
    }()
    
    var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 6
        textView.backgroundColor = UIColor.init(white: 239/255, alpha: 1)
        textView.font = UIFont.boldSystemFont(ofSize: 14)
        textView.textColor = UIColor.init(displayP3Red: 112/255, green: 112/255, blue: 112/255, alpha: 1)
        return textView
    }()
    
    //MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = .white
        
        view.addSubview(dismissButton)
        view.addSubview(viewControllerTitle)
        view.addSubview(saveButton)
        view.addSubview(imageHolderView)
        view.addSubview(nameTextField)
        view.addSubview(lineUIView)
        view.addSubview(reminderTitle)
        view.addSubview(reminderSwitch)
        view.addSubview(descriptionTitle)
        view.addSubview(descriptionTextView)
        view.addSubview(pickerStackView)
        view.addSubview(titleStackView)
        
        //constraints
        setupLayout()
        
        //close date picker when touch outside textField
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        tapGestureReconizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureReconizer)

        //set delegate to  text field
        nameTextField.delegate = self
<<<<<<< HEAD
        configureKeyboardObservers()
        hideKeyboardWhenTappedAround()
        
        //request permission for sending notifications
        if #available(iOS 13.0, *) {
            NotificationManager.shared.requestAuthorization { granted in
                
                if granted {
                    //showNotificationSettingsUI = true
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //prevent multiple keyboard observers
        NotificationCenter.default.removeObserver(self)
=======
>>>>>>> parent of 372361c (Zoom step images & keyboard)
    }
    
  
    //MARK: Methods
    @objc func saveAction(_ sender: Any) {
        //creates new or update existing
        let event: Event = self.defineEventTemplate()
        
        if reminderSwitch.isOn == true {
            
            //check if current event has previously created notification/reminder
            //If so, remove previous one
            if let currentEvent = self.event, let currentReminder = currentEvent.reminder {
                if #available(iOS 13.0, *) {
                    NotificationManager.shared.removeScheduledNotification(taskId: currentReminder.id)
                }
                ProjectListRepository.instance.deleteNotificationNote(note: currentReminder)
            }
            
            //Notification displays in Notification Tab
            event.reminder = createNotification(event: event)
            
            if #available(iOS 13.0, *) {
                
                //Task object, that passing in NotificationManager, contains reminder
                let reminder = Reminder(timeInterval: nil, date: event.date, location: nil, reminderType: .calendar, repeats: false)
                //if Event contains Notification (unwrap optional value)
                if let eventReminder = event.reminder{
                    //create Task from Notification properties
                    let task = Task(reminder: reminder, eventDate: eventReminder.eventDate, eventTime: eventReminder.eventTime, startDate: eventReminder.eventDate, name: eventReminder.name, category: eventReminder.category, complete: eventReminder.complete, projectId: eventReminder.projectId, stepId: eventReminder.stepId, id: eventReminder.id)
                    //schedule notification
                    NotificationManager.shared.scheduleNotification(task: task)
                }
            }
            
        }else{ //reminder switch.isOn == false

            //check if current event has previously created notification/reminder
            if let currentEvent = self.event, let currentReminder = currentEvent.reminder {
                if #available(iOS 13.0, *) {
                    NotificationManager.shared.removeScheduledNotification(taskId: currentReminder.id)
                }
                ProjectListRepository.instance.deleteNotificationNote(note: currentReminder)
            }
        }
        
        //unwrap optional date for activity object
        guard let eventDate = event.date else {return}
        //new event
        if self.eventId == nil{
            
            //creates new project instance
            ProjectListRepository.instance.createEvent(event: event)
            
            UserActivitySingleton.shared.createUserActivity(description: "New Event on \(self.dateFormatterFullDate.string(from: eventDate)): \(event.title)")
        }else{
            //because event with that id exist it perform update
            ProjectListRepository.instance.updateEvent(event: event)
            //save event  to activity
            UserActivitySingleton.shared.createUserActivity(description: "\(event.title) on \(self.dateFormatterFullDate.string(from: eventDate)) was updated")
        }
        
        if let stepIdentifier = self.stepId{
            //assign image to step event
            if let step = ProjectListRepository.instance.getProjectStep(id: stepIdentifier){

                ProjectListRepository.instance.updateStepEvent(step: step, event: event)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func createNotification(event: Event) -> Notification {
       
        let notification = Notification()
        notification.name = event.title
        notification.timeInterval = 0.0
        if let projId = projectId, let stepIdentifier = stepId {
            notification.projectId = projId
            notification.stepId = stepIdentifier
        }
        notification.reminderType = "calendar"
        notification.category = stepId != nil ? "step" : "event"
        notification.eventTime = self.eventStart != nil ? true : false
        
        if let date = event.date{
            notification.eventDate = date
        }
        return notification
    }
    
    //creates event instance
    func defineEventTemplate() -> Event{
        
        let eventTemplate = Event()
        
        if let text = nameTextField.text{
            eventTemplate.title = text
        }
        
        //as picker change it save Date to this var
        eventTemplate.date = eventDate
        
        //startTime must have the same Date as eventDate
        eventTemplate.startTime = eventStart != nil ? eventStart : eventDate
        
        //whatever eventTemplate start time is, if end time is not defined it anticipates 1 hour from event start
        if let eventStartTime = eventTemplate.startTime{
            //if end time is not defined, define event duration as 1 hour event
            eventTemplate.endTime = eventEnd != nil ? eventEnd : formatTimeBasedDate(date: eventStartTime, anticipateHours: 1, anticipateMinutes: 0)
        }
        
        //try to set properties
        eventTemplate.projectId = self.projectId
        eventTemplate.stepId = self.stepId
        
        
        if let stepIdentifier = self.stepId{
            //if NewEventViewController has a step identifier, it means that event type is a project step
            eventTemplate.category = "projectStep"
            //assign image to step event
            if let step = ProjectListRepository.instance.getProjectStep(id: stepIdentifier){
                if step.selectedPhotosArray.count > 0{
                    eventTemplate.picture = step.selectedPhotosArray[0]
                }
                //remove existing Event, Notification, Push Notification
                if let existingEvent = step.event{
                    
                    if let notification = existingEvent.reminder{
                        if #available(iOS 13.0, *) {
                            NotificationManager.shared.removeScheduledNotification(taskId: notification.id)
                        }
                        ProjectListRepository.instance.deleteNotificationNote(note: notification)
                    }
                    ProjectListRepository.instance.deleteEvent(event: existingEvent)
                }
            }
        }
        
        if let eventIdentifier = eventId {
            eventTemplate.id = eventIdentifier
        }
        
        if let description = descriptionTextView.text{
            eventTemplate.descr = description
        }
        //quick notes with images define url
        if let url = pictureUrl {
            eventTemplate.picture = url
        }
        
        return eventTemplate
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func switchChangedValue(sender: UISwitch){
        if #available(iOS 13.0, *) {
            if NotificationManager.shared.settings?.authorizationStatus == .authorized{

            }else if NotificationManager.shared.settings?.authorizationStatus == .notDetermined{

            }else{
                //present alert message, that invites user for enable notifications
                let ac = UIAlertController(title: "Notifications are Disabled", message: "To turn on notifications, please go to Settings > Notifications > Projector", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
                sender.isOn = false
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    //close date picker after touch outside textField
    @objc func tap(sender: UITapGestureRecognizer) {
        //calls textFieldDidEndEditing
        view.endEditing(true)
        // or use
        //        noteTextView.resignFirstResponder()
        // or use
        //        view.super().endEditing(true)
        // or use
        //        view.keyboardDismissMode = .onDrag
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Disable the Save button while editing.
        saveButton.isEnabled = false
        //show date picker
    }
    
    //date picker action
    @objc func dateChanged(_ sender: UIDatePicker) {
        guard let startDate = eventStart, let endDate = eventEnd else {return}
        
        self.eventDate = sender.date
        
        self.startTimePicker.date = formatTimeBasedDate(date: startDate, anticipateHours: 0, anticipateMinutes: 0)
        self.eventStart = self.startTimePicker.date
        
        
        self.endTimePicker.date = formatTimeBasedDate(date: endDate, anticipateHours: 0, anticipateMinutes: 0)
        self.eventEnd = self.endTimePicker.date
    }

    //start time picker action
    @objc func startTimeChanged(_ sender: UIDatePicker) {
        
        //because format function takes event date like a day parameter, set picker date first
        self.datePicker.date = formatTimeBasedDate(date: sender.date, anticipateHours: 0, anticipateMinutes: 0)
        self.eventDate = self.datePicker.date
        
        //-------------> start time picker is changed
        //define exact time, when event should begin
        self.eventStart = formatTimeBasedDate(date: sender.date, anticipateHours: 0, anticipateMinutes: 0)
        
        
        //anticipate end time to 1 hour by default
        self.endTimePicker.date = formatTimeBasedDate(date: sender.date, anticipateHours: 1, anticipateMinutes: 0)
        self.eventEnd = self.endTimePicker.date
        
        updateSaveButtonState()
    }

    //end time picker action
    @objc func endTimeChanged(_ sender: UIDatePicker) {
        
        //--------> so it did not change the main date
        // that's why I should leave it as it is
        
        //---------> it did not affect start time
        //so even here I haven't to do something
        
        //---------> sender date is changed in picker
        //prevent error, when end time is less than start time
        if sender.date < startTimePicker.date {
            sender.date = formatTimeBasedDate(date: startTimePicker.date, anticipateHours: 1, anticipateMinutes: 0)
        }
        
        //define exact time, when event should end
        self.eventEnd = formatTimeBasedDate(date: sender.date, anticipateHours: 0, anticipateMinutes: 0)
        
        
        updateSaveButtonState()
    }
    
    //anticipate time 
    fileprivate func formatTimeBasedDate(date: Date, anticipateHours: Int, anticipateMinutes: Int) -> Date{
        //extract hours and minutes from date parameter
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = components.hour! + anticipateHours
        let minute = components.minute! + anticipateMinutes
        
        //using current date and picker time for date formatting
        guard let compiledDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: eventDate) else { return date}
        return compiledDate
    }
    
    private func updateSaveButtonState(){
        //Disable the Save button when text field is empty.
        let text = nameTextField.text ?? ""
        //let date = dateTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty//--------------------- && !date.isEmpty
            
        if startTimePicker.date > endTimePicker.date {
            endTimeTitle.text = "Is less than start!"
            endTimeTitle.textColor = .red

            saveButton.isEnabled = false
        }else{
            endTimeTitle.text = " End"
            endTimeTitle.textColor = UIColor.init(white: 96/255, alpha: 1)
            saveButton.isEnabled = true
        }
    }
    
    //MARK: Constraints
    private func setupLayout(){
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        viewControllerTitle.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        lineUIView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTitle.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        viewControllerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        viewControllerTitle.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor, constant: 0).isActive = true
        viewControllerTitle.widthAnchor.constraint(equalToConstant: 150).isActive = true
        viewControllerTitle.heightAnchor.constraint(equalToConstant: 21).isActive = true

        saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        imageHolderView.topAnchor.constraint(equalTo: viewControllerTitle.bottomAnchor, constant: 55).isActive = true
        imageHolderView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        imageHolderView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        imageHolderView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        nameTextField.topAnchor.constraint(equalTo: imageHolderView.bottomAnchor, constant: 40).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        lineUIView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 4).isActive = true
        lineUIView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        lineUIView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        lineUIView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        titleStackView.topAnchor.constraint(equalTo: lineUIView.bottomAnchor, constant: 45).isActive = true
        titleStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        titleStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        titleStackView.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        pickerStackView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 3).isActive = true
        pickerStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        pickerStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        pickerStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        reminderTitle.topAnchor.constraint(equalTo: pickerStackView.bottomAnchor, constant: 45).isActive = true
        reminderTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        reminderTitle.widthAnchor.constraint(equalToConstant: 130).isActive = true
        reminderTitle.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        reminderSwitch.centerYAnchor.constraint(equalTo: reminderTitle.centerYAnchor, constant: 0).isActive = true
        reminderSwitch.leftAnchor.constraint(equalTo: reminderTitle.rightAnchor, constant: 15).isActive = true
        reminderSwitch.widthAnchor.constraint(equalToConstant: 51).isActive = true
        reminderSwitch.heightAnchor.constraint(equalToConstant: 31).isActive = true
        
        descriptionTitle.topAnchor.constraint(equalTo: reminderTitle.bottomAnchor, constant: 45).isActive = true
        descriptionTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        descriptionTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        descriptionTitle.heightAnchor.constraint(equalToConstant: 17).isActive = true
        
        descriptionTextView.topAnchor.constraint(equalTo: descriptionTitle.bottomAnchor, constant: 12).isActive = true
        descriptionTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        descriptionTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        descriptionTextView.heightAnchor.constraint(equalToConstant: 126).isActive = true
    }
    
    
}
extension NewEventViewController{
    private func dayOfWeekLetter(for dayNumber: Int) -> String {
        switch dayNumber {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
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
