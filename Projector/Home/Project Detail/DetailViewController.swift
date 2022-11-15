//
//  ViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 07.11.2019.
//  Copyright © 2019 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
import Photos

class DetailViewController: UIViewController, UITextFieldDelegate, EditViewControllerDelegate{
    
    //most for reload data
    weak var delegate: DetailViewControllerDelegate?
    
    //MARK: scroll view container
    //container for all items on the page
    var scrollViewContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    var contentUIView = UIView()
    
    //MARK: Project Numbers
    //Project Numbers Side Panel
    let sideView = SidePanelView()
    //project statistics (money, distance..)
    // 'lazy' give access to self & set controller once
    //give it some wrap to avoid error
    lazy var projectNumbersCV: ProjectNumbersCollectionView = {
        let projectNumbersCV = ProjectNumbersCollectionView(
            didTapMoneyCompletionHandler: { [weak self] in
                guard let self = self else {return}
                self.sideView.categoryKey = "money"
                self.showStatisticsDetail()
        },
            didTapTimeCompletionHandler: { [weak self] in
                guard let self = self else {return}
                self.sideView.categoryKey = "time"
                self.showStatisticsDetail()
        },
            didTapFuelCompletionHandler: { [weak self] in
                guard let self = self else {return}
                self.sideView.categoryKey = "fuel"
                self.showStatisticsDetail()
        })
        return projectNumbersCV
    }()
    
