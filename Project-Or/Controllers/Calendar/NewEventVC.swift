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

//MARK: OK
class NewEventViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //MARK: Properties
    var eventDate = Date()
    var eventStart: Date?
    var eventEnd: Date?
    var stepId: String?
    var projectId: String?
    //quick notes saves image url here
    var pictureUrl: String?
    
    private lazy var dateFormatterFullDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter
    }()
    
    //update requires information about event
    var event: Event?
    
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
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(named: "saveTo"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
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
        
    lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.attributedPlaceholder = NSAttributedString(string: "Title",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(white: 96/255, alpha: 1)])
        textField.font = UIFont.boldSystemFont(ofSize: 22)
        textField.addTarget(self, action:  #selector(textFieldEditing), for: .editingChanged)
        textField.delegate = self
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
        picker.date = formatTimeBasedDate(date: eventDate, anticipateHours: 0, anticipateMinutes: 30)
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
    
    var requiredStarLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "*"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .mainPink
        label.textAlignment = .left
        return label
    }()
    
    var dismissButtonTopAnchor: NSLayoutConstraint!
    
    //MARK: Lifecycle
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
        view.addSubview(requiredStarLabel)
        
        //constraints
        setupLayout()
        
        //close date picker when touch outside textField
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        tapGestureReconizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureReconizer)

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
    }
    
    override func viewDidLayoutSubviews() {
        updateSaveButtonState()
    }
    //MARK: Methods
    fileprivate func configureKeyboardObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    @objc fileprivate func handleKeyboardWillHide(notification: NSNotification){
        
        if let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            
            dismissButtonTopAnchor.constant = 15
            
            UIView.animate(withDuration: keyboardDuration, delay: 0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc fileprivate func handleKeyboardWillShow(notification: NSNotification){
                
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        //keyboard pop-up animation duration
        if let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            if let keyboardRectangle = keyboardFrame?.cgRectValue {
                
                let  frameContentDifference = self.view.frame.height - 680
                
                dismissButtonTopAnchor.constant = -(keyboardRectangle.height - frameContentDifference)
                
                UIView.animate(withDuration: keyboardDuration, delay: 0) {
                    self.view.layoutIfNeeded()
                }
            }
        }
       
    }
    
    @objc func saveAction(_ sender: Any) {
        //creates new or update existing
        let event: Event = self.defineEventTemplate()
        if reminderSwitch.isOn == true {
            //check if current event has previously created notification/reminder
            checkForPrevNotification()
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
            checkForPrevNotification()
        }
        
        //unwrap optional date for activity object
        guard let eventDate = event.date else {return}
        //new event
        if self.eventId == nil{
            //creates new project instance
            ProjectListRepository.instance.createEvent(event: event)
            UserActivitySingleton.shared.createUserActivity(description: "New Event on \(self.dateFormatterFullDate.string(from: eventDate)): \(event.title)")
        }else{
            //because an event with that ID stored it performs an update
            ProjectListRepository.instance.updateEvent(event: event)
            UserActivitySingleton.shared.createUserActivity(description: "\(event.title) on \(self.dateFormatterFullDate.string(from: eventDate)) was updated")
        }
        
        if let stepIdentifier = self.stepId{
            if let step = ProjectListRepository.instance.getProjectStep(id: stepIdentifier){
                ProjectListRepository.instance.updateStepEvent(step: step, event: event)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func checkForPrevNotification(){
        
        guard let currentEvent = self.event, let currentReminder = currentEvent.reminder else {return}
        print(currentReminder.id)
        //check if current event has previously created notification/reminder
        if #available(iOS 13.0, *) {
            NotificationManager.shared.removeScheduledNotification(taskId: currentReminder.id)
        }
        ProjectListRepository.instance.deleteNotificationNote(note: currentReminder)
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
    
    //creates an event instance
    func defineEventTemplate() -> Event{
        
        let eventTemplate = Event()
        
        if let text = nameTextField.text{
            eventTemplate.title = text
        }
        
        eventTemplate.date = eventDate
        
        eventTemplate.startTime = eventStart != nil ? eventStart : eventDate
        
        if let eventStartTime = eventTemplate.startTime{
            eventTemplate.endTime = eventEnd != nil ? eventEnd : formatTimeBasedDate(date: eventStartTime, anticipateHours: 1, anticipateMinutes: 0)
        }
    
        eventTemplate.projectId = self.projectId
        eventTemplate.stepId = self.stepId
    
        if let stepIdentifier = self.stepId{

            eventTemplate.category = "projectStep"
            if let step = ProjectListRepository.instance.getProjectStep(id: stepIdentifier){
                if step.selectedPhotosArray.count > 0{
                    eventTemplate.picture = step.selectedPhotosArray[0]
                }
            }
        }
        if let eventIdentifier = eventId {
            eventTemplate.id = eventIdentifier
        }
        if let description = descriptionTextView.text{
            eventTemplate.descr = description
        }
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
    
    //MARK: TextField
    //close date picker after touch outside textField
    @objc func tap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldEditing(_ textfield: UITextField) {
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState(){
        guard let text = nameTextField.text else {return}
        saveButton.isEnabled = !text.isEmpty
        requiredStarLabel.isHidden = saveButton.isEnabled
    }
    //date picker
    @objc func dateChanged(_ sender: UIDatePicker) {
        guard let startDate = eventStart, let endDate = eventEnd else {return}
        self.eventDate = sender.date
        self.startTimePicker.date = formatTimeBasedDate(date: startDate, anticipateHours: 0, anticipateMinutes: 0)
        self.eventStart = self.startTimePicker.date
        self.endTimePicker.date = formatTimeBasedDate(date: endDate, anticipateHours: 0, anticipateMinutes: 0)
        self.eventEnd = self.endTimePicker.date
    }

    //start time picker
    @objc func startTimeChanged(_ sender: UIDatePicker) {
        self.datePicker.date = formatTimeBasedDate(date: sender.date, anticipateHours: 0, anticipateMinutes: 0)
        self.eventDate = self.datePicker.date
        self.eventStart = formatTimeBasedDate(date: sender.date, anticipateHours: 0, anticipateMinutes: 0)
        self.endTimePicker.date = formatTimeBasedDate(date: sender.date, anticipateHours: 0, anticipateMinutes: 30)
        self.eventEnd = self.endTimePicker.date
        updateSaveButtonState()
    }

    //end time picker
    @objc func endTimeChanged(_ sender: UIDatePicker) {
        let minDuration = formatTimeBasedDate(date: startTimePicker.date, anticipateHours: 0, anticipateMinutes: 30)
        if sender.date < minDuration {
            sender.date = minDuration
        }
        self.eventEnd = formatTimeBasedDate(date: sender.date, anticipateHours: 0, anticipateMinutes: 0)
        updateSaveButtonState()
    }
    
    //anticipate time 
    fileprivate func formatTimeBasedDate(date: Date, anticipateHours: Int, anticipateMinutes: Int) -> Date{
        let calendar = NSCalendar.current
        var anticipatedDate = date
        if anticipateMinutes > 0 {
            anticipatedDate = calendar.date(byAdding: .minute, value: anticipateMinutes, to: date) ?? Date()
        }
        if anticipateHours > 0 {
            anticipatedDate = calendar.date(byAdding: .hour, value: anticipateHours, to: date) ?? Date()
        }
        return anticipatedDate
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
        
        dismissButtonTopAnchor = dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15)
        dismissButtonTopAnchor.isActive = true
        dismissButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        viewControllerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        viewControllerTitle.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor, constant: 0).isActive = true
        viewControllerTitle.widthAnchor.constraint(equalToConstant: 150).isActive = true
        viewControllerTitle.heightAnchor.constraint(equalToConstant: 21).isActive = true

        saveButton.topAnchor.constraint(equalTo: dismissButton.topAnchor, constant: 0).isActive = true
        saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 85).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        imageHolderView.topAnchor.constraint(equalTo: viewControllerTitle.bottomAnchor, constant: 55).isActive = true
        imageHolderView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        imageHolderView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        imageHolderView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        nameTextField.topAnchor.constraint(equalTo: imageHolderView.bottomAnchor, constant: 40).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        requiredStarLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        requiredStarLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor, constant: 48).isActive = true
        requiredStarLabel.topAnchor.constraint(equalTo: nameTextField.topAnchor).isActive = true
        requiredStarLabel.widthAnchor.constraint(equalToConstant: 10).isActive = true
        
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
