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
    //this function is reload data according of changes make by user
    func reloadTableView()
    //General func for retreaving image by URL (BECOUSE Realm can't save images)
    func retreaveImageForProject(myUrl: String) -> UIImage
}

class DetailViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    //If there is no retaining cycles print statment should run!
    deinit {
        print("OS Reclaiming memory for Detail View Controller")
    }

    //MARK: Properties
    
    //most for reload data
    weak var delegate: DetailViewControllerDelegate?
    
    //Project Statistic Collection View
    var myProjectData = ProjectData()
    
    //Project Steps Filter by Categories
    var stepCategoriesFilter = StepCategoriesCollectionView()
    
    //Instance of Project Selected by User
    var projectDetail: ProjectList? {
        get{
            //Retrieve a single object with unique identifier (projectListIdentifier)
            return ProjectListRepository.instance.getProjectList(id: projectListIdentifier!)
        }
    }
    
    //Identifier of selected project
    var projectListIdentifier: String?
    //an array of steps
    var stepsArray = [ProjectStep](){
        //great way to see how your var is changing in process
        didSet{
//            print("number of steps: ", stepsArray.count)
        }
    }

   //Project Image created programatically
    let projectImageView: UIImageView = {
        let PIV = UIImageView()
        PIV.contentMode = UIImageView.ContentMode.scaleAspectFill
        PIV.clipsToBounds = true
        PIV.layer.cornerRadius = 12
        //leave like so?
        PIV.image = UIImage(named: "workspace")
        return PIV
    }()

    //Outlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var projectNameTF: UITextField!
    @IBOutlet weak var projectDetailDescriptionLabel: UITextView!
    
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
        
        //Passing selected project to data collection view
        if let project = projectDetail{
            myProjectData.project = project
        }
        //assign description of the project
        projectDetailDescriptionLabel.text = projectDetail?.comment
        
        //Passing URL to a func that returns image
        if let validUrl = projectDetail?.selectedImagePathUrl {
            //thankfully to my delegate mechanism I can path url of my project image & return image
            projectImageView.image = self.delegate?.retreaveImageForProject(myUrl: validUrl)
        }else{
            //in case image wasn't selected
            projectImageView.image = UIImage(named: "defaultImage")
        }
        
        //Editing Project Name
        projectNameTF.delegate = self
        projectNameTF.isHidden = true
        projectName.isUserInteractionEnabled = true
        let nameTapGesture = UITapGestureRecognizer(target: self, action: #selector(labelIsTapped))
        nameTapGesture.numberOfTapsRequired = 1
        projectName.addGestureRecognizer(nameTapGesture)
        projectName.text = projectDetail?.name
        
        
        //add subviews
        view.addSubview(projectImageView)
        view.addSubview(myProjectData)
        view.addSubview(stepCategoriesFilter)
        view.addSubview(collectionStackView)
        
        //setup constraints
        setupLayout()
        
        //define selected project for categories collection view
        stepCategoriesFilter.project = projectDetail
        //identifier uses for creating existing step categories array
        stepCategoriesFilter.projectId = projectListIdentifier!
        
        // define parents collection view for reload
        stepCategoriesFilter.detailViewController = self
        //?
        updateMyArray()
        //make first pointer ("All") color - orange = selected
        stepCategoriesFilter.performButchUpdates()
        //create dictionary for deleting purposes
        createStepIdDictionary()
        
        if let date = projectDetail?.date {
            dateLabel.text = date
        }
        
    }
    
    
    //perforn all positioning configurations
    private func setupLayout(){
        
        projectImageView.translatesAutoresizingMaskIntoConstraints = false
        myProjectData.translatesAutoresizingMaskIntoConstraints = false
        stepCategoriesFilter.translatesAutoresizingMaskIntoConstraints = false
        collectionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        //projects main image
        collectionStackView.topAnchor.constraint(equalTo: stepCategoriesFilter.bottomAnchor, constant:  18).isActive = true
        collectionStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        collectionStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        collectionStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        //projects main image
        projectImageView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant:  18).isActive = true
        projectImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        projectImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        projectImageView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        //projects values
        myProjectData.topAnchor.constraint(equalTo: projectDetailDescriptionLabel.bottomAnchor, constant:  3).isActive = true
        myProjectData.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        myProjectData.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        myProjectData.heightAnchor.constraint(equalToConstant: 65).isActive = true
        //steps filter
        stepCategoriesFilter.topAnchor.constraint(equalTo: myProjectData.bottomAnchor, constant:  17).isActive = true
        stepCategoriesFilter.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        stepCategoriesFilter.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        stepCategoriesFilter.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
            // reload steps collection view
            self.stepsCollectionView.reloadData()
            //reload main view
            self.delegate?.reloadTableView()
            //perform actions step by step
            self.stepCategoriesFilter.updateCategoriesCV()
            
        })
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(deleteAction)
        //shows an alert window
        present(alertVC, animated: true, completion: nil)
    }
    
    //Switch handler
    @objc func itemCompleted(button: UIButton){
        
        //assign an opposite value to button.isSeleceted
        button.isSelected = !button.isSelected
        //here save .tag of selected switch = selected cell
        let updatedStep = projectDetail?.projectStep[button.tag]
        //func that change complete bool of the step
        ProjectListRepository.instance.updateStepCompletionStatus(step: updatedStep!, isComplete: button.isSelected)
        // reload of detail step collection view
        self.stepsCollectionView.reloadData()
        //here we call a masters (Boss) delegate function to reload its data
        self.delegate?.reloadTableView()
    }
    
    @objc func labelIsTapped(){
        projectName.isHidden = true
        projectNameTF.isHidden = false
        //projectNameTF.text = projectName.text
        projectNameTF.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()// don't know where it was declared
        projectNameTF.isHidden = true
        projectName.isHidden = false
        
        //update project name
        if let text = projectNameTF.text {
            if !text.isEmpty{
                projectName.text = text
                ProjectListRepository.instance.updateProjectName(name: text, list: projectDetail!)
                self.delegate?.reloadTableView()
            }else{
                print("Text Field is Empty!!!")
            }
        }
        return true
    }
    
    //MARK: Actions
    
    //pergorm segue to new step VC
    @IBAction func addStep(_ sender: UIStoryboardSegue) {}
    
    @IBAction func unwindDetailViewController(sender: UIStoryboardSegue){// !!!--- NAME == TARGET ----!!!
        //update array, to have a data for new cell
        updateMyArray()
        //update mainViewController data
        self.delegate?.reloadTableView()
        //perform all operations step by step with categories CV
        stepCategoriesFilter.updateCategoriesCV()
        
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
        // ?
        default: break
        }
    }
    
    //back to previous view
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
