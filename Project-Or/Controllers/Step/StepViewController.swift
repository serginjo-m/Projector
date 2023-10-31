//
//  StepVC.swift
//  Projector
//
//  Created by Serginjo Melnik on 21.04.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

//MARK: OK

class StepViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    
    //MARK: Properties
    let cellIdentifier = "stepTableViewCell"
    var startingFrame: CGRect?
    var zoomBackgroundView: UIView?
    var startingView: UIView?
    var startingImageFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIView?
    
    lazy var stepTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(StepTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    //container for all items on the page
    lazy var scrollViewContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    var contentUIView = UIView()
    
    var projectStep: ProjectStep? {
        get{
            //Retrieve a single object with unique identifier (stepID)
            return ProjectListRepository.instance.getProjectStep(id: stepID)
        }
        set{
            //update
        }
    }
    var projectId: String?
    //step id passed by detail VC
    var stepID: String
    
    //step photos collection view
    lazy var stepImagesCV = StepImagesCollectionView(parentVC: self, step: projectStep ?? ProjectStep(), frame: CGRect.zero)
    //step values
    let stepComment: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.init(white: 0.3, alpha: 1)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.isHidden = true
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        
        return button
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(red: 104/255, green: 104/255, blue: 104/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .left
        return label
    }()
    
    let circleImage = UIImageView(image: #imageLiteral(resourceName: "redCircle"))
    
    var stepNameTitle: UILabel = {
        let label = UILabel()
        label.text = "Your Step Name"
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    lazy var stepToEventButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(addStepToCalendarEvent(button:)), for: .touchUpInside)
        button.setTitle("Calendar", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(UIColor.init(red: 104/255, green: 104/255, blue: 104/255, alpha: 1), for: .normal)
        button.setTitleColor(UIColor.init(red: 42/255, green: 192/255, blue: 45/255, alpha: 1), for: .selected)
        return button
    }()
    
    lazy var editStepButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(editButtonAction(_:)), for: .touchUpInside)
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(UIColor.init(red: 104/255, green: 104/255, blue: 104/255, alpha: 1), for: .normal)
        button.setTitleColor(UIColor.init(red: 42/255, green: 192/255, blue: 45/255, alpha: 1), for: .selected)
        return button
    }()
    
    lazy var removeStepButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(deleteStep(button:)), for: .touchUpInside)
        button.setTitle("Remove", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(UIColor.init(red: 104/255, green: 104/255, blue: 104/255, alpha: 1), for: .normal)
        button.setTitleColor(UIColor.init(red: 42/255, green: 192/255, blue: 45/255, alpha: 1), for: .selected)
        return button
    }()
    
    lazy var reminderStepButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(setReminder(button:)), for: .touchUpInside)
        button.setTitle("Reminder", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(UIColor.init(red: 104/255, green: 104/255, blue: 104/255, alpha: 1), for: .normal)
        button.setTitleColor(UIColor.init(red: 245/255, green: 166/255, blue: 35/255, alpha: 1), for: .selected)
        return button
    }()
    
    var stepItemsTitle: UILabel = {
        let label = UILabel()
        label.text = "Items Todo"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    let reminderViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 11
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.init(white: 55/255, alpha: 1)
        view.isHidden = true
        return view
    }()
    
    let reminderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.init(white: 242/255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "Reminder is not set"
        return label
    }()
    
    lazy var dismissReminderButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dismissReminder), for: .touchUpInside)
        let originalImage = UIImage(named: "close")
        let tintedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = UIColor.init(white: 242/255, alpha: 1)
        return button
    }()

    var stepCommentHeightConstraint: NSLayoutConstraint!
    var stepCommentTopAnchorHigherConstraint: NSLayoutConstraint!
    var stepCommentTopAnchorLowerConstraint: NSLayoutConstraint!
    var stepItemsTitleTopAnchorHigherConstraint: NSLayoutConstraint!
    var stepItemsTitleTopAnchorMiddleConstraint: NSLayoutConstraint!
    var stepItemsTitleTopAnchorLowerConstraint: NSLayoutConstraint!
    var stepNameTitleHeightAnchor: NSLayoutConstraint!
    
    var contentHeightAnchor: NSLayoutConstraint!
    
    //MARK: Initialization
    //Good way to init view controller
    //Good way to init viewController
    init(stepId: String, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.stepID = stepId
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        //scroll containers
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        [dismissButton, stepImagesCV, categoryLabel, circleImage, stepToEventButton,editStepButton, removeStepButton, reminderStepButton, stepComment, stepNameTitle, stepItemsTitle, stepTableView, reminderViewContainer].forEach {
            contentUIView.addSubview($0)
        }
        reminderViewContainer.addSubview(reminderLabel)
        reminderViewContainer.addSubview(dismissReminderButton)
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //configure view controller
        performPageConfigurations()
    }
    
    override func viewDidLayoutSubviews() {
        updateContentHeight()
    }
    
    //MARK: Methods
    private func updateContentHeight(){
        
        guard let step = projectStep else {return}
        let imagesCollectionViewHeight: CGFloat = stepImagesCV.isHidden == true ? 0 : 174
        
        let totalContentHeight = stepNameTitle.frame.height + stepCommentHeightConstraint.constant + stepTableView.contentSize.height + 193 + imagesCollectionViewHeight
        //update content height first
        if stepItemsTitle.frame.origin.y > 0 {
            stepImagesCV.stepImagesCollectionView.reloadData()
            contentHeightAnchor.constant = totalContentHeight
        }

        if step.comment.isEmpty == true {
            if step.selectedPhotosArray.count == 0 {
                //under buttons
                stepItemsTitleTopAnchorMiddleConstraint.isActive = false
                stepItemsTitleTopAnchorLowerConstraint.isActive = false
                stepItemsTitleTopAnchorHigherConstraint.isActive = true
            }else{
                //under photos
                stepItemsTitleTopAnchorHigherConstraint.isActive = false
                stepItemsTitleTopAnchorLowerConstraint.isActive = false
                stepItemsTitleTopAnchorMiddleConstraint.isActive = true
            }
        }else{//under comment
            stepItemsTitleTopAnchorHigherConstraint.isActive = false
            stepItemsTitleTopAnchorMiddleConstraint.isActive = false
            stepItemsTitleTopAnchorLowerConstraint.constant = -(stepTableView.contentSize.height  + 40)
            stepItemsTitleTopAnchorLowerConstraint.isActive = true
        }
    }
    
    private func performPageConfigurations(){
        projectStep = ProjectListRepository.instance.getProjectStep(id: stepID)
        
        guard let step = projectStep else {return}
        
        categoryLabel.text = step.category
        stepNameTitle.text = step.name
        stepComment.text = step.comment
        stepToEventButton.isSelected = step.complete
        stepComment.isHidden = step.comment.isEmpty == true ? true : false
        stepImagesCV.isHidden = step.selectedPhotosArray.count == 0 ? true : false
        
        if let event = step.event{
            if event.reminder != nil{
                reminderStepButton.isSelected = true
            }
        }else{
            reminderStepButton.isSelected = false
        }
        //hide if no data available
        if step.selectedPhotosArray.count == 0 {
            stepImagesCV.isHidden = true
        }else{
            stepImagesCV.step = step
            stepImagesCV.stepImagesCollectionView.reloadData()
            stepImagesCV.isHidden = false
        }
        
        //constraints and visibility of some views, that needs to be reloaded after each update
        updateDynamicConstraints()
        self.stepTableView.reloadData()
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //Add to Calendar Event
    @objc func addStepToCalendarEvent(button: UIButton) {

        hideReminderView()
        
        guard let step = projectStep else {return}
        //create new event view controller based on selected step
        let newEventViewController = NewEventViewController()
        newEventViewController.modalTransitionStyle = .coverVertical
        newEventViewController.modalPresentationStyle = .fullScreen
        //step identifier access data base object
        newEventViewController.stepId = stepID
        if let projId = projectId {
            newEventViewController.projectId = projId
        }
        //if step has images, define event image
        if step.selectedPhotosArray.count > 0 {
            //use UIImageView extension function that retreaves image from URL
            newEventViewController.imageHolderView.retreaveImageUsingURLString(myUrl: step.selectedPhotosArray[0])
        }
        newEventViewController.nameTextField.text = step.name
        newEventViewController.descriptionTextView.text = step.comment
        navigationController?.present(newEventViewController, animated: true, completion: nil)
    }
    
    @objc func deleteStep( button: UIButton){
        //hide reminder if it open
        hideReminderView()
        
        let alertVC = UIAlertController(title: "Delete Step?", message: "Are You sure want delete this step?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
            
            guard let step = self.projectStep, let projectId = self.projectId else {return}
            //check if step contains a reminder
            if step.reminderEnabled == true{
                if #available(iOS 13.0, *) {
                    
                    if let event = step.event {
                        if let notification = event.reminder{
                            //removes push notification from the system
                            NotificationManager.shared.removeScheduledNotification(taskId: notification.id)
                            //remove Notification object( it also removes from Event )
                            ProjectListRepository.instance.deleteNotificationNote(note: notification)
                        }
                        //remove event
                        ProjectListRepository.instance.deleteEvent(event: event)
                    }
                    
                } else {
                    // Fallback on earlier versions
                }
            }
            
            UserActivitySingleton.shared.createUserActivity(description: "Deleted \(step.name)")
            
            var project: ProjectList? {
                get{
                    return ProjectListRepository.instance.getProjectList(id: projectId)
                }
            }
            
            if let proj = project {
                for (index, value) in proj.projectStep.enumerated(){
                    if value.id == self.stepID{
                        //delete step in data base
                        ProjectListRepository.instance.deleteStepFromProject(list: proj, stepAtIndex: index)
                        ProjectListRepository.instance.deleteStep(step: value)
                    }
                }
            }
            
            self.navigationController?.popViewController(animated: true)
        })
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(deleteAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    @objc func setReminder(button: UIButton){
        if let step = self.projectStep, let event = step.event, let notification = event.reminder  {
            let formatter = DateFormatter()
            
            formatter.dateFormat = "dd MMM yyyy HH:mm"

            let myString = formatter.string(from: notification.eventDate) // string purpose I add here
            
            if notification.eventDate < Date(){
                
                reminderLabel.text = "Expired: " + myString
            }else{
                reminderLabel.text = "Upcomming: " + myString
            }
            
        }
        
        hideReminderView(button: true)
    }
    
    @objc func dismissReminder(){
        hideReminderView()
    }
    
    func hideReminderView(button: Bool? = nil){
        
        if let _ = button {
            
                reminderViewContainer.isHidden = !reminderViewContainer.isHidden
            
        }else{
            reminderViewContainer.isHidden = true
        }
    }
    
    //EDIT ACTION
    @objc func editButtonAction(_ sender: Any){
        hideReminderView()
        
        guard let step = projectStep else {return}
        
        let editStepViewController = NewStepViewController()
        editStepViewController.modalTransitionStyle = .coverVertical
        editStepViewController.modalPresentationStyle = .fullScreen
        editStepViewController.stepID = stepID
        if let projId = projectId {
            editStepViewController.projectId = projId
        }
        editStepViewController.projectId = projectId
        editStepViewController.viewControllerTitle.text = "Edit Step"
        editStepViewController.stepNameTextField.text = step.name
        for item in step.selectedPhotosArray{
            editStepViewController.newStepImages.photoArray.append(item)
        }
        editStepViewController.stepItems.append(objectsIn: step.stepItemsList)
        editStepViewController.stepComplete = step.complete
        if let event = step.event{
            if let reminder = event.reminder{
                //*reminder button configured from picker, but not from notification object
                editStepViewController.expandingReminderView.timePicker.date = reminder.eventDate
                editStepViewController.expandingReminderView.datePicker.date = reminder.eventDate
                editStepViewController.expandingReminderView.notification = reminder
            }
        }
        self.present(editStepViewController, animated: true, completion: nil)
    }
    
    //MARK: Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let num = projectStep?.stepItemsList.count  {
            return num
        }
        return 0
    }
    
    //cell configuration
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as? StepTableViewCell else {
            fatalError( "The dequeued cell is not an instance of ProjectTableViewCell." )
        }
        
        if let step = projectStep {
            let template = step.stepItemsList[indexPath.row]
            cell.template = template
        }
        
        cell.stepViewController = self
        return cell
    }
    
    
    //MARK: Scroll View
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //hide reminder if it's open
        hideReminderView()
    }
    
    
    //MARK: Constraints
    //perforn all positioning configurations
    private func setupLayout(){
        
        [dismissButton, stepImagesCV, contentUIView, scrollViewContainer, categoryLabel, circleImage, stepToEventButton, editStepButton, removeStepButton, stepNameTitle, stepItemsTitle].forEach{$0.translatesAutoresizingMaskIntoConstraints = false}
        
        scrollViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollViewContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollViewContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentUIView.topAnchor.constraint(equalTo: scrollViewContainer.topAnchor).isActive = true
        contentUIView.leftAnchor.constraint(equalTo: scrollViewContainer.leftAnchor).isActive = true
        contentUIView.rightAnchor.constraint(equalTo: scrollViewContainer.rightAnchor).isActive = true
        contentUIView.bottomAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor).isActive = true
        contentUIView.widthAnchor.constraint(equalTo: scrollViewContainer.widthAnchor).isActive = true
        
        contentHeightAnchor = contentUIView.heightAnchor.constraint(equalToConstant: 1500)
        contentHeightAnchor.isActive = true
        
        dismissButton.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 15).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        categoryLabel.removeConstraints(categoryLabel.constraints)
        categoryLabel.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor, constant: 0).isActive = true
        categoryLabel.centerXAnchor.constraint(equalTo: contentUIView.centerXAnchor, constant: 0).isActive = true
        categoryLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        circleImage.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor, constant: 0).isActive = true
        circleImage.rightAnchor.constraint(equalTo: categoryLabel.leftAnchor, constant: -6).isActive = true
        circleImage.widthAnchor.constraint(equalToConstant: 8).isActive = true
        circleImage.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        stepNameTitle.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 22).isActive = true
        stepNameTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        stepNameTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        stepNameTitleHeightAnchor = stepNameTitle.heightAnchor.constraint(equalToConstant: 20)
        stepNameTitleHeightAnchor.isActive = true
        
        stepToEventButton.topAnchor.constraint(equalTo: stepNameTitle.bottomAnchor, constant: 18).isActive = true
        stepToEventButton.leftAnchor.constraint(equalTo: dismissButton.leftAnchor, constant: 0).isActive = true
        stepToEventButton.widthAnchor.constraint(equalToConstant: 72).isActive = true
        stepToEventButton.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        editStepButton.centerYAnchor.constraint(equalTo: stepToEventButton.centerYAnchor, constant: 0).isActive = true
        editStepButton.leftAnchor.constraint(equalTo: stepToEventButton.rightAnchor, constant: 24).isActive = true
        editStepButton.widthAnchor.constraint(equalToConstant: 31).isActive = true
        editStepButton.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        removeStepButton.centerYAnchor.constraint(equalTo: stepToEventButton.centerYAnchor, constant: 0).isActive = true
        removeStepButton.leftAnchor.constraint(equalTo: editStepButton.rightAnchor, constant: 24).isActive = true
        removeStepButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        removeStepButton.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        reminderStepButton.centerYAnchor.constraint(equalTo: stepToEventButton.centerYAnchor, constant: 0).isActive = true
        reminderStepButton.leftAnchor.constraint(equalTo: removeStepButton.rightAnchor, constant: 24).isActive = true
        reminderStepButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        reminderStepButton.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        reminderViewContainer.topAnchor.constraint(equalTo: reminderStepButton.bottomAnchor, constant: 10).isActive = true
        reminderViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        reminderViewContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        reminderViewContainer.widthAnchor.constraint(equalToConstant: 370).isActive = true
        
        reminderLabel.leadingAnchor.constraint(equalTo: reminderViewContainer.leadingAnchor).isActive = true
        reminderLabel.trailingAnchor.constraint(equalTo: reminderViewContainer.trailingAnchor, constant: -30).isActive = true
        reminderLabel.heightAnchor.constraint(equalToConstant: 17).isActive = true
        reminderLabel.centerYAnchor.constraint(equalTo: reminderViewContainer.centerYAnchor).isActive = true
        
        dismissReminderButton.widthAnchor.constraint(equalToConstant: 21).isActive = true
        dismissReminderButton.heightAnchor.constraint(equalToConstant: 21).isActive = true
        dismissReminderButton.centerYAnchor.constraint(equalTo: reminderViewContainer.centerYAnchor).isActive = true
        dismissReminderButton.trailingAnchor.constraint(equalTo: reminderViewContainer.trailingAnchor, constant: -15).isActive = true
        
        stepImagesCV.topAnchor.constraint(equalTo: stepToEventButton.bottomAnchor, constant: 30).isActive = true
        stepImagesCV.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  16).isActive = true
        stepImagesCV.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: 0).isActive = true
        stepImagesCV.heightAnchor.constraint(equalToConstant: 144).isActive = true
        
        stepCommentHeightConstraint = stepComment.heightAnchor.constraint(equalToConstant: 20)
        stepCommentHeightConstraint.isActive = true
        stepComment.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        stepComment.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: 0).isActive = true
        
        
        stepCommentTopAnchorHigherConstraint = stepComment.topAnchor.constraint(equalTo: stepToEventButton.bottomAnchor, constant: 20)
        stepCommentTopAnchorLowerConstraint = stepComment.topAnchor.constraint(equalTo: stepImagesCV.bottomAnchor, constant: 30)
        
        
        stepItemsTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        stepItemsTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        stepItemsTitle.heightAnchor.constraint(equalToConstant: 25).isActive = true
        stepItemsTitleTopAnchorHigherConstraint = stepItemsTitle.topAnchor.constraint(equalTo: stepToEventButton.bottomAnchor, constant:  25)
        stepItemsTitleTopAnchorMiddleConstraint = stepItemsTitle.topAnchor.constraint(equalTo: stepImagesCV.bottomAnchor, constant: 30)
        stepItemsTitleTopAnchorLowerConstraint = stepItemsTitle.topAnchor.constraint(equalTo: contentUIView.bottomAnchor, constant: -20)
        
        stepTableView.topAnchor.constraint(equalTo: stepItemsTitle.bottomAnchor, constant:  9).isActive = true
        stepTableView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        stepTableView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        stepTableView.bottomAnchor.constraint(equalTo: contentUIView.bottomAnchor, constant: 0).isActive = true
    }
    
    func updateDynamicConstraints(){
        //diff size string need width calculation for constraints
        guard let categoryLabelString = categoryLabel.text, let step = projectStep else {return}
            
       //calculates precise label width
        let categoryLabelSize = ceil(categoryLabelString.size(withAttributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]).width)
        categoryLabel.widthAnchor.constraint(equalToConstant: categoryLabelSize).isActive = true
        
        //logic that makes stepNamelabel size correct
        let rect = NSString(string: step.name).boundingRect(with: CGSize(width: view.frame.width - 30, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)], context: nil)
        
        stepNameTitleHeightAnchor.constant = rect.height + 20
        
        let commentRect = NSString(string: step.comment).boundingRect(with: CGSize(width: view.frame.width - 15, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)], context: nil)
        
        stepCommentHeightConstraint.constant = commentRect.height + 10

        if step.selectedPhotosArray.count == 0 {//if no photos, place it under buttons
            stepCommentTopAnchorLowerConstraint.isActive = false
            stepCommentTopAnchorHigherConstraint.isActive = true
        }else{//if it contains photos place it under photos
            stepCommentTopAnchorHigherConstraint.isActive = false
            stepCommentTopAnchorLowerConstraint.isActive = true
        }
    }
}

