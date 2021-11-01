//
//  StepVC.swift
//  Projector
//
//  Created by Serginjo Melnik on 21.04.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

protocol StepViewControllerDelegate: class {
    //this function is dedicated to perform reload to all views related to this object
    func someKindOfFunctionThatPerformRelaod()
}

class StepViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StepViewControllerDelegate {
    
    //TABLE VIEW CELL IDENTIFIER
    let cellIdentifier = "stepTableViewCell"
    
    //TABLE VIEW
    let stepTableView = UITableView()
    
    //PARENT VC - WHOLE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    weak var parentVC: DetailViewController?
    
    //scroll view container2
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
            return ProjectListRepository.instance.getProjectStep(id: stepID!)
        }
    }
    
    //delete action need index & project id of item in project step array for removing
    var stepIndex: Int?
    var projectId: String?
    
    //step id passed by detail VC
    var stepID: String?
    
    //creates an instance of extension
    let myStepImagesCV = StepImagesCollectionView()
    //step values
    let stepNumbersCV = StepNumbersCollectionView()
    
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
    
    let completeStepButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(changeSelectedValue(button:)), for: .touchUpInside)
        button.setTitle("Complete", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(UIColor.init(red: 104/255, green: 104/255, blue: 104/255, alpha: 1), for: .normal)
        button.setTitleColor(UIColor.init(red: 42/255, green: 192/255, blue: 45/255, alpha: 1), for: .selected)
        return button
    }()
    
    let editStepButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(editButtonAction(_:)), for: .touchUpInside)
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(UIColor.init(red: 104/255, green: 104/255, blue: 104/255, alpha: 1), for: .normal)
        button.setTitleColor(UIColor.init(red: 42/255, green: 192/255, blue: 45/255, alpha: 1), for: .selected)
        return button
    }()
    
    let removeStepButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(deleteStep(button:)), for: .touchUpInside)
        button.setTitle("Remove", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(UIColor.init(red: 104/255, green: 104/255, blue: 104/255, alpha: 1), for: .normal)
        button.setTitleColor(UIColor.init(red: 42/255, green: 192/255, blue: 45/255, alpha: 1), for: .selected)
        return button
    }()
    
    let reminderStepButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(setReminder(button:)), for: .touchUpInside)
        button.setTitle("Reminder", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(UIColor.init(red: 104/255, green: 104/255, blue: 104/255, alpha: 1), for: .normal)
        button.setTitleColor(UIColor.init(red: 245/255, green: 166/255, blue: 35/255, alpha: 1), for: .selected)
        return button
    }()
    
    var stepValuesTitle: UILabel = {
        let label = UILabel()
        label.text = "Step Values"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var stepItemsTitle: UILabel = {
        let label = UILabel()
        label.text = "Items Todo"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //by default - black
        view.backgroundColor = .white
        
        //add scroll containers
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        
        //add items to a view
        [dismissButton, stepTableView, myStepImagesCV, categoryLabel, circleImage, completeStepButton,editStepButton, removeStepButton, reminderStepButton, stepNameTitle, stepValuesTitle, stepNumbersCV, stepItemsTitle].forEach {
            contentUIView.addSubview($0)
        }
        
        //perform all configuration separated by categories
        performPageConfigurations()
    }
    
    
    private func performPageConfigurations(){
        
        //------------------------ temporary solution -----------------------------
        guard let step = projectStep else {return}
        stepNameTitle.text = step.name
        completeStepButton.isSelected = step.complete
        reminderStepButton.isSelected = step.reminder != nil ? true : false//convert to bool value
        stepNumbersCV.step = step
        categoryLabel.text = step.category
        
        //this logic makes stepnamelabel size correct
        let rect = NSString(string: step.name).boundingRect(with: CGSize(width: view.frame.width, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)], context: nil)
        
        
        //CONSTRAINTS
        //----------------------------------------------------------------------------------------------------
        //it is not very efficient to configure ALL constraints after editing step
        setupLayout(titleRectHeight: rect.height)
        
        
        //IMAGES CV CONFIGURATION
        configureImageCV()
        
        //TABLE VIEW CONFIGURATION
        configureStepTableView()
    }
    
    //RELOAD ALL VIEWS :))
    func someKindOfFunctionThatPerformRelaod(){
        
        performPageConfigurations()
        myStepImagesCV.stepImagesCollectionView.reloadData()
        
        //--------------------------- whole VC need to be reduced! ---------------------------------------
//        parentVC?.stepsCollectionView.reloadData()
        //call DetailVC delegate function of main VC that perform reloads (a bit odd)?!
        parentVC?.delegate?.reloadTableView()
    }
    
    //TABLE VIEW CONFIGURATION
    private func configureStepTableView(){
        stepTableView.delegate = self
        stepTableView.dataSource = self
        stepTableView.register(StepTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        stepTableView.separatorStyle = .none
    }
    
    //IMAGES CV CONFIGURATION
    private func configureImageCV(){
        
        //clear before append
        myStepImagesCV.photosArray.removeAll()
        
        //append images to collections view array
        if let imageArray = projectStep?.selectedPhotosArray{
            for imageURL in imageArray {
                myStepImagesCV.photosArray.append(retreaveImageForStep(myUrl: imageURL))
            }
        }
        
        //define step inside class instance
        myStepImagesCV.step = projectStep
    }
    
    //return UIImage by URL
    func retreaveImageForStep(myUrl: String) -> UIImage{
        var stepImage: UIImage = UIImage(named: "defaultImage")!
        let url = URL(string: myUrl)
        let data = try? Data(contentsOf: url!)
        if let imageData = data{
            stepImage = UIImage(data: imageData)!
        }
        return stepImage
    }

    //back to previous view
    @objc func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //REMOVE ITEM
    @objc func removeItem(button: UIButton){
        guard let myStep = projectStep else {return}
        
        UserActivitySingleton.shared.createUserActivity(description: "\(myStep.itemsArray[button.tag]) removed from \(myStep.name)")
        
        ProjectListRepository.instance.deleteStepItem(step: myStep, itemAtIndex: button.tag)
        stepTableView.reloadData()
        
    }
    
    //COMPLETE
    @objc func changeSelectedValue(button: UIButton) {
        guard let step = projectStep else {return}
        //assign an opposite value to button.isSeleceted
        button.isSelected = !button.isSelected
        ProjectListRepository.instance.updateStepCompletionStatus(step: step, isComplete: button.isSelected)
//        parentVC?.stepsCollectionView.reloadData()
        parentVC?.delegate?.reloadTableView()
        
        let completedString = button.isSelected == true ? "completed" : "not completed"
        UserActivitySingleton.shared.createUserActivity(description: "\(step.name) is \(completedString)")
    }
    
    //DELETE STEP
    @objc func deleteStep( button: UIButton){
        //create new alert window
        let alertVC = UIAlertController(title: "Delete Step?", message: "Are You sure want delete this step?", preferredStyle: .alert)
        //cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        //delete button
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
            guard let step = self.projectStep,
                let projectId = self.projectId,
                let stepIndex = self.stepIndex
            else {return}
            
            UserActivitySingleton.shared.createUserActivity(description: "Deleted \(step.name)")
            
            var project: ProjectList? {
                get{
                    return ProjectListRepository.instance.getProjectList(id: projectId)
                }
            }
            
            if let proj = project {
                //delete step in data base
                ProjectListRepository.instance.deleteProjectStep(list: proj, stepAtIndex: stepIndex)
            }
            
            self.navigationController?.popViewController(animated: true)
        })
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(deleteAction)
        //shows an alert window
        present(alertVC, animated: true, completion: nil)
    }
    
    @objc func setReminder(button: UIButton){
        print("button try to set a reminder")
    }
    
    //EDIT ACTION
    @objc func editButtonAction(_ sender: Any){
        guard let step = projectStep else {return}
        
        let editStepViewController = NewStepViewController()
        editStepViewController.modalTransitionStyle = .coverVertical
        editStepViewController.modalPresentationStyle = .fullScreen
        editStepViewController.stepID = stepID
        editStepViewController.viewControllerTitle.text = "Edit Step"
        editStepViewController.stepNameTextField.text = step.name
        //categories
        editStepViewController.newStepCategory.selectedCategory = step.category
        //select step category in collecion view
        for (index, item) in editStepViewController.newStepCategory.sortedCategories.enumerated() {
            if step.category == item {
                editStepViewController.newStepCategory.categoryCollectionView.selectItem(at: [0, index], animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
            }
        }
        editStepViewController.newStepImages.photoArray = {
            var arrPhoto = [UIImage]()
            //plus image
            let defaultImage = UIImage(named: "plusIconV2")
            //unwrap optional
            if let photo = defaultImage{
                arrPhoto.append(photo)
            }
            //append images
            if myStepImagesCV.photosArray.count > 0{
                for image in myStepImagesCV.photosArray{
                    arrPhoto.append(image)
                }
            }
            return arrPhoto
        }()
        //becouse [String] != List<String>
        editStepViewController.selectedPhotoURLStringArray = {
            var array = [String]()
            
            for url in step.selectedPhotosArray{
                array.append(url)
            }
            
            return array
        }()
        //becouse [String] != List<String>
        editStepViewController.stepItems = {
            var stepItems = [String]()
            for item in step.itemsArray{
                stepItems.append(item)
            }
            return stepItems
        }()
        
        editStepViewController.stepComplete = step.complete
        editStepViewController.editDelegate = self
        //unwrap an optional value
        if let reminder = step.reminder{
            editStepViewController.expandingReminderView.notification = reminder
        }
        
        self.present(editStepViewController, animated: true, completion: nil)
    }
    
    //table view section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let num = projectStep?.itemsArray.count  {
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
        //turn of change background color from selected cell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.taskLabel.text = "Description Note"
        if let string = projectStep?.itemsArray[indexPath.row] {
            cell.descriptionLabel.text = string
        }
        cell.removeButton.tag = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(removeItem(button:)), for: .touchUpInside)
        return cell
    }
    
    //perforn all positioning configurations
    private func setupLayout(titleRectHeight: CGFloat){
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        myStepImagesCV.translatesAutoresizingMaskIntoConstraints = false
        stepTableView.translatesAutoresizingMaskIntoConstraints = false
        contentUIView.translatesAutoresizingMaskIntoConstraints = false
        scrollViewContainer.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        circleImage.translatesAutoresizingMaskIntoConstraints = false
        completeStepButton.translatesAutoresizingMaskIntoConstraints = false
        editStepButton.translatesAutoresizingMaskIntoConstraints = false
        removeStepButton.translatesAutoresizingMaskIntoConstraints = false
        stepNameTitle.translatesAutoresizingMaskIntoConstraints = false
        stepValuesTitle.translatesAutoresizingMaskIntoConstraints = false
        stepNumbersCV.translatesAutoresizingMaskIntoConstraints = false
        stepItemsTitle.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        //diff size string need width calculation for constraints
        guard let categoryLabelString = categoryLabel.text else {return}
        let categoryLabelSize = ceil(categoryLabelString.size(withAttributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]).width)
        
        //not sure is that's better solution, but it works after each reload
        categoryLabel.removeConstraints(categoryLabel.constraints)
        categoryLabel.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor, constant: 0).isActive = true
        categoryLabel.centerXAnchor.constraint(equalTo: contentUIView.centerXAnchor, constant: 0).isActive = true
        categoryLabel.widthAnchor.constraint(equalToConstant: categoryLabelSize).isActive = true
        categoryLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        circleImage.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor, constant: 0).isActive = true
        circleImage.rightAnchor.constraint(equalTo: categoryLabel.leftAnchor, constant: -6).isActive = true
        circleImage.widthAnchor.constraint(equalToConstant: 8).isActive = true
        circleImage.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        // 2 or 1 line title
        if titleRectHeight > 25{
            stepNameTitle.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 22).isActive = true
            stepNameTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
            stepNameTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
            stepNameTitle.heightAnchor.constraint(equalToConstant: 66).isActive = true
        }else{
            stepNameTitle.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 22).isActive = true
            stepNameTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
            stepNameTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
            stepNameTitle.heightAnchor.constraint(equalToConstant: 33).isActive = true
        }
        
        completeStepButton.topAnchor.constraint(equalTo: stepNameTitle.bottomAnchor, constant: 18).isActive = true
        completeStepButton.leftAnchor.constraint(equalTo: dismissButton.leftAnchor, constant: 0).isActive = true
        completeStepButton.widthAnchor.constraint(equalToConstant: 72).isActive = true
        completeStepButton.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        editStepButton.centerYAnchor.constraint(equalTo: completeStepButton.centerYAnchor, constant: 0).isActive = true
        editStepButton.leftAnchor.constraint(equalTo: completeStepButton.rightAnchor, constant: 24).isActive = true
        editStepButton.widthAnchor.constraint(equalToConstant: 31).isActive = true
        editStepButton.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        removeStepButton.centerYAnchor.constraint(equalTo: completeStepButton.centerYAnchor, constant: 0).isActive = true
        removeStepButton.leftAnchor.constraint(equalTo: editStepButton.rightAnchor, constant: 24).isActive = true
        removeStepButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        removeStepButton.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        reminderStepButton.centerYAnchor.constraint(equalTo: completeStepButton.centerYAnchor, constant: 0).isActive = true
        reminderStepButton.leftAnchor.constraint(equalTo: removeStepButton.rightAnchor, constant: 24).isActive = true
        reminderStepButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        reminderStepButton.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        myStepImagesCV.topAnchor.constraint(equalTo: completeStepButton.bottomAnchor, constant:  30).isActive = true
        myStepImagesCV.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  16).isActive = true
        myStepImagesCV.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -16).isActive = true
        myStepImagesCV.heightAnchor.constraint(equalToConstant: 144).isActive = true
        
        stepValuesTitle.topAnchor.constraint(equalTo: myStepImagesCV.bottomAnchor, constant: 30).isActive = true
        stepValuesTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        stepValuesTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: 0).isActive = true
        stepValuesTitle.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        stepNumbersCV.topAnchor.constraint(equalTo: stepValuesTitle.bottomAnchor, constant: 0).isActive = true
        stepNumbersCV.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        stepNumbersCV.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: 0).isActive = true
        stepNumbersCV.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        stepItemsTitle.topAnchor.constraint(equalTo: stepNumbersCV.bottomAnchor, constant: 20).isActive = true
        stepItemsTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        stepItemsTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        stepItemsTitle.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        stepTableView.topAnchor.constraint(equalTo: stepItemsTitle.bottomAnchor, constant:  9).isActive = true
        stepTableView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        stepTableView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        stepTableView.bottomAnchor.constraint(equalTo: contentUIView.bottomAnchor, constant: 0).isActive = true
    }
}

