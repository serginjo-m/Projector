//
//  StepVC.swift
//  Projector
//
//  Created by Serginjo Melnik on 21.04.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class StepViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //MARK: Properties
    //TABLE VIEW CELL IDENTIFIER
    let cellIdentifier = "stepTableViewCell"
    
    //All this stuff is for zooming items
    //hold dimension of event view displayed in side panel before zoomimg it to full dimension
    var startingFrame: CGRect?
    //background behind full dimension event, after it zooms in
    var zoomBackgroundView: UIView?
    //need to hide it before animation starts
    var startingView: UIView?
    
    //animation start point
    var startingImageFrame: CGRect?
    //black bg
    var blackBackgroundView: UIView?
    //view to zoom in
    var startingImageView: UIView?
    
    //TABLE VIEW
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
    var scrollViewContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    var contentUIView = UIView()
    
    //Instance of Project Selected by User
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
    
    //zooming stuff (because same items need different anchors for zoomingOUt and ZoomingIN)
    var stepCommentHeightConstraint: NSLayoutConstraint!
    var stepCommentTopAnchorHigherConstraint: NSLayoutConstraint!
    var stepCommentTopAnchorLowerConstraint: NSLayoutConstraint!
    var stepItemsTitleTopAnchorHigherConstraint: NSLayoutConstraint!
    var stepItemsTitleTopAnchorMiddleConstraint: NSLayoutConstraint!
    var stepItemsTitleTopAnchorLowerConstraint: NSLayoutConstraint!
    var stepNameTitleHeightAnchor: NSLayoutConstraint!
    
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
        
        //by default - black
        view.backgroundColor = .white
        
        //add scroll containers
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        
        //add items to a view
        [dismissButton, stepTableView, stepImagesCV, categoryLabel, circleImage, stepToEventButton,editStepButton, removeStepButton, reminderStepButton, stepNameTitle, stepComment, stepItemsTitle].forEach {
            contentUIView.addSubview($0)
        }
        
        //constraints that are constant and don't need to be updated
        setupLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //configure view controller
        performPageConfigurations()
    }
    
    //MARK: Methods
    private func performPageConfigurations(){
        
        projectStep = ProjectListRepository.instance.getProjectStep(id: stepID)
        
        guard let step = projectStep else {return}
        
        categoryLabel.text = step.category
        stepNameTitle.text = step.name
        stepComment.text = step.comment
        stepToEventButton.isSelected = step.complete
        //hide or not, if no content is available for element
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
        
        //constraints and visibility of some views, that needs update after each update
        updateDynamicConstraints()
        self.stepTableView.reloadData()
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    //Add to Calendar Event
    @objc func addStepToCalendarEvent(button: UIButton) {
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
        //if step has some images define event image
        if step.selectedPhotosArray.count > 0 {
            //use UIImageView extension function that retreaves image from URL
            newEventViewController.imageHolderView.retreaveImageUsingURLString(myUrl: step.selectedPhotosArray[0])
        }
        //define event name
        newEventViewController.nameTextField.text = step.name
        //define comment
        newEventViewController.descriptionTextView.text = step.comment
        //show new event view controller
        navigationController?.present(newEventViewController, animated: true, completion: nil)
    }
    
    //DELETE STEP
    @objc func deleteStep( button: UIButton){
        //create new alert window
        let alertVC = UIAlertController(title: "Delete Step?", message: "Are You sure want delete this step?", preferredStyle: .alert)
        //cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        //delete button
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
            
            guard let step = self.projectStep, let projectId = self.projectId else {return}
//            check if step contain a reminder
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
            //fetch project for deleting step inside it
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
        //shows an alert window
        present(alertVC, animated: true, completion: nil)
    }
    
    @objc func setReminder(button: UIButton){
        print("Show events list?")
    }
    
    //EDIT ACTION
    @objc func editButtonAction(_ sender: Any){
        guard let step = projectStep else {return}
        
        let editStepViewController = NewStepViewController()
        editStepViewController.modalTransitionStyle = .coverVertical
        editStepViewController.modalPresentationStyle = .fullScreen
        //define step id
        editStepViewController.stepID = stepID
        //define project id
        if let projId = projectId {
            editStepViewController.projectId = projId
        }
        editStepViewController.projectId = projectId
        editStepViewController.viewControllerTitle.text = "Edit Step"
        editStepViewController.stepNameTextField.text = step.name
        
        //trick: if cv array modified it tries to modify data source object, so need to add item by item
        for item in step.selectedPhotosArray{
            editStepViewController.newStepImages.photoArray.append(item)
        }
        editStepViewController.stepItems.append(objectsIn: step.stepItemsList)
        
        editStepViewController.stepComplete = step.complete
        //configure expanding reminder active state
        if let event = step.event{
            if let reminder = event.reminder{
                editStepViewController.expandingReminderView.notification = reminder
            }
        }
        
        self.present(editStepViewController, animated: true, completion: nil)
    }
    
    //MARK: Table View
    //table view section
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
        contentUIView.heightAnchor.constraint(equalToConstant: 1500).isActive = true
        
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
        
        stepImagesCV.topAnchor.constraint(equalTo: stepToEventButton.bottomAnchor, constant:  30).isActive = true
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
        stepItemsTitleTopAnchorLowerConstraint = stepItemsTitle.topAnchor.constraint(equalTo: stepComment.bottomAnchor, constant: 20)
        
        stepTableView.topAnchor.constraint(equalTo: stepItemsTitle.bottomAnchor, constant:  9).isActive = true
        stepTableView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        stepTableView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        stepTableView.bottomAnchor.constraint(equalTo: contentUIView.bottomAnchor, constant: 0).isActive = true
    }
    
    func updateDynamicConstraints(){
        //diff size string need width calculation for constraints
        guard let categoryLabelString = categoryLabel.text, let step = projectStep else {return}
        
       //calculates precise label width needed
        let categoryLabelSize = ceil(categoryLabelString.size(withAttributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]).width)
        categoryLabel.widthAnchor.constraint(equalToConstant: categoryLabelSize).isActive = true
        
        //this logic makes stepNamelabel size correct
        let rect = NSString(string: step.name).boundingRect(with: CGSize(width: view.frame.width - 30, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)], context: nil)
        
        stepNameTitleHeightAnchor.constant = rect.height + 20
        
        let commentRect = NSString(string: step.comment).boundingRect(with: CGSize(width: view.frame.width - 30, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)], context: nil)
        
        stepCommentHeightConstraint.constant = commentRect.height + 10
        
        if step.selectedPhotosArray.count == 0 {//if no photos, place it under buttons
            stepCommentTopAnchorLowerConstraint.isActive = false
            stepCommentTopAnchorHigherConstraint.isActive = true
        }else{//if it contains photos place it under photos
            stepCommentTopAnchorHigherConstraint.isActive = false
            stepCommentTopAnchorLowerConstraint.isActive = true
        }
        
        //Configure items position based on comment and photos visibily
        if step.comment.isEmpty == true {//if no comments
            if step.selectedPhotosArray.count == 0 {//if no photos
                //place it under buttons
                stepItemsTitleTopAnchorMiddleConstraint.isActive = false
                stepItemsTitleTopAnchorLowerConstraint.isActive = false
                stepItemsTitleTopAnchorHigherConstraint.isActive = true
            }else{
                //place it under photos
                stepItemsTitleTopAnchorHigherConstraint.isActive = false
                stepItemsTitleTopAnchorLowerConstraint.isActive = false
                stepItemsTitleTopAnchorMiddleConstraint.isActive = true
            }
        }else{//place it under comment
            stepItemsTitleTopAnchorHigherConstraint.isActive = false
            stepItemsTitleTopAnchorMiddleConstraint.isActive = false
            stepItemsTitleTopAnchorLowerConstraint.isActive = true
        }
        
    }
}

