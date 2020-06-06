////
////  ViewController.swift
////  Projector
////
////  Created by Serginjo Melnik on 07.11.2019.
////  Copyright © 2019 Serginjo Melnik. All rights reserved.
////
//
//import UIKit
//import RealmSwift
//import Photos
//
////trying to make a call about some changes in child to a parent
//protocol DetailViewControllerDelegate: class {
//    //this function is reload data according of changes make by user
//    func reloadTableView()
//    //General func for retreaving image by URL (BECOUSE Realm can't save images)
//    func retreaveImageForProject(myUrl: String) -> UIImage
//}
//
//class DetailViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
//    
//    //MARK: Properties
//    
//    //most for reload data
//    weak var delegate: DetailViewControllerDelegate?
//    
//    //Project Statistic Collection View
//    var myProjectData = ProjectData(frame: CGRect(x : 15 , y : 263, width: 360, height: 77))
//    //Project Steps Filter by Categories
//    var myStepCategoriesCollectionView = StepCategoriesCollectionView(frame: CGRect(x: 15, y: 340, width: 360, height: 50))
//    
//    
//    //use collection view
//    var cellId = "cellID"
//    //here creates a horizontal collectionView
//    let stepsCollectionView: UICollectionView = {
//        
//        //instance for UICollectionView purposes
//        let layout = UICollectionViewFlowLayout()
//        
//        //changing default direction of scrolling
//        layout.scrollDirection = .vertical
//        
//        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
//        // & also we need to specify how "big" it needs to be
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        
//        collectionView.backgroundColor = UIColor.clear
//        
//        //deactivate default constraints
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        
//        return collectionView
//    }()
//    
//    //Instance of Project Selected by User
//    var projectDetail: ProjectList? {
//        get{
//            //Retrieve a single object with unique identifier (projectListIdentifier)
//            return ProjectListRepository.instance.getProjectList(id: projectListIdentifier!)
//        }
//    }
//    
//    //Identifier of selected project
//    var projectListIdentifier: String?
//    
//    //Project Image created programatically
//    let projectImageView: UIImageView = {
//        let PIV = UIImageView()
//        PIV.contentMode = UIImageView.ContentMode.scaleAspectFill
//        PIV.clipsToBounds = true
//        PIV.layer.cornerRadius = 12
//        //leave like so?
//        PIV.image = UIImage(named: "workspace")
//        return PIV
//    }()
//    
//    //Outlets
//    @IBOutlet weak var projectName: UILabel!
//    @IBOutlet weak var projectNameTF: UITextField!
//    @IBOutlet weak var projectDetailDescriptionLabel: UITextView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        //I can write func for this string appending
//        //this is temporary solution, need to refactor this code..........
//        myProjectData.projectArray.append("\(projectDetail!.totalCost)$")
//        myProjectData.projectArray.append("\(projectDetail!.budget)$")
//        myProjectData.projectArray.append("\(projectDetail!.distance)km")
//        myProjectData.projectArray.append("\(projectDetail!.spending)$")
//        
//        //Passing selected project to collection view
//        myProjectData.project = projectDetail
//        
//        //assign description of the project
//        projectDetailDescriptionLabel.text = projectDetail?.comment
//        
//        //Passing URL to a func that returns image
//        if let validUrl = projectDetail?.selectedImagePathUrl {
//            //thankfully to my delegate mechanism I can path url of my project image & return image
//            projectImageView.image = self.delegate?.retreaveImageForProject(myUrl: validUrl)
//        }else{
//            //in case image wasn't selected
//            projectImageView.image = UIImage(named: "defaultImage")
//        }
//        //project image configurations
//        projectImageView.frame = CGRect(x: 16, y: 63, width: 344 , height: 110)
//        
//        
//        //Editing Project Name
//        projectNameTF.delegate = self
//        projectNameTF.isHidden = true
//        projectName.isUserInteractionEnabled = true
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelIsTapped))
//        tapGesture.numberOfTapsRequired = 1
//        projectName.addGestureRecognizer(tapGesture)
//        projectName.text = projectDetail?.name
//        
//        
//        //add subviews
//        view.addSubview(projectImageView)
//        view.addSubview(myProjectData)
//        view.addSubview(myStepCategoriesCollectionView)
//        
//        
//        // --------------------- need to refactor ------------------------------
//        view.addSubview(stepsCollectionView)
//        
//        
//        //----------------------------- not a better for collection view configuration ----------------------------------
//        
//        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
//        stepsCollectionView.dataSource = self
//        stepsCollectionView.delegate = self
//        
//        //Class is need to be registered in order of using inside
//        stepsCollectionView.register(StepsCell.self, forCellWithReuseIdentifier: cellId)
//        
//        //CollectionView constraints
//        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[v0]-15-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepsCollectionView]))
//        
//        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-403-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepsCollectionView]))
//    }
//    
//    //MARK: Collection View Section
//    
//    //size
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 167.0, height: 100)
//    }
//    //number of cells
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if let numberOfSteps = projectDetail?.steps{
//            return numberOfSteps
//        }
//        return 0
//    }
//    
//    //define the cell
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StepsCell
//        cell.layer.borderColor = UIColor.lightGray.cgColor
//        cell.layer.borderWidth = 7
//        cell.layer.cornerRadius = 12
//        
//        
//        if let projectSTEP = projectDetail?.projectStep[indexPath.row]{
//            cell.stepNameLabel.text = projectSTEP.name
//            cell.completedSwitch.isOn = projectSTEP.complete
//        }
//        cell.completedSwitch.tag = indexPath.row
//        
//        //cell.stepCompleteSwitch.addTarget(self, action: #selector(itemCompleted(sender:)), for: .valueChanged)
//        cell.completedSwitch.addTarget(self, action: #selector(itemCompleted(sender:)), for: .valueChanged)
//        
//        return cell
//    }
//    
//    //turn cells to be selectable
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    
//    //action when user selects the cell
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//    }
//    //makes cells deselectable
//    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    //define color of deselected cell
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        
//    }
//    
//    //MARK: Functions
//    @objc func itemCompleted (sender: UISwitch){
//        
//        let updatedStep = projectDetail?.projectStep[sender.tag]
//        ProjectListRepository.instance.updateStepCompletionStatus(step: updatedStep!, isComplete: sender.isOn)
//        self.stepsCollectionView.reloadData()
//        //here we call a masters (Boss) delegate function to reload its data
//        self.delegate?.reloadTableView()
//    }
//    
//    @objc func labelIsTapped(){
//        projectName.isHidden = true
//        projectNameTF.isHidden = false
//        //projectNameTF.text = projectName.text
//        projectNameTF.becomeFirstResponder()
//    }
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()// don't know where it was declared
//        projectNameTF.isHidden = true
//        projectName.isHidden = false
//        
//        //update project name
//        if let text = projectNameTF.text {
//            if !text.isEmpty{
//                projectName.text = text
//                ProjectListRepository.instance.updateProjectName(name: text, list: projectDetail!)
//                self.delegate?.reloadTableView()
//            }else{
//                print("Text Field is Empty!!!")
//            }
//        }
//        return true
//    }
//    
//    //MARK: Actions
//    //pergorm segue to new step VC
//    @IBAction func addStep(_ sender: UIStoryboardSegue) {}
//    
//    @IBAction func unwindDetailViewController(sender: UIStoryboardSegue){// !!!--- NAME == TARGET ----!!!
//        let newIndexPath = IndexPath(row: projectDetail!.projectStep.count - 1, section: 0)
//        stepsCollectionView.insertItems(at: [newIndexPath])
//    }
//    
//    //passing tapped cell identifier to NewStepVC
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "AddStep" {
//            //Passing projectListIdentifier to NewStepViewController
//            let destinationVC = segue.destination as! NewStepViewController
//            destinationVC.uniqueID = projectListIdentifier!
//        }
//    }
//    
//    //back to previous view
//    @IBAction func backAction(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//    }
//    
//}
//
//class StepsCell: UICollectionViewCell{
//    
//    //initializers
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        setupViews()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    let stepNameLabel: UILabel = {
//        let label = UILabel()
//        label.text = "some text"
//        label.font = UIFont.systemFont(ofSize: 15)
//        label.textColor = UIColor.darkGray
//        return label
//    }()
//    
//    let completedSwitch: UISwitch = {
//        let swtch = UISwitch()
//        return swtch
//    }()
//    
//    func setupViews(){
//        //backgroundColor = UIColor.yellow
//        addSubview(stepNameLabel)
//        addSubview(completedSwitch)
//        
//        stepNameLabel.frame = CGRect(x: 18, y: 5, width: frame.width, height: 40)
//        completedSwitch.frame = CGRect(x: 18, y: 40, width: 49, height: 31)
//    }
//}
