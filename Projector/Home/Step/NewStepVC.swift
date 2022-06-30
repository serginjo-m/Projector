//
//  NewStepViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 23.11.2019.
//  Copyright © 2019 Serginjo Melnik. All rights reserved.
//
import UIKit
import RealmSwift
import os.log
import Photos


class NewStepViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NewStepImagesDelegate {
    
    //MARK: Properties
    //push to view controller, reloadViews , perform configurations
    weak var delegate: EditViewControllerDelegate?
    //set the project, that step is belongs to
    var projectId: String?
    //step id passed by detail VC
    var stepID: String?
    //step completion status
    var stepComplete: Bool?
    // list of items in step
    var stepItems = [String]()
    // step progress category
    var selectedStepProgress: Int = 0
    
    var realm: Realm!//create a var
    
    let colorArr = [
        UIColor.init(red: 56/255, green: 136/255, blue: 255/255, alpha: 1),//blue color
        UIColor.init(red: 248/255, green: 182/255, blue: 24/255, alpha: 1),//orange color
        UIColor.init(red: 17/255, green: 201/255, blue: 109/255, alpha: 1),//green color
        UIColor.init(red: 236/255, green: 65/255, blue: 91/255, alpha: 1)//red color
    ]
    
    lazy var todoButton: UIButton = {
        let button = UIButton()
        button.setTitle("To-do", for: .normal)
        button.setTitleColor(UIColor.init(white: 101/255, alpha: 1), for: .normal)
        button.setTitleColor(colorArr[0], for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(handleButtonsActiveState(_:)), for: .touchUpInside)
        button.isSelected = true
        button.tag = 0
        return button
    }()
    