    //transparent black view that covers all content
    lazy var blackView: UIView = {
        let view = UIView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.25)
        view.alpha = 0
        return view
    }()
    
    //Instance of Selected Project by User
    var projectInstance: ProjectList? {
        get{
            //Retrieve a single object with unique identifier (projectListIdentifier)
            return ProjectListRepository.instance.getProjectList(id: projectListIdentifier)
        }
    }
    //Identifier of selected project
    var projectListIdentifier = String()
    
    
    lazy var stepsCollections: Steps = {
        //it isn't optional, so I need to set something to view
        guard let project = ProjectListRepository.instance.getProjectList(id: projectListIdentifier) else {
            return Steps(project: ProjectList(), delegate: self, projectWayFilter: self.displayStepsSwitchButton.isSelected)//empty instace
        }
        let steps = Steps(project: project, delegate: self, projectWayFilter: self.displayStepsSwitchButton.isSelected)
        return steps
    }()
    
    let projectImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIImageView.ContentMode.scaleAspectFill
        imageView.image = UIImage(named: "newEventDefault")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 13
        return imageView
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
    //adds contrast to project title
    let gradient: CAGradientLayer =  {
        let gradient = CAGradientLayer()
        let topColor = UIColor.init(red: 1/255, green: 1/255, blue: 1/255, alpha: 0).cgColor//black transparent
        let middleColor = UIColor.init(red: 1/255, green: 1/255, blue: 1/255, alpha: 0.21).cgColor//black 16% opacity
        let bottomColor = UIColor.init(red: 2/255, green: 2/255, blue: 2/255, alpha: 0.55).cgColor//black 56% opacity
        gradient.colors = [topColor, middleColor, bottomColor]
        gradient.locations = [0.55, 0.75, 1.0]
        return gradient
    }()
    let projectName:UILabel = {
        let pn = UILabel()
        pn.text = "Travel to Europe on Motorcycle"
        pn.textAlignment = NSTextAlignment.left
        pn.font = UIFont.boldSystemFont(ofSize: 20)
        pn.textColor = UIColor.white
        pn.numberOfLines = 3
        return pn
    }()
    var projectNumbersTitle: UILabel = {
        let label = UILabel()
        label.text = "Project Expenses"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    var stepsTitle: UILabel = {
        let label = UILabel()
        label.text = "Steps To Do"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    lazy var displayStepsSwitchButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleStepsDispalayFilter(_:)), for: .touchUpInside)
        button.setImage(UIImage(named: "greenEye"), for: .normal)
        button.setImage(UIImage(named: "redEye"), for: .selected)
        button.contentMode = .left
        let redColor = UIColor.init(displayP3Red: 255/255, green: 49/255, blue: 49/255, alpha: 1)
        let greenColor = UIColor.init(displayP3Red: 27/255, green: 186/255, blue: 28/255, alpha: 1)
        button.setTitleColor(redColor, for: .selected)
        button.setTitleColor(greenColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        if let project = projectInstance {
            button.isSelected = project.filterIsActive
        }
        return button
    }()
    
    lazy var editButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "editButton"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(editButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var projectWayButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "projectWayIcon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(presentProjectWay), for: .touchUpInside)
        return button
    }()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        view.backgroundColor = .white
        //apply because side panel visible during animation btwn view controllers
        view.layer.masksToBounds = true
        
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        contentUIView.addSubview(projectImageView)
        contentUIView.addSubview(dismissButton)
        contentUIView.addSubview(editButton)
        contentUIView.addSubview(projectWayButton)
        contentUIView.addSubview(projectName)
        contentUIView.addSubview(projectNumbersTitle)
        contentUIView.addSubview(projectNumbersCV)
        contentUIView.addSubview(stepsTitle)
        contentUIView.addSubview(stepsCollections)
        contentUIView.addSubview(displayStepsSwitchButton)
        
        view.addSubview(blackView)
        view.addSubview(sideView)
        
        //adds gradient to image view
        projectImageView.layer.insertSublayer(gradient, at: 0)
        
        //setup constraints
        setupLayout()
        //includes keyboard dismiss func from extension
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        performAllConfigurations()
    }
    
    //perform sublayer configuration after all views sizes and positions are defined
    override func viewDidLayoutSubviews() {
        gradient.frame = projectImageView.bounds
    }
      
    //MARK: Methods
    //back to previous view
    @objc func backAction(_ sender: Any) {
        self.delegate?.reloadTableView()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func toggleStepsDispalayFilter(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let project = projectInstance {
            ProjectListRepository.instance.updateProjectFilterStatus(project: project, filterIsActive: sender.isSelected)
        }
        stepsCollections.projectWayFilter = sender.isSelected
        stepsCollections.updateAllStepCollectionViews()
    }
    
    //set project image, name, statistics DB
    func performAllConfigurations(){
        //GET IMAGE from url
        if let validUrl = projectInstance?.selectedImagePathUrl {
            //thankfully to my delegate mechanism I can path url of my project image & return image
            projectImageView.image = self.delegate?.retreaveImageForProject(myUrl: validUrl)
        }else{
            //in case image wasn't selected
            projectImageView.image = UIImage(named: "newEventDefault")
        }
        
        //SET PROJECT DATA TO OBJECTS
        if let project = projectInstance{
            projectNumbersCV.project = project
            //define side panel data source
            sideView.projectId = self.projectListIdentifier
            stepsCollections.project = project
            projectName.text = project.name
            //displayed steps number
            let stepsToDisplay = project.projectStep.filter { step in
                step.displayed == true
            }
            //Filter turned off
            displayStepsSwitchButton.setTitle("  \(project.projectStep.count)/\(project.projectStep.count) displayed", for: .normal)
            //Filter turned on
            displayStepsSwitchButton.setTitle("  \(stepsToDisplay.count)/\(project.projectStep.count) displayed", for: .selected)
            
            //is it really good idea to update every time step is set to hidden inside StepWayVC?
            displayStepsSwitchButton.isSelected = project.filterIsActive
            stepsCollections.projectWayFilter = project.filterIsActive
            stepsCollections.updateAllStepCollectionViews()
        }
    }
    
    @objc func presentProjectWay(){
        let projectWayVC = ProjectWayViewController(projectId: projectListIdentifier)
        projectWayVC.modalPresentationStyle = .fullScreen
        self.present(projectWayVC, animated: true)
    }
    
    //EDIT BUTTON ACTION
    @objc func editButtonAction(_ sender: Any){
        guard let project = projectInstance else {return}
        //instance of project edit mode VC
        let editProjectViewController = NewProjectViewController()
        editProjectViewController.modalTransitionStyle = .coverVertical
        editProjectViewController.modalPresentationStyle = .fullScreen
        
        editProjectViewController.viewControllerTitle.text = "Edit Project"
        editProjectViewController.nameTextField.text = projectName.text
        editProjectViewController.projectImage.image = projectImageView.image
        //set project category
        for (index, item) in editProjectViewController.newProjectCategories.categories.enumerated() {
           
            if project.category == item {
             
                editProjectViewController.newProjectCategories.categoryCollectionView.selectItem(at: [0, index], animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
            }
        }
        
        editProjectViewController.newProjectCategories.categoryName = project.category
        
        
        //information about project object need to be transfered
        editProjectViewController.selectedImageURLString = project.selectedImagePathUrl
        editProjectViewController.projectId = project.id
      
        self.present(editProjectViewController, animated: true, completion: nil)
    }
    
    //UPDATES AFTER CHaNGINGS
    func reloadViews(){
        
        //here we call mainVC delegate function to reload its data
        self.delegate?.reloadTableView()
        // reload steps collection view
        if let project = ProjectListRepository.instance.getProjectList(id: projectListIdentifier){
            //as project defined, didSet call update for collection views
            stepsCollections.project = project
        }
        //reload statistics collection view
        projectNumbersCV.projectNumbersCollectionView.reloadData()
        
    }
    //calls by customDelegate StepsCategoryCollectionView
    func pushToViewController(stepId: String) {
        
        let stepViewController = StepViewController(stepId: stepId)
        stepViewController.stepID = stepId
        stepViewController.projectId = projectListIdentifier
        
        navigationController?.pushViewController(stepViewController, animated: true)
    }
    
    
    //MARK: Constraints
    private func setupLayout(){
                
        [editButton, scrollViewContainer, contentUIView, projectName, projectImageView, dismissButton, projectNumbersTitle, projectNumbersCV, stepsTitle, blackView, stepsCollections].forEach { (view) in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        blackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        blackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        blackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        blackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        //70% of width
        let width = 70 * self.view.frame.width / 100
        self.sideView.frame = CGRect(x: -self.view.frame.width, y: 0, width: width, height: self.view.frame.height)
        
        scrollViewContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        scrollViewContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        scrollViewContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        contentUIView.topAnchor.constraint(equalTo: scrollViewContainer.topAnchor).isActive = true
        contentUIView.leftAnchor.constraint(equalTo: scrollViewContainer.leftAnchor).isActive = true
        contentUIView.rightAnchor.constraint(equalTo: scrollViewContainer.rightAnchor).isActive = true
        contentUIView.bottomAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor).isActive = true
        contentUIView.widthAnchor.constraint(equalTo: scrollViewContainer.widthAnchor).isActive = true
        contentUIView.heightAnchor.constraint(equalToConstant: 1500).isActive = true
        
        projectImageView.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 20).isActive = true
        projectImageView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        projectImageView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        projectImageView.heightAnchor.constraint(equalToConstant: 222).isActive = true
        
        dismissButton.topAnchor.constraint(equalTo: projectImageView.topAnchor, constant: 7).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: projectImageView.leftAnchor, constant: 7).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        editButton.topAnchor.constraint(equalTo: projectImageView.topAnchor, constant: 7).isActive = true
        editButton.rightAnchor.constraint(equalTo: projectImageView.rightAnchor, constant: -7).isActive = true
        editButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        projectWayButton.topAnchor.constraint(equalTo: editButton.topAnchor, constant: 0).isActive = true
        projectWayButton.rightAnchor.constraint(equalTo: editButton.leftAnchor, constant: -18).isActive = true
        projectWayButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        projectWayButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        projectName.bottomAnchor.constraint(equalTo: projectImageView.bottomAnchor, constant: -10).isActive = true
        projectName.leftAnchor.constraint(equalTo: projectImageView.leftAnchor, constant: 14).isActive = true
        projectName.rightAnchor.constraint(equalTo: projectImageView.rightAnchor, constant: -14).isActive = true
        projectName.heightAnchor.constraint(equalToConstant: 49).isActive = true
        
        projectNumbersTitle.topAnchor.constraint(equalTo: projectImageView.bottomAnchor, constant: -7).isActive = true
        projectNumbersTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        projectNumbersTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: 0).isActive = true
        projectNumbersTitle.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        projectNumbersCV.topAnchor.constraint(equalTo: projectNumbersTitle.bottomAnchor, constant: -11).isActive = true
        projectNumbersCV.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        projectNumbersCV.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: 0).isActive = true
        projectNumbersCV.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        stepsTitle.topAnchor.constraint(equalTo: projectNumbersCV.bottomAnchor, constant: 16).isActive = true
        stepsTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        stepsTitle.widthAnchor.constraint(equalToConstant: 110).isActive = true
        stepsTitle.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        displayStepsSwitchButton.centerYAnchor.constraint(equalTo: stepsTitle.centerYAnchor).isActive = true
        displayStepsSwitchButton.leadingAnchor.constraint(equalTo: stepsTitle.trailingAnchor, constant: 15).isActive = true
        displayStepsSwitchButton.widthAnchor.constraint(equalToConstant: 155).isActive = true
        displayStepsSwitchButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        stepsCollections.topAnchor.constraint(equalTo: stepsTitle.bottomAnchor, constant: 19).isActive = true
        stepsCollections.bottomAnchor.constraint(equalTo: contentUIView.bottomAnchor, constant: 0).isActive = true
        stepsCollections.trailingAnchor.constraint(equalTo: contentUIView.trailingAnchor, constant: -15).isActive = true
        stepsCollections.leadingAnchor.constraint(equalTo: contentUIView.leadingAnchor, constant: 15).isActive = true
    }
    
}
