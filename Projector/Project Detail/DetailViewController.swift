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

//calls functions from MainViewController
protocol DetailViewControllerDelegate: class {
    //this function is reload mainVC project data
    func reloadTableView()
    //General func for retreaving image by URL (BECOUSE Realm can't save images)
    func retreaveImageForProject(myUrl: String) -> UIImage
    //access nav controller for segue
    func pushToViewController(controllerType: Int)
}

//Many protocols in app? is it good? ---------------------------------------
//reload views after changings(add or edit object)
protocol EditViewControllerDelegate: class{
    // assign all necessary data to objects  in detailVC
    func performAllConfigurations()
    //reload mainVC TV & detailVC CV after make changes to stepsCV
    func reloadViews()
}

class DetailViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EditViewControllerDelegate{
    
    //most for reload data
    weak var delegate: DetailViewControllerDelegate?
    
    //scroll view container
    //container for all items on the page
    var scrollViewContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    var contentUIView = UIView()
    
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
    //IMPORTANT:
    //here I can add gesture recognizer becouse lazy var
    lazy var blackView: UIView = {
        let view = UIView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.25)
        view.alpha = 0
        return view
    }()

    //Project Steps Filter by Categories
    var stepCategoriesFilter = StepCategoriesCollectionView()
    //find steps array position in data base by id for filter
    var stepsIdDictionary: [String: Int] = [:]
    //an array of steps
    var localStepsArray: [ProjectStep] = []
    
    //Instance of Selected Project by User
    var projectInstance: ProjectList? {
        get{
            //Retrieve a single object with unique identifier (projectListIdentifier)
            return ProjectListRepository.instance.getProjectList(id: projectListIdentifier)
        }
    }
    
    //Identifier of selected project
    var projectListIdentifier = String() {
        didSet{
            self.sideView.projectId = self.projectListIdentifier
        }
    }

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
    
    //identifier for collection view
    var cellId = "cellID"
    
    //here creates a horizontal collectionView
    let stepsCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = PinterestLayout()
    
        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this instance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clear
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    lazy var collectionStackView: UIStackView = {
        
        let stack = UIStackView()
        
        stack.addSubview(stepsCollectionView)
        
        //specify delegate & datasourse for generating our individual horizontal cells
        stepsCollectionView.dataSource = self
        stepsCollectionView.delegate = self
        
        stepsCollectionView.showsHorizontalScrollIndicator = false
        stepsCollectionView.showsVerticalScrollIndicator = false
        
        stepsCollectionView.isScrollEnabled = false
    
        //Class is need to be registered in order of using inside
        stepsCollectionView.register(StepsCell.self, forCellWithReuseIdentifier: cellId)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepsCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepsCollectionView]))
        
        return stack
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
        contentUIView.addSubview(stepCategoriesFilter)
        contentUIView.addSubview(collectionStackView)
        
        view.addSubview(blackView)
        view.addSubview(sideView)
        
        //adds gradient to image view
        projectImageView.layer.insertSublayer(gradient, at: 0)
        
        if let layout = stepsCollectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }

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
        //IMAGE GET
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
            projectName.text = project.name
            stepsTitle.text = "Steps To Do (\(project.projectStep.count))"
        }
        
        //as project ID defined filter start to run
        stepCategoriesFilter.projectId = projectListIdentifier
        
        // define parents collection view for reload
        stepCategoriesFilter.detailViewController = self
        
        //this two things
        updateMyArray()
        
        //update CV
        stepsCollectionView.reloadData()
        
        //create dictionary for steps deleting purposes
        createStepIdDictionary()
        
    }
    
    //MARK: Collection View Section
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //define cell width
        let cellWidth = self.stepsCollectionView.frame.width/2 - 5
        return CGSize(width: cellWidth, height: 173)
    }
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return localStepsArray.count
    }
    
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StepsCell
        cell.layer.cornerRadius = 12
        
        let step = localStepsArray[indexPath.row]
        
        cell.stepNameLabel.text = step.name
        cell.doneButton.isSelected = step.complete
        
        //not all steps include images
        if step.selectedPhotosArray.count > 0 {
            cell.imageView.image = self.delegate?.retreaveImageForProject(myUrl: step.selectedPhotosArray[0])
        }else{
            cell.imageView.image = nil
        }
        
        //add tags for being able identify selected cell
        cell.doneButton.tag = stepsIdDictionary[step.id]!
        cell.deleteButton.tag = stepsIdDictionary[step.id]!
        cell.doneButton.addTarget(self, action: #selector(itemCompleted(button:)), for: .touchDown)
        cell.deleteButton.addTarget(self, action: #selector(deleteStep(button:)), for: .touchDown)
        
        return cell
    }
    
    //turn cells to be selectable
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //action when user selects the cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //segue to step details
        //performSegue(withIdentifier: "ShowStepViewController", sender: nil)
        
        showStepDetails(index: indexPath.item)
        
    }
    //makes cells deselectable
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    //define color of deselected cell
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
 
    //DELETE ACTION
    @objc func deleteStep( button: UIButton){
        //create new alert window
        let alertVC = UIAlertController(title: "Delete Step?", message: "Are You sure want delete this step?", preferredStyle: .alert)
        //cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        //delete button
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
            
            UserActivitySingleton.shared.createUserActivity(description: "Deleted \(self.localStepsArray[button.tag].name)")
            
            //delete step in data base
            ProjectListRepository.instance.deleteProjectStep(list: self.projectInstance!, stepAtIndex: button.tag)
            //update array for collection veiw
            self.updateMyArray()
            //reload views with new data after editing
            self.reloadViews()
            //perform actions step by step
            self.stepCategoriesFilter.updateCategoriesCV()
        })
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(deleteAction)
        //shows an alert window
        present(alertVC, animated: true, completion: nil)
    }
    
    //COMPLETED ACTION
    @objc func itemCompleted(button: UIButton){
        guard let step = projectInstance?.projectStep[button.tag] else {return}
        //assign an opposite value to button.isSeleceted
        button.isSelected = !button.isSelected
        
        //func that change complete bool of the step
        ProjectListRepository.instance.updateStepCompletionStatus(step: step, isComplete: button.isSelected)
        
        let completedString = button.isSelected == true ? "completed" : "not completed"
        UserActivitySingleton.shared.createUserActivity(description: "\(step.name) is \(completedString)")
        //update views after data source has been changed
        reloadViews()
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
    
    //UPDATES AFTER CHANGINGS
    func reloadViews(){
        //here we call mainVC delegate function to reload its data
        self.delegate?.reloadTableView()
        // reload steps collection view
        self.stepsCollectionView.reloadData()
        //reload statistics collection view
        projectNumbersCV.projectNumbersCollectionView.reloadData()
    }
    
    
    //MARK: FILTER LOGIC
    
    //creates array for CV based on data source
    func updateMyArray(){
        guard let array = projectInstance?.projectStep else {return}
        //clear all step from array
        localStepsArray.removeAll()
        
        //add all steps to array
        for item in array {
            localStepsArray.append(item)
        }
        /*becouse of dequeue issue have to
         create dictionary where step id is corresponds to position in ...
         */
        createStepIdDictionary()
    }
    
    //DELETE PURPOSES
    //Dictionary that holds position of step in array based on step id
    func createStepIdDictionary(){
        //clear old data
        stepsIdDictionary.removeAll()
        
        if let stArr = projectInstance?.projectStep{
            for step in stArr{
                stepsIdDictionary[step.id] = stArr.index(of: step)
            }
        }
    }
    
    //perform segue to step detail view controller
    func showStepDetails(index: Int){
        
        let selectedStepId = localStepsArray[index].id
        //------------------------------------- not happy, because object is huge! -----------------------------
        let stepDetailVC = StepViewController()
        
        stepDetailVC.stepIndex = index
        stepDetailVC.stepID = selectedStepId
        stepDetailVC.projectId = self.projectListIdentifier
        navigationController?.pushViewController(stepDetailVC, animated: true)
    }
    
    //perforn all positioning configurations
    private func setupLayout(){
        
        stepCategoriesFilter.translatesAutoresizingMaskIntoConstraints = false//
        collectionStackView.translatesAutoresizingMaskIntoConstraints = false//
        editButton.translatesAutoresizingMaskIntoConstraints = false
        scrollViewContainer.translatesAutoresizingMaskIntoConstraints = false//
        contentUIView.translatesAutoresizingMaskIntoConstraints = false//
        projectName.translatesAutoresizingMaskIntoConstraints = false//
        projectImageView.translatesAutoresizingMaskIntoConstraints = false//
        dismissButton.translatesAutoresizingMaskIntoConstraints = false//
        projectNumbersTitle.translatesAutoresizingMaskIntoConstraints = false//
        projectNumbersCV.translatesAutoresizingMaskIntoConstraints = false//
        stepsTitle.translatesAutoresizingMaskIntoConstraints = false//
        blackView.translatesAutoresizingMaskIntoConstraints = false

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
        
        stepsTitle.topAnchor.constraint(equalTo: projectNumbersCV.bottomAnchor, constant: -7).isActive = true
        stepsTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        stepsTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: 0).isActive = true
        stepsTitle.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        stepCategoriesFilter.topAnchor.constraint(equalTo: stepsTitle.bottomAnchor, constant: -27).isActive = true
        stepCategoriesFilter.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        stepCategoriesFilter.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: 0).isActive = true
        stepCategoriesFilter.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        collectionStackView.topAnchor.constraint(equalTo: stepCategoriesFilter.bottomAnchor, constant:  18).isActive = true
        collectionStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  15).isActive = true
        collectionStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        collectionStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
    }
    
}
// Pinterest Layout Configurations
extension DetailViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        let step = localStepsArray[indexPath.row]
        if step.selectedPhotosArray.count > 0 {
            guard let image = self.delegate?.retreaveImageForProject(myUrl: step.selectedPhotosArray[0]) else {return 60}
            return image.size.height
        }
        
        return 60
    }
    
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let step = localStepsArray[indexPath.row]
        if step.selectedPhotosArray.count > 0 {
            guard let image = self.delegate?.retreaveImageForProject(myUrl: step.selectedPhotosArray[0]) else {
                return 100
                
            }
            return image.size.width
        }
        
        return 100
    }
}
