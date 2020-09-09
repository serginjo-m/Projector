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
    
    //instance of project edit mode VC
    let editStepViewController = EditStepViewController()
    //cell identifier
    let cellIdentifier = "stepTableViewCell"
    //create an instance of table view
    let stepTableView = UITableView()
    //use for reload table & collection views
    weak var parentVC: DetailViewController?
    //VC for creating items in stepTableView
    let stepItemViewController = StepItemViewController()
    //Instance of Project Selected by User
    var projectStep: ProjectStep? {
        get{
            //Retrieve a single object with unique identifier (stepID)
            return ProjectListRepository.instance.getProjectStep(id: stepID!)
        }
    }
    //step id passed by detail VC
    var stepID: String?
    //creates an instance of extension
    let myStepImagesCV = StepImagesCollectionView()
    let stepStackView = StepStackView()
    
    //Cancel button
    let cancelButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "backArrow")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backAction(button:)), for: .touchDown)
        return button
    }()
    //Date Label
    let createdDateLabel: UILabel = {
        let label = UILabel()
        label.text = "23.04.2020"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = UIColor.darkGray
//        label.backgroundColor = .yellow
        return label
    }()
    //Add Button
    let addItemButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "addStep")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(addItem(button:)), for: .touchDown)
        return button
    }()
    
    //becouse of lazy var I can access "self"
    //lazy var calls ones, only when var == nil
    lazy var stepAddItem: StepAddItem = {
        let addItem = StepAddItem()
        addItem.parentViewController = self
        return addItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //perform all configuration separated by categories
        performPageConfigurations()
    }
    
    private func performPageConfigurations(){
        //add items to a view
        [cancelButton, stepTableView, createdDateLabel, addItemButton, myStepImagesCV, stepStackView].forEach {
            view.addSubview($0)
        }
        if let stepDate = projectStep?.date {
            createdDateLabel.text = stepDate
        }
        //setup constraints
        setupLayout()
        //assign values to stack view labels
        configureText()
        //configure image collection view
        configureImageCV()
        //configure stepTableView
        configureStepTableView()
    }
    
    private func configureStepTableView(){
        stepTableView.delegate = self
        stepTableView.dataSource = self
        stepTableView.register(StepTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        stepTableView.separatorStyle = .none
    }
    
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
    
    //make configurations to labels in stack view
    private func configureText(){
        stepStackView.step = projectStep
        stepStackView.editButton.addTarget(self, action: #selector(editButtonAction(_:)), for: .touchUpInside)
        stepStackView.doneButton.addTarget(self, action: #selector(changeSelectedValue(button:)), for: .touchDown)
    }
    
    //perforn all positioning configurations
    private func setupLayout(){
        //stepTableView.frame = CGRect(x: 16, y: 334, width: 345, height: 400)
        stepStackView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        createdDateLabel.translatesAutoresizingMaskIntoConstraints = false
        addItemButton.translatesAutoresizingMaskIntoConstraints = false
        myStepImagesCV.translatesAutoresizingMaskIntoConstraints = false
        stepTableView.translatesAutoresizingMaskIntoConstraints = false
        
        stepTableView.topAnchor.constraint(equalTo: stepStackView.bottomAnchor, constant:  23).isActive = true
        stepTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        stepTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        stepTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        myStepImagesCV.topAnchor.constraint(equalTo: createdDateLabel.bottomAnchor, constant:  18).isActive = true
        myStepImagesCV.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        myStepImagesCV.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        myStepImagesCV.heightAnchor.constraint(equalToConstant: 134).isActive = true
        
        stepStackView.topAnchor.constraint(equalTo: myStepImagesCV.bottomAnchor, constant:  18).isActive = true
        stepStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        stepStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        stepStackView.heightAnchor.constraint(equalToConstant: 93).isActive = true
        
        cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  10).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  26).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 8).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        createdDateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  10).isActive = true
        createdDateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        createdDateLabel.widthAnchor.constraint(equalToConstant: 90).isActive = true
        createdDateLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        addItemButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  10).isActive = true
        addItemButton.leftAnchor.constraint(equalTo: view.rightAnchor, constant:  -40).isActive = true
        addItemButton.widthAnchor.constraint(equalToConstant: 14).isActive = true
        addItemButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
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
    //edit button action
    @objc func editButtonAction(_ sender: Any){
        
        editStepViewController.stepViewSetting.id = stepID ?? ""
        editStepViewController.stepViewSetting.name = projectStep?.name ?? ""
        editStepViewController.stepViewSetting.category = projectStep?.category ?? "Other"
        editStepViewController.stepViewSetting.index = {
            var int = 0
            for (num, item) in editStepViewController.stepCategory.sortedCategories.enumerated() {
                if projectStep?.category == item {
                    int = num
                }
            }
            return int
        }()
        
        editStepViewController.stepViewSetting.photoArr = {
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
        
        editStepViewController.stepViewSetting.urlArr = {
            var array = [String]()
            if let arr = projectStep?.selectedPhotosArray{
                for url in arr{
                    array.append(url)
                }
            }
            return array
        }()
        
        editStepViewController.stepViewSetting.items = {
            var stepItems = [String]()
            if let itemsArray = projectStep?.itemsArray{
                for item in itemsArray{
                    stepItems.append(item)
                }
            }
            return stepItems
        }()
        editStepViewController.stepViewSetting.price = projectStep?.cost ?? 0
        editStepViewController.stepViewSetting.distance = projectStep?.distance ?? 0
        editStepViewController.stepViewSetting.complete = projectStep?.complete ?? false
       
        //------------- I don't realy like this approach, becouse it seems like a routine cycle
        editStepViewController.delegate = self
  
        //present edit VC
        self.show(editStepViewController, sender: sender)
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
    
    @objc func removeItem(button: UIButton){
        if let myStep = projectStep {
            ProjectListRepository.instance.deleteStepItem(step: myStep, itemAtIndex: button.tag)
            stepTableView.reloadData()
        }
    }
    
    //Dismiss
    @objc func backAction( button: UIButton){
        dismiss(animated: true, completion: nil)
    }
    //complete button
    @objc func changeSelectedValue(button: UIButton) {
        //assign an opposite value to button.isSeleceted
        button.isSelected = !button.isSelected
        ProjectListRepository.instance.updateStepCompletionStatus(step: projectStep!, isComplete: button.isSelected)
        
        parentVC?.stepsCollectionView.reloadData()
        parentVC?.delegate?.reloadTableView()
    }
    
    //this function is dedicated to perform reload to all views related to this object
    func someKindOfFunctionThatPerformRelaod(){
        //assign values to stack view labels
        configureText()
        //configure image collection view
        configureImageCV()
        myStepImagesCV.stepImagesCollectionView.reloadData()
        //configure stepTableView
        configureStepTableView()
        parentVC?.stepsCollectionView.reloadData()
        parentVC?.delegate?.reloadTableView()
    }
    
    //Show menu for add item
    @objc func addItem( button: UIButton){
        //show menu func in child class
        stepAddItem.showMenu()
    }
    
    func showControllerForSetting(setting: Setting) {
        //set targets view controller title text
        stepItemViewController.titleLabel.text = setting.name
        stepItemViewController.step = projectStep
        stepItemViewController.stepVC = self
        
        //shows view controller for add item
        self.show(stepItemViewController, sender: UIButton.self)
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
        button.setTitle("Remove", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "removeButton"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        //button.backgroundColor = UIColor.brown
        button.contentHorizontalAlignment = .right
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
        bg.layer.borderWidth = 1
        bg.layer.borderColor = UIColor(displayP3Red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor
        return bg
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //backgroundColor = UIColor.lightGray
        
        addSubview(taskLabel)
        addSubview(titleIcon)
        addSubview(removeButton)
        addSubview(backgroundBubble)
        addSubview(descriptionLabel)
        
        titleIcon.frame = CGRect(x: 0, y: 8, width: 16, height: 14)
        taskLabel.frame = CGRect(x: 23, y: 0, width: 250, height: 30)
        removeButton.frame = CGRect(x: Int(frame.width) - 67, y: 5, width: 77, height: 17)
        
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundBubble.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            descriptionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 48),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            backgroundBubble.topAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -16),
            backgroundBubble.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor, constant: -16),
            backgroundBubble.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            backgroundBubble.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 16)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