    lazy var inProgressButton: UIButton = {
        let button = UIButton()
        button.setTitle("In Progress", for: .normal)
        button.setTitleColor(UIColor.init(white: 101/255, alpha: 1), for: .normal)
        button.setTitleColor(colorArr[1], for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(handleButtonsActiveState(_:)), for: .touchUpInside)
        button.tag = 1
        return button
    }()
    lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(UIColor.init(white: 101/255, alpha: 1), for: .normal)
        button.setTitleColor(colorArr[2], for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(handleButtonsActiveState(_:)), for: .touchUpInside)
        button.tag = 2
        return button
    }()
    lazy var blockedButton: UIButton = {
        let button = UIButton()
        button.setTitle("Blocked", for: .normal)
        button.setTitleColor(UIColor.init(white: 101/255, alpha: 1), for: .normal)
        button.setTitleColor(colorArr[3], for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(handleButtonsActiveState(_:)), for: .touchUpInside)
        button.tag = 3
        return button
    }()
    lazy var progressCategoryStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [todoButton, inProgressButton, doneButton, blockedButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        return stack
    }()

    lazy var newStepImages: NewStepImages = {
        var stepImages = NewStepImages()
        // handle image picker appearance, through delegate callback!! :>)
        //it is very important to define, what instances of view controllers are
        //notice that I have this optional delegate var
        stepImages.delegate = self
        stepImages.translatesAutoresizingMaskIntoConstraints = false
        return stepImages
    }()

    //scroll view container
    var scrollViewContainer = UIScrollView()
    var contentUIView = UIView()
    
    //name text field
    lazy var stepNameTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.placeholder = "Write Your Step Name Here"
        textField.font = UIFont.boldSystemFont(ofSize: 15)
        textField.translatesAutoresizingMaskIntoConstraints = false
        // Handle the text field's user input through delegate callback.
        textField.delegate = self
        return textField
        
    }()
    
    let lineUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0.63, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stepSaveButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "okButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(saveButtonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let viewControllerTitle: UILabel = {
        let label = UILabel()
        label.text = "New Step"
        label.textColor = UIColor.init(white: 0.7, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //Titles
    let nameTitle: UILabel = {
        let label = UILabel()
        label.text = "Your Step Name"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let categoryTitle: UILabel = {
        let label = UILabel()
        label.text = "Select Category"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let photoTitle: UILabel = {
        let label = UILabel()
        label.text = "Do You Have Some Photos?"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
   
    //define current date
    let createdDate: String = {
        let calendar = Calendar(identifier: .gregorian)
        let ymd = calendar.dateComponents([.year, .month, .day], from: Date())
        guard let year = ymd.year, let month = ymd.month, let day = ymd.day else {return ""}
        let myDate = "\(day)/\(month)/\(year)"// compiler gives me an error type? is it because of guard?
        return myDate
    }()
    
    //wrap to avoid error
    lazy var expandingReminderView: ExpandingReminder = {
        let reminder = ExpandingReminder(
            //expand,close & remove button (3 in 1)
            didTapExpandCompletionHandler: { [weak self] in
                guard let self = self else {return}
    
                let applyButton = self.expandingReminderView.applyReminderButton
                let expandButton = self.expandingReminderView.reminderExpandIcon
    
                //Check what kind of animation should run
                if applyButton.isSelected == false {
                    self.handleAnimate(active: false)
                }else{
                    applyButton.isSelected = false
                }
    
            },
            //apply reminder button
            didTapApplyCompletionHandler: { [weak self] in
                guard let self = self else {return}
    
                self.handleAnimate(active: true)
        })
        return reminder
    }()
    
    //constraints for animation approach
    var maxHeightAnchor: NSLayoutConstraint?
    var minHeightAnchor: NSLayoutConstraint?
    
    //define selected project for adding steps to it
    var projectList: ProjectList? {
        get{
            //Retrieve a single object with unique identifier (projectListIdentifier)
            return realm.object(ofType: ProjectList.self, forPrimaryKey: projectId)
        }
    }
    
    //MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //add scroll containers
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        
        //add all subviews
        [stepNameTextField, lineUIView, stepSaveButton, dismissButton, viewControllerTitle, nameTitle, categoryTitle, progressCategoryStackView, photoTitle, newStepImages, expandingReminderView].forEach {
            contentUIView.addSubview($0)
        }
        
        //constraints configuration
        setupLayout()
        
        
        //Enable the Save button only if the text field has a valid project name.
        updateSaveButtonState()
        
        realm = try! Realm()//create an instance of object
        
    }
    
    //MARK: Methods
    @objc func handleButtonsActiveState(_ sender: UIButton){
        //reset all buttons
        [todoButton, inProgressButton, doneButton, blockedButton].forEach { (button) in
            button.isSelected = false
        }
        //change button selected state
        sender.isSelected = true
        //user progress category selection
        selectedStepProgress = sender.tag
    }
    
    //animate add item menu
    fileprivate func handleAnimate(active: Bool){
    
        guard let minHeight = minHeightAnchor else {return}
        
        
        if minHeight.isActive == true{
            //hide title
            self.expandingReminderView.reminderTitle.alpha = 0
            
            minHeightAnchor?.isActive = false
            maxHeightAnchor?.isActive = true
        }else{
            maxHeightAnchor?.isActive = false
            minHeightAnchor?.isActive = true
        }
        
        //"active" can be true only when apply button is tapped
        if active == false {
            
            //rotate icon 45 degrees
            self.expandingReminderView.reminderExpandIcon.transform = self.expandingReminderView.reminderExpandIcon.transform.rotated(by: CGFloat(Double.pi/4))
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            let grayColor = UIColor.init(white: 214/255, alpha: 1)
            let greenColor = UIColor.init(red: 53/255, green: 204/255, blue: 117/255, alpha: 1)
            let blackColor = UIColor.init(white: 55/255, alpha: 1)
            
            //change color of close button
            if let maxHeight = self.maxHeightAnchor {
                self.expandingReminderView.reminderExpandIcon.tintColor = maxHeight.isActive ? blackColor : .white
                self.expandingReminderView.reminderExpandButton.backgroundColor = maxHeight.isActive ? grayColor : greenColor
            }
            //if apply button is tapped, changes background color to green
            if active == true {
                self.expandingReminderView.backgroundColor = UIColor.init(red: 211/255, green: 250/255, blue: 227/255, alpha: 1)
            }
            //show reminder title
            if minHeight.isActive == true{
                self.expandingReminderView.reminderTitle.alpha = 1
            }
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
        
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //This is my save button action!?
    @objc func saveButtonAction(_ sender: Any){

        //prepare object ready to save
        let stepTemplate: ProjectStep = self.defineStepTemplate()
        
        //--------------------------- this check is not the best solution -----------------------------------
        if #available(iOS 13.0, *) {
            
            if let event = stepTemplate.event{
                
                //TODO: temporary solution with Notification clone
                //Task include reminder
                let reminder = Reminder(timeInterval: nil, date: event.date, location: nil, reminderType: .calendar, repeats: false)
                //check if event includes reminder
                if let eventReminder = event.reminder{
                    //Task is basically an event clone, but uses different property types supported in notifications and not supported in realmSwift :(
                    let task = Task(reminder: reminder, eventDate: eventReminder.eventDate, eventTime: eventReminder.eventTime, startDate: eventReminder.eventDate, name: eventReminder.name, category: eventReminder.category, complete: eventReminder.complete, projectId: eventReminder.projectId, stepId: eventReminder.stepId, id: eventReminder.id)
                    //set notification
                    NotificationManager.shared.scheduleNotification(task: task)
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
        //update existing step
        if self.stepID != nil{
            ProjectListRepository.instance.editStep(step: stepTemplate)
            UserActivitySingleton.shared.createUserActivity(description: "Updated \(stepTemplate.name) step")
        }else{//save new step instance
            //
            try! self.realm!.write ({//here we actually add a new object called projectList
                self.projectList?.projectStep.append(stepTemplate)
            })
            
            UserActivitySingleton.shared.createUserActivity(description: "Added new step: \(stepTemplate.name)")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //prepare object before saving or updating inside DB
    func defineStepTemplate() -> ProjectStep{
        //create project step instance
        let stepTemplate = ProjectStep()
        //if id exist(edit mode), replace it
        if let id = stepID {
            stepTemplate.id = id
        }
        //date
        stepTemplate.date = createdDate
        //name
        stepTemplate.name = stepNameTextField.text ?? ""
        //category
        let categories = ["todo", "inProgress", "done", "blocked"]//switch maybe?
        stepTemplate.category = categories[selectedStepProgress]
        //photos
        for item in newStepImages.photoArray {
            stepTemplate.selectedPhotosArray.append(item)
        }
        //items
        for item in stepItems{
            stepTemplate.itemsArray.append(item)
        }
        
        //check if notification exist inside expanding notification reminder widget
        if let existingNotification = self.expandingReminderView.notification{
            
            //TODO: need real event
            let event = Event()
            event.title = stepTemplate.name
            event.date = existingNotification.eventDate
            
            
            //take some data from step object
            existingNotification.name = stepTemplate.name
            existingNotification.category = "step"
            
            if let projectId = projectId {
                existingNotification.projectId = projectId
            }
            //edit or new, stepTemplate  always has a correct id
            existingNotification.stepId = stepTemplate.id
            
            //finally assign reminder to step
            event.reminder = existingNotification
            stepTemplate.event = event
            
            stepTemplate.reminderEnabled = true
        }
        
        //complete
        if let complete = stepComplete{
            stepTemplate.complete = complete
        }
        
        return stepTemplate
    }
    
    
    //NAME TEXT FIELD
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
        stepSaveButton.isEnabled = false
    }
    
    //MARK: Private Methods
    private func updateSaveButtonState(){
        //Disable the Save button when text field is empty.
        let text = stepNameTextField.text ?? ""
        stepSaveButton.isEnabled = !text.isEmpty
    }
    
    func showImagePicker() {
        // Hide the keyboard.
        stepNameTextField.resignFirstResponder()
        //check for library authorization, that allows PHAsset option using in picker
        // & it is important, because all mechanism is based on PHAsset image address
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined  {
            PHPhotoLibrary.requestAuthorization({status in
                
            })
        }
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func setupLayout(){
        
        view.backgroundColor = .white
        scrollViewContainer.translatesAutoresizingMaskIntoConstraints = false
        contentUIView.translatesAutoresizingMaskIntoConstraints = false
        expandingReminderView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollViewContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollViewContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentUIView.topAnchor.constraint(equalTo: scrollViewContainer.topAnchor).isActive = true
        contentUIView.leftAnchor.constraint(equalTo: scrollViewContainer.leftAnchor).isActive = true
        contentUIView.rightAnchor.constraint(equalTo: scrollViewContainer.rightAnchor).isActive = true
        contentUIView.bottomAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor).isActive = true
        contentUIView.widthAnchor.constraint(equalTo: scrollViewContainer.widthAnchor).isActive = true
        contentUIView.heightAnchor.constraint(equalToConstant: 1500).isActive = true
        
        progressCategoryStackView.leadingAnchor.constraint(equalTo: contentUIView.leadingAnchor, constant: 15).isActive = true
        progressCategoryStackView.trailingAnchor.constraint(equalTo: contentUIView.trailingAnchor, constant: -15).isActive = true
        progressCategoryStackView.topAnchor.constraint(equalTo: categoryTitle.bottomAnchor, constant: 20).isActive = true
        progressCategoryStackView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        
        dismissButton.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 15).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        viewControllerTitle.centerXAnchor.constraint(equalTo: contentUIView.centerXAnchor, constant: 0).isActive = true
        viewControllerTitle.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor, constant: 0).isActive = true
        viewControllerTitle.widthAnchor.constraint(equalToConstant: 120).isActive = true
        viewControllerTitle.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        
        expandingReminderView.bottomAnchor.constraint(equalTo: newStepImages.bottomAnchor, constant: 88).isActive = true
        expandingReminderView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        expandingReminderView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        //height constraints animation
        minHeightAnchor = expandingReminderView.heightAnchor.constraint(equalToConstant: 46)
        maxHeightAnchor = expandingReminderView.heightAnchor.constraint(equalToConstant: 190)
        minHeightAnchor?.isActive = true

        newStepImages.topAnchor.constraint(equalTo: photoTitle.bottomAnchor, constant:  20).isActive = true
        newStepImages.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        newStepImages.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        newStepImages.heightAnchor.constraint(equalToConstant: 146).isActive = true
        
        photoTitle.topAnchor.constraint(equalTo: progressCategoryStackView.bottomAnchor, constant:  20).isActive = true
        photoTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        photoTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        photoTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        categoryTitle.topAnchor.constraint(equalTo: lineUIView.bottomAnchor, constant:  30).isActive = true
        categoryTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        categoryTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        categoryTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        nameTitle.topAnchor.constraint(equalTo: viewControllerTitle.bottomAnchor, constant:  40).isActive = true
        nameTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        nameTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        nameTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        lineUIView.topAnchor.constraint(equalTo: stepNameTextField.bottomAnchor, constant: 3).isActive = true
        lineUIView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        lineUIView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        lineUIView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        stepNameTextField.topAnchor.constraint(equalTo: nameTitle.bottomAnchor, constant: 0).isActive = true
        stepNameTextField.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        stepNameTextField.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        stepNameTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        stepSaveButton.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 15).isActive = true
        stepSaveButton.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        stepSaveButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        stepSaveButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
    }
    
    //?? Am I Need It?
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
               
        if let imgPHAsset = info["UIImagePickerControllerPHAsset"] as? PHAsset{
            //retreave image URL
            imgPHAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions(), completionHandler: { (contentEditingInput, dictInfo) in
                if imgPHAsset.mediaType == .image {
                    if let strURL = contentEditingInput?.fullSizeImageURL?.description {
                        //print("IMAGE URL: ", strURL)
                        assignUrl(url: strURL)
                    }
                }
            })
        }
        
        //a bit trick, because can't append item to array directly, so need to call func
        func assignUrl(url: String){
//            selectedPhotoURLStringArray.append(url)
            //add new item
            newStepImages.photoArray.append(url)
            //reload when picker closes
            newStepImages.imageCollectionView.reloadData()
        }
         //Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
}
