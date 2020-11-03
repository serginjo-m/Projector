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

//trying to make a call about some changes in child to a parent
protocol DetailViewControllerDelegate: class {
    //this function is reload data according to changes make by user
    func reloadTableView()
    //General func for retreaving image by URL (BECOUSE Realm can't save images)
    func retreaveImageForProject(myUrl: String) -> UIImage
}

//Many protocols in app? is it good? ---------------------------------------
//delegate for reload after editing project
protocol EditViewControllerDelegate: class{
    func performAllConfigurations()
    func reloadViews()
}


class DetailViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EditViewControllerDelegate{
    
    //container for all items on the page
    var scrollViewContainer = UIScrollView()
    var contentUIView = UIView()
    
    let projectNumbersCV = ProjectNumbersCollectionView()
    
    
    
    
    
    
    
    
    //instance of project edit mode VC
    let editProjectViewController = EditProjectViewController()
    
    //most for reload data
    weak var delegate: DetailViewControllerDelegate?
  
    
    //Project Steps Filter by Categories
    var stepCategoriesFilter = StepCategoriesCollectionView()
    
    //Instance of Selected Project by User
    var projectDetail: ProjectList? {
        get{
            //Retrieve a single object with unique identifier (projectListIdentifier)
            return ProjectListRepository.instance.getProjectList(id: projectListIdentifier!)
        }
    }
    //Identifier of selected project
    var projectListIdentifier: String?
    
    //an array of steps
    var stepsArray = [ProjectStep]()

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
    let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "editButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(editButtonAction(_:)), for: .touchUpInside)
        button.contentHorizontalAlignment = .right
        return button
    }()

    //Outlets
//    @IBOutlet weak var addButton: UIButton!
//    @IBOutlet weak var dateLabel: UILabel!
//    @IBOutlet weak var projectName: UILabel!
//    @IBOutlet weak var projectNameTF: UITextField!
//    @IBOutlet weak var projectDetailDescriptionLabel: UITextView!
    
    //identifier for collection view
    var cellId = "cellID"
    
    //find steps array position in data base by id for filter
    var stepsIdDictionary = [String: Int]()
    
    //here creates a horizontal collectionView
    let stepsCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .vertical
        
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
        
        //Editing Project Name
        //projectNameTF.delegate = self
       // projectNameTF.isHidden = true
//        projectName.isUserInteractionEnabled = true
//        let nameTapGesture = UITapGestureRecognizer(target: self, action: #selector(labelIsTapped))
//        nameTapGesture.numberOfTapsRequired = 1
//        projectName.addGestureRecognizer(nameTapGesture)
        
        //add subviews
        //temporary location
        //adjust scroll view
        view.addSubview(scrollViewContainer)
        
        scrollViewContainer.addSubview(contentUIView)
        contentUIView.addSubview(projectImageView)
        //adds gradient to image view
        projectImageView.layer.insertSublayer(gradient, at: 0)
        contentUIView.addSubview(dismissButton)
        contentUIView.addSubview(projectName)
        contentUIView.addSubview(projectNumbersTitle)
        contentUIView.addSubview(projectNumbersCV)
        
        
        
        
