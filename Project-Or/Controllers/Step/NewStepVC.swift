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

//MARK: OK
class NewStepViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NewStepImagesDelegate {
    
    //MARK: Properties
    //photo library accesss permission status
    var photoLibraryStatus = PHPhotoLibrary.authorizationStatus()
    //push to view controller, reloadViews , perform configurations
    weak var delegate: EditViewControllerDelegate?
    
    var projectId: String?

    var stepID: String? {
        didSet{
            if let id = self.stepID{
                guard let projectStep = ProjectListRepository.instance.getProjectStep(id: id),
                      let section = projectStep.section else {return}
                self.projectStep = projectStep
                self.stepSection = section
                self.comment = projectStep.comment
                self.sectionButton.setTitle("    \(section.name)", for: .normal)
                self.descriptionTextView.text = projectStep.comment
            }
        }
    }
    
    var projectStep: ProjectStep?
    //step completion status
    var stepComplete: Bool?
    // list of items in step
    var stepItems = List<StepItem>()
    // step progress category
    var selectedStepProgress: Int = 0
    //this property uses for building a ProjectWayViewController (required)
    var stepSection: StepWaySection? {
        didSet{
            sectionButton.titleLabel?.textColor = .black
            self.updateSaveButtonState()
        }
    }
    
    var comment = "" {
        didSet{
                let textRect = NSString(string: self.comment).boundingRect(with: CGSize(width: view.frame.width - 30, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)], context: nil)
                
                let commentHeight = textRect.height + 20
            
            if commentHeight > 126 {
                descriptionTextHeightAnchor.constant = commentHeight
            }
        }
    }
    
    var realm: Realm!

    let colorArr = [
        UIColor.init(red: 56/255, green: 136/255, blue: 255/255, alpha: 1),//blue color
        UIColor.init(red: 248/255, green: 182/255, blue: 24/255, alpha: 1),//orange color
        UIColor.init(red: 17/255, green: 201/255, blue: 109/255, alpha: 1),//green color
        UIColor.init(red: 236/255, green: 65/255, blue: 91/255, alpha: 1)//red color
    ]
    
    lazy var todoButton: UIButton = {
        let button = UIButton()
        button.setTitle("To do", for: .normal)
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
        stepImages.delegate = self
        stepImages.translatesAutoresizingMaskIntoConstraints = false
        return stepImages
    }()

    var scrollViewContainer: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    var contentUIView = UIView()
    
    //name text field
    lazy var stepNameTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.placeholder = "Write Your Step Name Here"
        textField.font = UIFont.boldSystemFont(ofSize: 15)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.addTarget(self, action:  #selector(textFieldEditing), for: .editingChanged)
        return textField
        
    }()
    
    let lineUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0.63, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(named: "saveTo"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
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
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let nameTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        let mutableString = NSMutableAttributedString(string: "Your Step Name *", attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.mainPink, range: NSRange(location: 15, length: 1))
        label.attributedText = mutableString
        return label
    }()
    
    let sectionTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        let mutableString = NSMutableAttributedString(string: "Select Section *", attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.mainPink, range: NSRange(location: 15, length: 1))
        label.attributedText = mutableString
        return label
    }()
    
    lazy var sectionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(selectSection), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 5
        button.setTitle("   Select Section for Your Step", for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.backgroundColor = UIColor.init(white: 237/255, alpha: 1)
        button.layer.masksToBounds = true
        return button
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
        label.text = "Add an Image to Your Step"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
   
    //define current date
    let createdDate: String = {
        let calendar = Calendar(identifier: .gregorian)
        let ymd = calendar.dateComponents([.year, .month, .day], from: Date())
        guard let year = ymd.year, let month = ymd.month, let day = ymd.day else {return ""}
        let myDate = "\(day)/\(month)/\(year)"
        return myDate
    }()
    
    //wrap fixes error
    lazy var expandingReminderView: ExpandingReminder = {
        let reminder = ExpandingReminder(
            //expand,close & remove button (3 in 1)
            didTapExpandCompletionHandler: { [weak self] in
                guard let self = self else {return}
    
                let applyButton = self.expandingReminderView.applyReminderButton
                let expandButton = self.expandingReminderView.reminderExpandIcon
    
                //Check what kind of animation should use
                if applyButton.isSelected == false {
                    self.handleAnimate(active: false)
                }else{
                    //if apply button is not selected -> remove notification action
                    applyButton.isSelected = false
                    if let unwStep = self.projectStep, let stepEvent = unwStep.event{
                        ProjectListRepository.instance.deleteEvent(event: stepEvent)
                    }

                }
    
            },
            //apply reminder button
            didTapApplyCompletionHandler: { [weak self] in
                guard let self = self else {return}
    
                self.handleAnimate(active: true)
        },
            presentAlertView: {[weak self] in
                guard let self = self else {return}
                
                let ac = UIAlertController(title: "Notifications are Disabled", message: "To turn on notifications, please go to Settings > Notifications > Projector", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        )
        return reminder
    }()
    
    let descriptionTitle: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 6
        textView.backgroundColor = UIColor.init(white: 239/255, alpha: 1)
        textView.font = UIFont.boldSystemFont(ofSize: 14)
        textView.textColor = UIColor.init(displayP3Red: 112/255, green: 112/255, blue: 112/255, alpha: 1)
        return textView
    }()
    
    //constraints for animation approach
    var maxHeightAnchor: NSLayoutConstraint?
    var minHeightAnchor: NSLayoutConstraint?
    
    var descriptionTextHeightAnchor: NSLayoutConstraint!
    var contentViewHeightAnchor: NSLayoutConstraint!
    var scrollViewTopAnchor: NSLayoutConstraint!
    //textView animation properties, when keyboard pop-up
    var additionalHeight: CGFloat = 0
    var totalContentHeight: CGFloat = 0
    
    //define a selected project to add steps to it
    var projectList: ProjectList? {
        get{
            return realm.object(ofType: ProjectList.self, forPrimaryKey: projectId)
        }
    }
    
    //MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //request permission, to send notifications
        if #available(iOS 13.0, *) {
            NotificationManager.shared.requestAuthorization { granted in
                if granted {
                    //showNotificationSettingsUI = true
                }
            }
        } else {
            // Fallback on earlier versions
        }
    
        //add scroll containers
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        
        [stepNameTextField, lineUIView, saveButton, dismissButton, viewControllerTitle, nameTitle,sectionTitle, sectionButton, categoryTitle, progressCategoryStackView, photoTitle, newStepImages, expandingReminderView, descriptionTitle , descriptionTextView].forEach {
            contentUIView.addSubview($0)
        }
        
        //constraints configuration
        setupLayout()
        //Enable the Save button only if the text field has a valid project name.
        updateSaveButtonState()
        
        realm = try! Realm()
        //keyboard configurations
        setupKeyboardObservers()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        
        
        let subviewsHeightSum = (contentUIView.subviews.map { $0.frame.height }).reduce(0, +)
        //calls two times, and the first is 0
        if subviewsHeightSum > 0 {
            
            totalContentHeight = subviewsHeightSum + 103
            additionalHeight = totalContentHeight - self.view.frame.height
            contentViewHeightAnchor.constant = additionalHeight > 0 ? subviewsHeightSum + (additionalHeight * 2) : totalContentHeight
        }
        updateSaveButtonState()
    }
    
    //fix memory leak issue
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //prevent multiple keyboard observers
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Methods
    @objc func handleButtonsActiveState(_ sender: UIButton){
        //reset all buttons
        [todoButton, inProgressButton, doneButton, blockedButton].forEach { (button) in
            button.isSelected = false
        }
        sender.isSelected = true
        //user progress category selection
        selectedStepProgress = sender.tag
    }
     
    @objc private func selectSection(){
        guard let projectId = projectId else {return}
        let newStepSectionsList = NewStepSectionsList(projectId: projectId)
        newStepSectionsList.parentViewControllerExtension = self
        newStepSectionsList.modalPresentationStyle = .fullScreen
        newStepSectionsList.projectId = projectId
        present(newStepSectionsList, animated: true)
    }
    
    private func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification){
        //only description requires push animation
        guard descriptionTextView.isFirstResponder == true else {return}
        if let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            scrollViewTopAnchor.constant = 0
            UIView.animate(withDuration: keyboardDuration, delay: 0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification){
        //only description requires push animation
        guard descriptionTextView.isFirstResponder == true else {return}
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        if let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            if let keyboardRectangle = keyboardFrame?.cgRectValue {
                let extraHeightBit = additionalHeight * 2
                scrollViewTopAnchor.constant = additionalHeight > 0 ? -(keyboardRectangle.height) - extraHeightBit : -(keyboardRectangle.height)
                UIView.animate(withDuration: keyboardDuration, delay: 0) {
                    self.view.layoutIfNeeded()
                }
            }
        }
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
            //rotate icon to 45 degrees
            self.expandingReminderView.reminderExpandIcon.transform = self.expandingReminderView.reminderExpandIcon.transform.rotated(by: CGFloat(Double.pi/4))
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            let grayColor = UIColor.init(white: 214/255, alpha: 1)
            let greenColor = UIColor.init(red: 53/255, green: 204/255, blue: 117/255, alpha: 1)
            let blackColor = UIColor.init(white: 55/255, alpha: 1)
            
            //change the color of the close button
            if let maxHeight = self.maxHeightAnchor {
                self.expandingReminderView.reminderExpandIcon.tintColor = maxHeight.isActive ? blackColor : .white
                self.expandingReminderView.reminderExpandButton.backgroundColor = maxHeight.isActive ? grayColor : greenColor
            }
            //if the apply button is selected, change the background color to green
            if active == true {
                self.expandingReminderView.backgroundColor = UIColor.init(red: 211/255, green: 250/255, blue: 227/255, alpha: 1)
            }
            //show reminders title
            if minHeight.isActive == true{
                self.expandingReminderView.reminderTitle.alpha = 1
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonAction(_ sender: Any){
        
        if self.stepSection == nil {
            sectionButton.titleLabel?.textColor = .red
            return
        }
        
        let stepTemplate: ProjectStep = self.defineStepTemplate()
        
        if #available(iOS 13.0, *) {
            
            if let existingNotification = self.expandingReminderView.notification {
                stepTemplate.event = defineStepEvent(stepTemplate: stepTemplate, notification: existingNotification)
            }

            if let event = stepTemplate.event{
                
                let reminder = Reminder(timeInterval: nil, date: event.date, location: nil, reminderType: .calendar, repeats: false)
                if let eventReminder = event.reminder{
                    let task = Task(reminder: reminder, eventDate: eventReminder.eventDate, eventTime: eventReminder.eventTime, startDate: eventReminder.eventDate, name: eventReminder.name, category: eventReminder.category, complete: eventReminder.complete, projectId: eventReminder.projectId, stepId: eventReminder.stepId, id: eventReminder.id)
                    
                    NotificationManager.shared.scheduleNotification(task: task)
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
        if self.stepID != nil{
            ProjectListRepository.instance.editStep(step: stepTemplate)
            UserActivitySingleton.shared.createUserActivity(description: "Updated \(stepTemplate.name) step")
        }else{
            try! self.realm!.write ({
                self.projectList?.projectStep.append(stepTemplate)
            })
            UserActivitySingleton.shared.createUserActivity(description: "Added new step: \(stepTemplate.name)")
        }
        dismiss(animated: true, completion: nil)
    }
    
    //prepare object before save or update
    func defineStepTemplate() -> ProjectStep{
        let stepTemplate = ProjectStep()
        //if id exist(edit mode), replace it
        if let id = stepID {
            stepTemplate.id = id
            //update step displayed status
            if let step = projectStep{
                stepTemplate.displayed = step.displayed
            }
        }
        stepTemplate.date = createdDate
        stepTemplate.name = stepNameTextField.text ?? ""
        stepTemplate.comment = self.descriptionTextView.text ?? ""
        //section uses for ProjectWayViewController configuration
        stepTemplate.section = stepSection
        //categories
        let categories = ["todo", "inProgress", "done", "blocked"]
        stepTemplate.category = categories[selectedStepProgress]
        //photos
        for item in newStepImages.photoArray {
            stepTemplate.selectedPhotosArray.append(item)
        }
        //items
        stepTemplate.stepItemsList.append(objectsIn: stepItems)
        //complete
        if let complete = stepComplete{
            stepTemplate.complete = complete
        }
        return stepTemplate
    }
    
    fileprivate func defineStepEvent(stepTemplate: ProjectStep, notification: Notification) -> Event{
        let event = Event()
        
        event.title = stepTemplate.name
        //add image if exist
        if let img = stepTemplate.selectedPhotosArray.first{
            event.picture = img
        }
        event.date = notification.eventDate
        event.startTime = notification.eventDate
        event.category = "projectStep"
        let components = Calendar.current.dateComponents([.hour, .minute], from: notification.eventDate)
        //Because expanding reminder don't have an end time, anticipate 1 hour for it by default
        if let hour = components.hour, let minute = components.minute {
            //using current date and picker time for date formatting
            event.endTime = Calendar.current.date(bySettingHour: hour + 1, minute: minute, second: 0, of: notification.eventDate)
        }
        
        notification.name = stepTemplate.name
        notification.category = "step"
        
        if let projectId = projectId {
            notification.projectId = projectId
        }
        //edit or new, stepTemplate should always has a correct id
        notification.stepId = stepTemplate.id
        //assign reminder to event
        event.reminder = notification
        return event
    }
    
    private func updateSaveButtonState(){
        guard let text = stepNameTextField.text, let _ = stepSection else {return}
        saveButton.isEnabled = !text.isEmpty
    }
    
    //MARK: Text Field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldEditing(_ textfield: UITextField) {
        updateSaveButtonState()
    }
    
    //MARK: Picker
    func showImagePicker() {

        stepNameTextField.resignFirstResponder()
        
        //check for library authorization, that allows PHAsset option using in picker
        // & it is important, because all mechanism is based on PHAsset image address
        switch self.photoLibraryStatus {
        case .authorized:
            
            //lets a user pick media from their photo library.
            let imagePickerController = UIImagePickerController()
            
            // Only allow photos to be picked, not taken
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = true
            
            // Make sure ViewController is notified when the user picks an image
            imagePickerController.delegate = self
            
            self.present(imagePickerController, animated: true, completion: nil)
            
        case .denied:
            showPermissionAlert()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({status in
                self.photoLibraryStatus = status
            })
        case .restricted:
            print("restricted")
        case .limited:
            print("limited")
        @unknown default:
            print("unknown case!")
        }
    }
    
    private func showPermissionAlert(){
        let ac = UIAlertController(title: "Access to Photo Library is Denied", message: "To turn on access to photo library, please go to Settings > Notifications > Projector", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }
    
    private func setupLayout(){
        
        view.backgroundColor = .white
        
        contentUIView.translatesAutoresizingMaskIntoConstraints = false
        expandingReminderView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollViewTopAnchor = scrollViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        scrollViewTopAnchor.isActive = true
        scrollViewContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollViewContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentUIView.topAnchor.constraint(equalTo: scrollViewContainer.topAnchor).isActive = true
        contentUIView.leftAnchor.constraint(equalTo: scrollViewContainer.leftAnchor).isActive = true
        contentUIView.rightAnchor.constraint(equalTo: scrollViewContainer.rightAnchor).isActive = true
        contentUIView.bottomAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor).isActive = true
        contentUIView.widthAnchor.constraint(equalTo: scrollViewContainer.widthAnchor).isActive = true
        contentViewHeightAnchor = contentUIView.heightAnchor.constraint(equalToConstant: 400)
        contentViewHeightAnchor.isActive = true
        
                
        progressCategoryStackView.leadingAnchor.constraint(equalTo: contentUIView.leadingAnchor, constant: 15).isActive = true
        progressCategoryStackView.trailingAnchor.constraint(equalTo: contentUIView.trailingAnchor, constant: -15).isActive = true
        progressCategoryStackView.topAnchor.constraint(equalTo: categoryTitle.bottomAnchor, constant: 20).isActive = true
        progressCategoryStackView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        
        dismissButton.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 15).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        viewControllerTitle.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 0).isActive = true
        viewControllerTitle.centerXAnchor.constraint(equalTo: contentUIView.centerXAnchor).isActive = true
        viewControllerTitle.widthAnchor.constraint(equalTo: contentUIView.widthAnchor).isActive = true
        viewControllerTitle.bottomAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 15).isActive = true
        
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
        
        categoryTitle.topAnchor.constraint(equalTo: sectionButton.bottomAnchor, constant:  20).isActive = true
        categoryTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        categoryTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        categoryTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        sectionTitle.topAnchor.constraint(equalTo: lineUIView.bottomAnchor, constant: 30).isActive = true
        sectionTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        sectionTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        sectionTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        sectionButton.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: 12).isActive = true
        sectionButton.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        sectionButton.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        sectionButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        nameTitle.topAnchor.constraint(equalTo: viewControllerTitle.bottomAnchor, constant:  20).isActive = true
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
        
        saveButton.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 15).isActive = true
        saveButton.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 85).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        descriptionTitle.topAnchor.constraint(equalTo: expandingReminderView.bottomAnchor, constant:  20).isActive = true
        descriptionTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        descriptionTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        descriptionTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        descriptionTextView.topAnchor.constraint(equalTo: descriptionTitle.bottomAnchor, constant: 12).isActive = true
        descriptionTextView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        descriptionTextView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        descriptionTextHeightAnchor = descriptionTextView.heightAnchor.constraint(equalToConstant: 126)
        descriptionTextHeightAnchor.isActive = true
        
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
               
        if let imgPHAsset = info["UIImagePickerControllerPHAsset"] as? PHAsset{
            //retreave image URL
            imgPHAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions(), completionHandler: { (contentEditingInput, dictInfo) in
                if imgPHAsset.mediaType == .image {
                    if let strURL = contentEditingInput?.fullSizeImageURL?.description {
                        assignUrl(url: strURL)
                    }
                }
            })
        }
        
        func assignUrl(url: String){
            newStepImages.photoArray.append(url)
            newStepImages.imageCollectionView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
    
}
