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
    lazy var projectNumbersCV = ProjectNumbersCollectionView(
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
        //it is optional, so I need to set something to view
        guard let project = ProjectListRepository.instance.getProjectList(id: projectListIdentifier) else {
            return Steps(project: ProjectList(), delegate: self)//empty instace
        }
        let steps = Steps(project: project, delegate: self)
        return steps
    }()
    
   //Project Image created programatically
    let projectImageView: UIImageView = {
        let PIV = UIImageView()
        PIV.contentMode = UIImageView.ContentMode.scaleAspectFill
        PIV.clipsToBounds = true
        PIV.layer.cornerRadius = 11
        //leave like so?
        PIV.image = UIImage(named: "workspace")
        return PIV
    }()
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
        label.text = "Project Numbers"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    var stepsTitle: UILabel = {
        let label = UILabel()
        label.text = "Steps To Do (0)"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setBackgroundImage(UIImage(named: "editButton"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(editButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .white
        //apply becouse side panel visible during animation btwn view controllers
        view.layer.masksToBounds = true
        
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        contentUIView.addSubview(projectImageView)
        contentUIView.addSubview(dismissButton)
        contentUIView.addSubview(editButton)
        contentUIView.addSubview(projectName)
        contentUIView.addSubview(projectNumbersTitle)
        contentUIView.addSubview(projectNumbersCV)
        contentUIView.addSubview(stepsTitle)
        contentUIView.addSubview(stepsCollections)
        
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
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        self.delegate?.reloadTableView()
        navigationController?.popViewController(animated: true)
    }
    
    //set project image, name, statistics DB
    func performAllConfigurations(){
        //GET IMAGE from url
        if let validUrl = projectInstance?.selectedImagePathUrl {
            //thankfully to my delegate mechanism I can path url of my project image & return image
            projectImageView.image = self.delegate?.retreaveImageForProject(myUrl: validUrl)
        }else{
            //in case image wasn't selected
            projectImageView.image = nil
        }
        
        //SET PROJECT DATA TO OBJECTS
        if let project = projectInstance{
            projectNumbersCV.project = project
            stepsCollections.project = project
            projectName.text = project.name
            stepsTitle.text = "Steps To Do (\(project.projectStep.count))"
            
        }
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
        editProjectViewController.projectSteps = project.projectStep
        editProjectViewController.delegate = self
      
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
    
    
    //constraints
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
        stepsTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: 0).isActive = true
        stepsTitle.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        stepsCollections.topAnchor.constraint(equalTo: stepsTitle.bottomAnchor, constant: 19).isActive = true
        stepsCollections.bottomAnchor.constraint(equalTo: contentUIView.bottomAnchor, constant: 0).isActive = true
        stepsCollections.trailingAnchor.constraint(equalTo: contentUIView.trailingAnchor, constant: -15).isActive = true
        stepsCollections.leadingAnchor.constraint(equalTo: contentUIView.leadingAnchor, constant: 15).isActive = true
    }
    
}