//MARK: Table View Cell
class StepTableViewCell: UITableViewCell {
    
    //use for zooming delgate
    var stepViewController: StepViewController?
    
    var template: StepItem? {
        didSet {
            guard let template = template else {return}
            itemTitle.text = template.title
            descriptionLabel.text = template.text
        }
    }

    let titleIcon: UIImageView = {
       let image = UIImageView()
        image.image = UIImage(named: "descriptionNote")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let itemTitle: UILabel = {
        let label = UILabel()
        label.text = "Something"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "First of all I need to clean and inspect all surface."
        //label.backgroundColor = UIColor.lightGray
        label.textColor = UIColor.init(white: 0.3, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let backgroundBubble: UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor(displayP3Red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        bg.layer.cornerRadius = 12
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.layer.masksToBounds = true
        return bg
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //turn of change background color on selected cell
        selectionStyle = UITableViewCell.SelectionStyle.none
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoomIn))
        addGestureRecognizer(tap)
        
        addSubview(itemTitle)
        addSubview(titleIcon)
        addSubview(backgroundBubble)
        addSubview(descriptionLabel)
        
        titleIcon.centerYAnchor.constraint(equalTo: itemTitle.centerYAnchor).isActive = true
        titleIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        titleIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        titleIcon.heightAnchor.constraint(equalToConstant: 14).isActive = true
        
        itemTitle.leftAnchor.constraint(equalTo: titleIcon.rightAnchor, constant: 7).isActive = true
        itemTitle.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        itemTitle.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        itemTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        descriptionLabel.topAnchor.constraint(equalTo: itemTitle.bottomAnchor, constant: 20).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        backgroundBubble.topAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -16).isActive = true
        backgroundBubble.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: -16).isActive = true
        backgroundBubble.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16).isActive = true
        backgroundBubble.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 16).isActive = true
        
        //Small tip
        //NSLayoutConstraint.activate([CONSTRAINTS])
    }
    
    //from cell to view controller
    @objc func zoomIn(tapGesture: UITapGestureRecognizer){
        
        guard let stepItem = template, let viewController = stepViewController else { return }
        viewController.performZoomForStartingEventView(stepItem: stepItem, startingView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension StepViewController {
    
    func performZoomForCollectionImageView(startingImageView: UIView){
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingImageFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)

        let zoomingImageView = UIImageView(frame: startingImageFrame!)
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.contentMode = .scaleAspectFill
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageZoomOut)))
        zoomingImageView.backgroundColor = .red
        if let cellImageView = startingImageView as? StepImageCell, let url = cellImageView.template {
            zoomingImageView.retreaveImageUsingURLString(myUrl: url)
        }

        if let keyWindow = UIApplication.shared.keyWindow{
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.alpha = 0
            blackBackgroundView?.backgroundColor = .black

            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)

            //math? of proportion with one side
            //h2 / w2 = h1 / w1
            //h2 = h1 / w1 * w2

            let height = self.startingImageFrame!.height / self.startingImageFrame!.width * keyWindow.frame.width

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {

                self.blackBackgroundView?.alpha = 1
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center

            }, completion: nil)

        }

    }
    
    @objc func handleImageZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view {
            
            zoomOutImageView.layer.cornerRadius = 5
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingImageFrame!
                self.blackBackgroundView?.alpha = 0
                
            }) { (completed: Bool) in
                
                //remove it completely
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }
    
    func performZoomForStartingEventView(stepItem: StepItem, startingView: UIView){
        
        guard let stepTableViewCell = startingView as? StepTableViewCell else {return}
        
        //save reference to the View() , so it can be used later
        self.startingView = stepTableViewCell
        //hide original view
        self.startingView?.isHidden = true

        guard let itemTemplate = stepTableViewCell.template,
              //it is a whole view frame
              let unwStartingFrame = startingView.superview?.convert(startingView.frame, to: nil) else {return}

        //bubble frame
        let zoomFrame = CGRect(x: unwStartingFrame.origin.x, y: unwStartingFrame.origin.y, width: unwStartingFrame.width, height: unwStartingFrame.height)
        //save frame for future use
        startingFrame = zoomFrame

        //expanded view size should start from small
        let zoomingView = StepItemZoomingView(stepItem: itemTemplate, frame: zoomFrame)
        //dismiss is not a button. It is a view
        zoomingView.dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOutItem)))
        
        zoomingView.title.text = stepTableViewCell.itemTitle.text
        zoomingView.descriptionLabel.text = stepTableViewCell.descriptionLabel.text
        zoomingView.descriptionTextView.text = zoomingView.descriptionLabel.text
        
        //button actions are located in parent viewController
        zoomingView.removeButton.addTarget(self, action: #selector(removeStepItem(_:)), for: .touchUpInside)
        zoomingView.editButton.addTarget( self, action: #selector(editStepItem(_:)), for: .touchUpInside)
        
        if let keyWindow = UIApplication.shared.keyWindow {

            //black transpared background
            self.zoomBackgroundView = UIView(frame: keyWindow.frame)

            zoomBackgroundView?.backgroundColor = UIColor.init(white: 0, alpha: 0.7)
            zoomBackgroundView?.alpha = 0
            keyWindow.addSubview(zoomBackgroundView!)
            //add expanded event view body
            keyWindow.addSubview(zoomingView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
                
                zoomingView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width * 0.9, height: keyWindow.frame.height * 0.9)
                
                self.zoomBackgroundView?.alpha = 1
                zoomingView.dismissView.alpha = 1
                zoomingView.removeButton.alpha = 1
                zoomingView.editButton.alpha = 1
                
                zoomingView.layoutIfNeeded()
                
                //wherever view is, make view pleced in the center of window
                zoomingView.center = keyWindow.center
                
            } completion: { (completed: Bool) in
                //do something here later .....
            }
        }
    }
    
    // zoom out logic
    @objc func zoomOutItem(tapGesture: UITapGestureRecognizer){
        
        //extract view from tap gesture
        if let zoomOutView = tapGesture.view?.superview{
            //corner configuration
            zoomOutView.layer.cornerRadius = 11
            zoomOutView.clipsToBounds = true
            
            guard  let zoom = zoomOutView as? StepItemZoomingView else {return}
            
            zoom.dismissView.alpha = 0
            zoom.removeButton.alpha = 0
            zoom.editButton.alpha = 0
            zoom.thinUnderline.alpha = 0
            zoom.descriptionTextView.alpha = 0
            zoom.descriptionLabel.alpha = 1
            
            //zoom out animation
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
                //back to initial size
                zoomOutView.frame = self.startingFrame!
                //set back to transparent background
                self.zoomBackgroundView?.alpha = 0
                
                    if let startingView = self.startingView as? StepTableViewCell {
                        
                        zoom.bubbleBottomAnchor.isActive = false
                        zoom.bubbleBottomLabelAnchor.isActive = true
                        
                        zoom.bubbleTopAnchor.isActive = false
                        zoom.bubbleTopLabelAnchor.isActive = true
                        
                        zoom.iconLeftAnchor.isActive = false
                        zoom.iconLeftCompactAnchor.isActive = true
                        
                        zoom.titleTopAnchor.constant = 0
                        zoom.descriptionTopAnchor.constant = 20
                        
                        zoom.descriptionHeightAnchor.isActive = false
                        zoom.descriptionBottomAnchor.isActive = true
                        
                        //zoom out fonts before animate
                        zoom.title.font = startingView.itemTitle.font
                        zoom.descriptionLabel.font = startingView.descriptionLabel.font
                        
                        if startingView.descriptionLabel.isHidden == true{
                            zoom.descriptionLabel.alpha = 0
                        }
                        
                    }
                
                zoomOutView.layoutIfNeeded()
                
            } completion: { (completed: Bool) in
                //remove temporary created view from superview
                zoomOutView.removeFromSuperview()
                //show back original event (bubble) view
                self.startingView?.isHidden = false
            }

        }
    }
    
    @objc func removeStepItem(_ sender: UIButton){
        
        guard let cell = self.startingView as? StepTableViewCell,
              let stepItem = cell.template,
              let zoomingItemView = sender.superview as? StepItemZoomingView else {return}
        
        //create new alert window
        let alertVC = UIAlertController(title: "Delete Step Item?", message: "Are You sure You want to delete this Step Item?", preferredStyle: .alert)
                
        //delete button
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
            
            zoomingItemView.removeFromSuperview()
            //set back to transparent background
            self.zoomBackgroundView?.alpha = 0
            self.startingView?.isHidden = false
            
            ProjectListRepository.instance.deleteStepItem(stepItem: stepItem)

            self.stepTableView.reloadData()
        })
        
        alertVC.addAction(deleteAction)
        //cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertVC.addAction(cancelAction)
        
        //shows an alert window
        present(alertVC, animated: true, completion: nil)
    }
    
    @objc func editStepItem(_ sender: UIButton){
        guard let cell = self.startingView as? StepTableViewCell,
              let stepItem = cell.template,
              let zoomingItemView = sender.superview as? StepItemZoomingView else {return}
        
        let newStepItemVC = StepItemViewController()
        newStepItemVC.stepItem = stepItem
        newStepItemVC.itemTitleTextField.text = stepItem.title
        newStepItemVC.noteTextView.text = stepItem.text
        newStepItemVC.stepID = self.stepID
        newStepItemVC.modalPresentationStyle = .fullScreen
        
        
        
        zoomingItemView.removeFromSuperview()
        //set back to transparent background
        self.zoomBackgroundView?.alpha = 0
        self.startingView?.isHidden = false
        
        present(newStepItemVC, animated: true)
    }
}
