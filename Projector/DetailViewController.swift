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
    
    //most for reload data
    weak var delegate: DetailViewControllerDelegate?
    
    //scroll view container
    var scrollViewContainer = UIScrollView()
    var contentUIView = UIView()
    
    //project statistics (money, distance..)
    let projectNumbersCV = ProjectNumbersCollectionView()
    
    //Project Steps Filter by Categories
    var stepCategoriesFilter = StepCategoriesCollectionView()
    //find steps array position in data base by id for filter
    var stepsIdDictionary: [String: Int] = [:]
    //an array of steps
    var localStepsArray: [ProjectStep] = []
    
    //instance of project edit mode VC
    let editProjectViewController = EditProjectViewController()
    
    //Instance of Selected Project by User
    var projectInstance: ProjectList? {
        get{
            //Retrieve a single object with unique identifier (projectListIdentifier)
            return ProjectListRepository.instance.getProjectList(id: projectListIdentifier!)
        }
    }
    
    //Identifier of selected project
    var projectListIdentifier: String?

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
        
        
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        contentUIView.addSubview(projectImageView)
        contentUIView.addSubview(dismissButton)
        contentUIView.addSubview(projectName)
        contentUIView.addSubview(projectNumbersTitle)
        contentUIView.addSubview(projectNumbersCV)
        contentUIView.addSubview(stepsTitle)
        contentUIView.addSubview(stepCategoriesFilter)
        contentUIView.addSubview(collectionStackView)
        
        //adds gradient to image view
        projectImageView.layer.insertSublayer(gradient, at: 0)
        
        
        if let layout = stepsCollectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        
        //setup constraints
        setupLayout()
        
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
            projectImageView.image = UIImage(named: "defaultImage")
        }
        
        //SET PROJECT DATA TO OBJECTS
        if let project = projectInstance{
            projectNumbersCV.project = project
            projectName.text = project.name
            stepsTitle.text = "Steps To Do (\(project.projectStep.count))"
        }
        
        //as project ID defined filter start to run
        stepCategoriesFilter.projectId = projectListIdentifier!
        
        // define parents collection view for reload
        stepCategoriesFilter.detailViewController = self
        
        //this two things
        updateMyArray()
        
        //update CV
        stepsCollectionView.reloadData()
        
        //create dictionary for steps deleting purposes
        createStepIdDictionary()
        
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
        //assign an opposite value to button.isSeleceted
        button.isSelected = !button.isSelected
        //here save .tag of selected switch = selected cell
        let updatedStep = projectInstance?.projectStep[button.tag]
        //func that change complete bool of the step
        ProjectListRepository.instance.updateStepCompletionStatus(step: updatedStep!, isComplete: button.isSelected)
        
        //update views after data source has been changed
        reloadViews()
    }
    
    //EDIT BUTTON ACTION
    @objc func editButtonAction(_ sender: Any){
        //define delegate between edit & detail VC
        editProjectViewController.delegate = self
        //set project name
  //      editProjectViewController.nameTextField.text = projectName.text
        //set project category
        for (index, item) in editProjectViewController.categoryCollectionView.categories.enumerated() {
            if projectInstance?.category == item {
                editProjectViewController.categoryCollectionView.categoryCollectionView.selectItem(at: [0, index], animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
            }
        }
        if let category = projectInstance?.category{
            editProjectViewController.categoryCollectionView.categoryName = category
        }
        //set project image
        editProjectViewController.projectMainPicture.image = projectImageView.image
        //set description text
      //  editProjectViewController.descriptionTextView.text = projectDetailDescriptionLabel.text
        //set project price value
        if let total = projectInstance?.totalCost{
            editProjectViewController.priceSlider.value = Float(total)
        }
        //set project distance value
        if let distance = projectInstance?.distance{
            editProjectViewController.distanceSlider.value = Float(distance)
        }
        if let url = projectInstance?.selectedImagePathUrl {
            editProjectViewController.selectedImageURLString = url
        }
        if let id = projectInstance?.id{
            editProjectViewController.projectId = id
        }
        if let steps = projectInstance?.projectStep{
            editProjectViewController.projectSteps = steps
        }
        self.show(editProjectViewController, sender: sender)
        //performSegue(withIdentifier: "pushToEditProject", sender: editButton)
    }
    
    //NEW STEP UPDATES
    /*@IBAction func unwindDetailViewController(sender: UIStoryboardSegue){// !!!--- NAME == TARGET ----!!!
        //update array, to have a data for new cell
        updateMyArray()
        //update views 
        self.delegate?.reloadTableView()
        //perform all operations step by step with categories CV
        stepCategoriesFilter.updateCategoriesCV()
        //add new item
        let newIndexPath = IndexPath(row: localStepsArray.count - 1, section: 0)
        stepsCollectionView.insertItems(at: [newIndexPath])
    }*/
    
    //UPDATES AFTER CHANGINGS
    func reloadViews(){
        //here we call a masters (Boss) delegate function to reload its data
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
    
    
    //passing tapped cell identifier to NewStepVC
   /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    }*/
    
    func showStepDetails(index: Int){
        let selectedStepId = localStepsArray[index].id
        
        let stepDetailVC = StepViewController()
        stepDetailVC.stepID = selectedStepId
//        stepDetailVC.delegate = self
        navigationController?.pushViewController(stepDetailVC, animated: true)
    }
    
}
// Pinterest Layout Configurations
extension DetailViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        //return photos[indexPath.item].image.size.height
        let sizesArray: [CGFloat] = [124, 87, 67, 58, 99, 120, 150]
    
        return sizesArray[indexPath.item]
    }
}