//        view.addSubview(myProjectData)
//        view.addSubview(stepCategoriesFilter)
//        view.addSubview(collectionStackView)
//        view.addSubview(editButton)
//        view.bringSubviewToFront(addButton)
        
        //setup constraints
        setupLayout()
        
        //define selected project for categories collection view
        stepCategoriesFilter.project = projectDetail
        //identifier uses for creating existing step categories array
        stepCategoriesFilter.projectId = projectListIdentifier!
        
        // define parents collection view for reload
        stepCategoriesFilter.detailViewController = self
        //creates array for stepsCV based on data source
        updateMyArray()
        //make first pointer ("All") color - orange = selected
        stepCategoriesFilter.performButchUpdates()
        //create dictionary for steps deleting purposes
        createStepIdDictionary()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        performAllConfigurations()
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func performAllConfigurations(){
        
        //Passing URL to a func that returns image
        if let validUrl = projectDetail?.selectedImagePathUrl {
            //thankfully to my delegate mechanism I can path url of my project image & return image
            projectImageView.image = self.delegate?.retreaveImageForProject(myUrl: validUrl)
        }else{
            //in case image wasn't selected
            projectImageView.image = UIImage(named: "defaultImage")
        }
        
        //Passing selected project to data collection view
        if let project = projectDetail{
            projectNumbersCV.project = project
            projectName.text = project.name
        }
    }
    
    
    //perforn all positioning configurations
    private func setupLayout(){
        
        scrollViewContainer.translatesAutoresizingMaskIntoConstraints = false
        contentUIView.translatesAutoresizingMaskIntoConstraints = false
        projectName.translatesAutoresizingMaskIntoConstraints = false
        projectImageView.translatesAutoresizingMaskIntoConstraints = false
    
        stepCategoriesFilter.translatesAutoresizingMaskIntoConstraints = false
        collectionStackView.translatesAutoresizingMaskIntoConstraints = false
//        addButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        projectNumbersTitle.translatesAutoresizingMaskIntoConstraints = false
        projectNumbersCV.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        
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
        
        projectImageView.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 20).isActive = true
        projectImageView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        projectImageView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        projectImageView.heightAnchor.constraint(equalToConstant: 222).isActive = true
        
        dismissButton.topAnchor.constraint(equalTo: projectImageView.topAnchor, constant: 7).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: projectImageView.leftAnchor, constant: 7).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
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
        
        /*//edit project button
        editButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  10).isActive = true
        editButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -26).isActive = true
        editButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        //steps CV
        collectionStackView.topAnchor.constraint(equalTo: view.bottomAnchor, constant:  18).isActive = true
        collectionStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        collectionStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        collectionStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        //projects values
        myProjectData.topAnchor.constraint(equalTo: view.bottomAnchor, constant:  13).isActive = true
        myProjectData.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        myProjectData.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        myProjectData.heightAnchor.constraint(equalToConstant: 65).isActive = true
        //steps filter
        stepCategoriesFilter.topAnchor.constraint(equalTo: view.bottomAnchor, constant:  5).isActive = true
        stepCategoriesFilter.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        stepCategoriesFilter.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        stepCategoriesFilter.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //add step button
//        addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant:  -16).isActive = true
//        addButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
//        addButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
//        addButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        addButton.layer.cornerRadius = 30*/
    }
    
    //perform sublayer configuration after all views sizes and positions are defined
    override func viewDidLayoutSubviews() {
        gradient.frame = projectImageView.bounds
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
        return stepsArray.count
    }
    
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StepsCell
        cell.layer.cornerRadius = 12
        
        let step = stepsArray[indexPath.row]
        
        cell.stepNameLabel.text = step.name
        cell.doneButton.isSelected = step.complete
        
        //not all steps include images
        if step.selectedPhotosArray.count > 0 {
            cell.imageView.image = self.delegate?.retreaveImageForProject(myUrl: step.selectedPhotosArray[0])
        }else{
            cell.imageView.image = UIImage(named: "defaultImage")
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
        performSegue(withIdentifier: "ShowStepViewController", sender: nil)
        
    }
    //makes cells deselectable
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    //define color of deselected cell
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
    //MARK: Functions
    
    //Delete Step Handler
    @objc func deleteStep( button: UIButton){
        //create new alert window
        let alertVC = UIAlertController(title: "Delete Step?", message: "Are You sure want delete this step?", preferredStyle: .alert)
        //cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        //delete button
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
            //delete step in data base
            ProjectListRepository.instance.deleteProjectStep(list: self.projectDetail!, stepAtIndex: button.tag)
            
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
    
    //perform updates to views after make changes
    func reloadViews(){
        //here we call a masters (Boss) delegate function to reload its data
        self.delegate?.reloadTableView()
        // reload steps collection view
        self.stepsCollectionView.reloadData()
        //project data
        projectNumbersCV.projectNumbersCollectionView.reloadData()
        
    }
    
    //Switch handler
    @objc func itemCompleted(button: UIButton){
        //assign an opposite value to button.isSeleceted
        button.isSelected = !button.isSelected
        //here save .tag of selected switch = selected cell
        let updatedStep = projectDetail?.projectStep[button.tag]
        //func that change complete bool of the step
        ProjectListRepository.instance.updateStepCompletionStatus(step: updatedStep!, isComplete: button.isSelected)
        
        //update views after data source has been changed
        reloadViews()
    }
    
    /*@objc func labelIsTapped(){
        projectName.isHidden = true
        projectNameTF.isHidden = false
        //projectNameTF.text = projectName.text
        projectNameTF.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        projectNameTF.isHidden = true
        projectName.isHidden = false
        
        //update project name
        if let text = projectNameTF.text {
            if !text.isEmpty{
                projectName.text = text
                ProjectListRepository.instance.updateProjectName(name: text, list: projectDetail!)
                //perform update after data source has been changed
                reloadViews()
            }else{
                print("Text Field is Empty!!!")
            }
        }
        return true
    }*/
    
    //MARK: Actions
    
    //pergorm segue to new step VC
    @IBAction func addStep(_ sender: UIStoryboardSegue) {}
    
    //This is my edit button action!?
    @objc func editButtonAction(_ sender: Any){
        //define delegate between edit & detail VC
        editProjectViewController.delegate = self
        //set project name
  //      editProjectViewController.nameTextField.text = projectName.text
        //set project category
        for (index, item) in editProjectViewController.categoryCollectionView.categories.enumerated() {
            if projectDetail?.category == item {
                editProjectViewController.categoryCollectionView.categoryCollectionView.selectItem(at: [0, index], animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
            }
        }
        if let category = projectDetail?.category{
            editProjectViewController.categoryCollectionView.categoryName = category
        }
        //set project image
        editProjectViewController.projectMainPicture.image = projectImageView.image
        //set description text
      //  editProjectViewController.descriptionTextView.text = projectDetailDescriptionLabel.text
        //set project price value
        if let total = projectDetail?.totalCost{
            editProjectViewController.priceSlider.value = Float(total)
        }
        //set project distance value
        if let distance = projectDetail?.distance{
            editProjectViewController.distanceSlider.value = Float(distance)
        }
        if let url = projectDetail?.selectedImagePathUrl {
            editProjectViewController.selectedImageURLString = url
        }
        if let id = projectDetail?.id{
            editProjectViewController.projectId = id
        }
        if let steps = projectDetail?.projectStep{
            editProjectViewController.projectSteps = steps
        }
        self.show(editProjectViewController, sender: sender)
        //performSegue(withIdentifier: "pushToEditProject", sender: editButton)
    }
    
    @IBAction func unwindDetailViewController(sender: UIStoryboardSegue){// !!!--- NAME == TARGET ----!!!
        //update array, to have a data for new cell
        updateMyArray()
        //update views 
        self.delegate?.reloadTableView()
        //perform all operations step by step with categories CV
        stepCategoriesFilter.updateCategoriesCV()
        //add new item
        let newIndexPath = IndexPath(row: stepsArray.count - 1, section: 0)
        stepsCollectionView.insertItems(at: [newIndexPath])
    }
    
   //creates array for CV based on data source
    func updateMyArray(){
        //clear all step from array
        stepsArray.removeAll()
        //add all steps to array
        for item in projectDetail!.projectStep {
            stepsArray.append(item)
        }
        /*becouse of dequeue issue have to
         create dictionary where step id is corresponds to position in projects array
         */
        createStepIdDictionary()
    }
    
    //Dictionary that holds position of step in array based on step id
    func createStepIdDictionary(){
        if let stArr = projectDetail?.projectStep{
            for step in stArr{
                stepsIdDictionary[step.id] = stArr.index(of: step)
            }
        }
    }
    
    //passing tapped cell identifier to NewStepVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // becouse prepare can be only 1, switch is needed
        switch segue.identifier{
        case "AddStep":
            //Passing projectListIdentifier to NewStepViewController
            let destinationVC = segue.destination as! NewStepViewController
            //define var of destination VC
            destinationVC.uniqueID = projectListIdentifier!
        case "ShowStepViewController":
            //identify index of selected step
            if let indexPath = stepsCollectionView.indexPathsForSelectedItems?[0]{
                //search step by sected item index
                let selectedStep = stepsArray[indexPath.row]
                //define what segue destination is
                let controller = segue.destination as! StepViewController
                //controller.delegate = self// am I need this? // the answer is YES!! Becouse it is a part of a delegate mechanism
                controller.stepID = selectedStep.id
                //set parentVC for delegate function of completed step
                controller.parentVC = self
            }
        default: break
        }
    }
    
}
