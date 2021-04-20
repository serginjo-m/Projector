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
    //there I can have many options, becouse event can last more then 1 day or a couple of hours
    var eventDate: Date?
    var eventStart: Date?
    var eventEnd: Date?
    
    private lazy var dateFormatterFullDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter
    }()
    
    //unique project id for updating
    var eventId: String?
    
    //MARK: Properties
    
    let dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        return button
    }()
    
    let viewControllerTitle: UILabel = {
        let label = UILabel()
        label.text = "Create an Event"
        label.textColor = UIColor.init(displayP3Red: 55/255, green: 55/255, blue: 55/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .left
        return label
    }()
    
    //MARK: Properties
    let saveButton: UIButton = {
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
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.placeholder = "Title"
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
        label.text = "Date"
        label.textColor = UIColor.init(displayP3Red: 216/255, green: 216/255, blue: 216/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    let dateTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.textColor = UIColor.init(displayP3Red: 112/255, green: 112/255, blue: 112/255, alpha: 1)
        textField.placeholder = "    day / month / year"
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.init(displayP3Red: 216/255, green: 216/255, blue: 216/255, alpha: 1).cgColor
        
        textField.font = UIFont.boldSystemFont(ofSize: 14)
        return textField
    }()

    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = UIDatePicker.Mode.date
        picker.backgroundColor = .white
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        picker.layer.borderColor = UIColor.init(displayP3Red: 216/255, green: 216/255, blue: 216/255, alpha: 1).cgColor
        picker.layer.borderWidth = 1
        picker.isHidden = true
        return picker
    }()
    
    let startTimeTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.textColor = UIColor.init(displayP3Red: 112/255, green: 112/255, blue: 112/255, alpha: 1)
        textField.placeholder = "    start at: 00:00"
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.init(displayP3Red: 216/255, green: 216/255, blue: 216/255, alpha: 1).cgColor
        
        textField.font = UIFont.boldSystemFont(ofSize: 14)
        return textField
    }()
    
    let startTimePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = UIDatePicker.Mode.time
        picker.backgroundColor = .white
        picker.addTarget(self, action: #selector(startTimeChanged(_:)), for: .valueChanged)
        picker.layer.borderColor = UIColor.init(displayP3Red: 216/255, green: 216/255, blue: 216/255, alpha: 1).cgColor
        picker.layer.borderWidth = 1
        picker.isHidden = true
        return picker
    }()
    
    let endTimeTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.textColor = UIColor.init(displayP3Red: 112/255, green: 112/255, blue: 112/255, alpha: 1)
        textField.placeholder = "    end at: 00:00"
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.init(displayP3Red: 216/255, green: 216/255, blue: 216/255, alpha: 1).cgColor
        
        textField.font = UIFont.boldSystemFont(ofSize: 14)
        return textField
    }()
    
    let endTimePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = UIDatePicker.Mode.time
        picker.backgroundColor = .white
        picker.layer.borderColor = UIColor.init(displayP3Red: 216/255, green: 216/255, blue: 216/255, alpha: 1).cgColor
        picker.layer.borderWidth = 1
        picker.addTarget(self, action: #selector(endTimeChanged(_:)), for: .valueChanged)
        picker.isHidden = true
        return picker
    }()
    
    let descriptionTitle: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = UIColor.init(displayP3Red: 216/255, green: 216/255, blue: 216/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.init(displayP3Red: 216/255, green: 216/255, blue: 216/255, alpha: 1).cgColor
        textView.font = UIFont.boldSystemFont(ofSize: 14)
        textView.textColor = UIColor.init(displayP3Red: 112/255, green: 112/255, blue: 112/255, alpha: 1)
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = .white
        
        view.addSubview(dismissButton)
        view.addSubview(viewControllerTitle)
        view.addSubview(saveButton)
        view.addSubview(nameTextField)
        view.addSubview(lineUIView)
        view.addSubview(dateTitle)
        view.addSubview(dateTextField)
        view.addSubview(startTimeTextField)
        view.addSubview(endTimeTextField)
        view.addSubview(descriptionTitle)
        view.addSubview(descriptionTextView)
        view.addSubview(datePicker)
        view.addSubview(startTimePicker)
        view.addSubview(endTimePicker)
        
        //constraints
        setupLayout()
        
        //close date picker when touch outside textField
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        tapGestureReconizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureReconizer)

        //set delegate to name text field
        nameTextField.delegate = self
        dateTextField.delegate = self
        startTimeTextField.delegate = self
        endTimeTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //back to previous view
    @objc func saveAction(_ sender: Any) {
        
        let event: Event = self.defineEventTemplate()
        
        //unwrap optional date for activity object
        guard let eventDate = event.date else {return}
        
        if self.eventId == nil{
            //creates new project instance
            ProjectListRepository.instance.createEvent(event: event)
            
            UserActivitySingleton.shared.createUserActivity(description: "New Event on \(self.dateFormatterFullDate.string(from: eventDate)): \(event.title)")
        }else{
            //becouse event with that id exist it perform update
            ProjectListRepository.instance.updateEvent(event: event)
            //configure detail VC
            // self.delegate?.performAllConfigurations()
            //reload parents views
            // self.delegate?.reloadViews()
            UserActivitySingleton.shared.createUserActivity(description: "\(event.title) on \(self.dateFormatterFullDate.string(from: eventDate)) was updated")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //creates event instance
    func defineEventTemplate() -> Event{
        let eventTemplate = Event()
        if let text = nameTextField.text{
            eventTemplate.title = text
        }
        if let date = self.eventDate{
            eventTemplate.date = date
        }else{
            eventTemplate.date = Date()
        }
        if let description = descriptionTextView.text{
            eventTemplate.descr = description
        }
        return eventTemplate
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
        updatePickerHiddenState(textField: textField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Disable the Save button while editing.
        saveButton.isEnabled = false
        //show date picker
        updatePickerHiddenState(textField: textField)
    }
    
    func updatePickerHiddenState(textField: UITextField){
        switch textField {
        case _ where textField == dateTextField:
            datePicker.isHidden = !datePicker.isHidden
        case _ where textField == startTimeTextField:
            startTimePicker.isHidden = !startTimePicker.isHidden
        case _ where textField == endTimeTextField:
            endTimePicker.isHidden = !endTimePicker.isHidden
        default:
            break
        }
    }
    
    //date picker action
    @objc func dateChanged(_ sender: UIDatePicker) {
        //date
        self.eventDate = sender.date
        setTextFieldText(sender: sender, senderDate: sender.date)
    }
    
    //start time picker action
    @objc func startTimeChanged(_ sender: UIDatePicker) {
        //start
        self.eventStart = sender.date
        setTextFieldText(sender: sender, senderDate: sender.date)
    }
    
    //end time picker action
    @objc func endTimeChanged(_ sender: UIDatePicker) {
        //end
        self.eventEnd = sender.date
        setTextFieldText(sender: sender, senderDate: sender.date)
    }
    
    private func setTextFieldText(sender: UIDatePicker, senderDate: Date){
        let components = Calendar.current.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: senderDate)

        switch sender{
            case _ where sender == datePicker:
                if let day = components.day, let month = components.month, let year = components.year, let weekday = components.weekday {
                    let weekDayString = dayOfWeekLetter(for: weekday)
                    let monthStr = monthString(for: month)
                    dateTextField.text = ("    \(weekDayString), \(day) \(monthStr) \(year)")
                }
            case _ where sender == startTimePicker:
                if let hour = components.hour, let minute = components.minute{
                    startTimeTextField.text = "    \(hour):\(minute)"
                }
            case _ where sender == endTimePicker:
                if let hour = components.hour, let minute = components.minute{
                    endTimeTextField.text = "    \(hour):\(minute)"
                }
            default:
                break
        }
    }
    
    private func updateSaveButtonState(){
        //Disable the Save button when text field is empty.
        let text = nameTextField.text ?? ""
        let date = dateTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty && !date.isEmpty
    }
    
    
    
    private func setupLayout(){
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        viewControllerTitle.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        lineUIView.translatesAutoresizingMaskIntoConstraints = false
        dateTitle.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        startTimeTextField.translatesAutoresizingMaskIntoConstraints = false
        startTimePicker.translatesAutoresizingMaskIntoConstraints = false
        endTimeTextField.translatesAutoresizingMaskIntoConstraints = false
        endTimePicker.translatesAutoresizingMaskIntoConstraints = false
        descriptionTitle.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        viewControllerTitle.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 60).isActive = true
        viewControllerTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        viewControllerTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        viewControllerTitle.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        nameTextField.topAnchor.constraint(equalTo: viewControllerTitle.bottomAnchor, constant: 27).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        lineUIView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 4).isActive = true
        lineUIView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        lineUIView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        lineUIView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        dateTitle.topAnchor.constraint(equalTo: lineUIView.bottomAnchor, constant: 30).isActive = true
        dateTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        dateTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        dateTitle.heightAnchor.constraint(equalToConstant: 17).isActive = true
        
        dateTextField.topAnchor.constraint(equalTo: dateTitle.bottomAnchor, constant: 12).isActive = true
        dateTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        dateTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        dateTextField.heightAnchor.constraint(equalToConstant: 43).isActive = true
        
        datePicker.topAnchor.constraint(equalTo: dateTextField.bottomAnchor, constant: 0).isActive = true
        datePicker.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        datePicker.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        startTimeTextField.topAnchor.constraint(equalTo: dateTextField.bottomAnchor, constant: 12).isActive = true
        startTimeTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        startTimeTextField.widthAnchor.constraint(equalToConstant: ((view.frame.size.width - 30) / 2) - 6).isActive = true
        startTimeTextField.heightAnchor.constraint(equalToConstant: 43).isActive = true
        
        startTimePicker.topAnchor.constraint(equalTo: startTimeTextField.bottomAnchor, constant: 0).isActive = true
        startTimePicker.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        startTimePicker.widthAnchor.constraint(equalTo: startTimeTextField.widthAnchor, multiplier: 1).isActive = true
        startTimePicker.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        endTimeTextField.topAnchor.constraint(equalTo: dateTextField.bottomAnchor, constant: 12).isActive = true
        endTimeTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        endTimeTextField.widthAnchor.constraint(equalToConstant: ((view.frame.size.width - 30) / 2) - 6).isActive = true
        endTimeTextField.heightAnchor.constraint(equalToConstant: 43).isActive = true
        
        endTimePicker.topAnchor.constraint(equalTo: endTimeTextField.bottomAnchor, constant: 0).isActive = true
        endTimePicker.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        endTimePicker.widthAnchor.constraint(equalTo: endTimeTextField.widthAnchor, multiplier: 1).isActive = true
        endTimePicker.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        descriptionTitle.topAnchor.constraint(equalTo: endTimeTextField.bottomAnchor, constant: 30).isActive = true
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