class StepTableViewCell: UITableViewCell {

    let titleIcon: UIImageView = {
       let image = UIImageView()
        image.image = UIImage(named: "descriptionNote")
        return image
    }()
    
    let taskLabel: UILabel = {
        let label = UILabel()
        label.text = "Something"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    let removeButton: UIButton = {
        let button = UIButton()
        
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setImage(UIImage(named: "removeItem"), for: .normal)
//        button.imageEdgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        button.contentMode = .center
        button.imageView!.contentMode = .scaleAspectFill
        
        button.backgroundColor = UIColor.init(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
        
        return button
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "First of all I need to clean and inspect all surface."
        //label.backgroundColor = UIColor.lightGray
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        return label
    }()
    
    let backgroundBubble: UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor(displayP3Red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        bg.layer.cornerRadius = 12
//        bg.layer.borderWidth = 1
//        bg.layer.borderColor = UIColor(displayP3Red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor
        bg.layer.masksToBounds = true
        return bg
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //backgroundColor = UIColor.lightGray
        
        addSubview(taskLabel)
        addSubview(titleIcon)
        
        addSubview(backgroundBubble)
        addSubview(descriptionLabel)
        backgroundBubble.addSubview(removeButton)
        
        titleIcon.frame = CGRect(x: 0, y: 8, width: 16, height: 14)
        taskLabel.frame = CGRect(x: 23, y: 0, width: 250, height: 30)
       // removeButton.frame = CGRect(x: Int(frame.width) - 67, y: 5, width: 77, height: 17)
        
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundBubble.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            descriptionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 48),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            backgroundBubble.topAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -16),
            backgroundBubble.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: -16),
            backgroundBubble.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            backgroundBubble.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 16),
            
            removeButton.topAnchor.constraint(equalTo: backgroundBubble.topAnchor, constant: 0),
            removeButton.rightAnchor.constraint(equalTo: backgroundBubble.rightAnchor, constant: 0),
            removeButton.widthAnchor.constraint(equalToConstant: 35),
            removeButton.bottomAnchor.constraint(equalTo: backgroundBubble.bottomAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
