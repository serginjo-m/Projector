//
//  ViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 07.11.2019.
//  Copyright © 2019 Serginjo Melnik. All rights reserved.
//
/*
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

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    //MARK: Properties
    
    //most for reload data
    weak var delegate: DetailViewControllerDelegate?
    
    //Project Statistic Collection View
    var myProjectData = ProjectData(frame: CGRect(x : 15 , y : 263, width: 360, height: 77))
    //Project Steps Filter by Categories
    var myStepCategoriesCollectionView = StepCategoriesCollectionView(frame: CGRect(x: 15, y: 340, width: 360, height: 50))
    
    
    //Identifier of selected project
    var projectListIdentifier: String?
    //Instance of Project Selected by User
    var projectDetail: ProjectList? {
        get{
            //Retrieve a single object with unique identifier (projectListIdentifier)
            return ProjectListRepository.instance.getProjectList(id: projectListIdentifier!)
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
    @IBOutlet weak var stepTableView: UITableView!//it makes appear a list
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var projectNameTF: UITextField!
    @IBOutlet weak var projectDetailDescriptionLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //I can write func for this string appending
        //this is temporary solution, need to refactor this code..........
        myProjectData.projectArray.append("\(projectDetail!.totalCost)$")
        myProjectData.projectArray.append("\(projectDetail!.budget)$")
        myProjectData.projectArray.append("\(projectDetail!.distance)km")
        myProjectData.projectArray.append("\(projectDetail!.spending)$")
        
        //Passing selected project to values collection view
        myProjectData.project = projectDetail
        
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
        //project image configurations
        projectImageView.frame = CGRect(x: 16, y: 63, width: 344 , height: 110)
        
        //assign delegate & data source
        stepTableView.delegate = self
        stepTableView.dataSource = self
        
        //Editing Project Name
        projectNameTF.delegate = self
        projectNameTF.isHidden = true
        projectName.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelIsTapped))
        tapGesture.numberOfTapsRequired = 1
        projectName.addGestureRecognizer(tapGesture)
        projectName.text = projectDetail?.name
        
        
        //add subviews
        view.addSubview(projectImageView)
        view.addSubview(myProjectData)
        view.addSubview(myStepCategoriesCollectionView)
        
    }
    
    //MARK: Functions
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
    
    //MARK: Table View Section
    
    //added for spacing between cells
    func numberOfSections(in stepTableView: UITableView) -> Int {
        return (projectDetail?.projectStep.count)!
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell" , for: indexPath) as? DetailTableViewCell else {
            fatalError( "The dequeued cell is not an instance of DetailTableViewCell." )
        }
        
        //cell configurations
        cell.roundedCellBG.layer.cornerRadius = 12.0
        cell.roundedCellBG.layer.masksToBounds = true
        cell.roundedCellBG.layer.borderColor = UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 0.1).cgColor
        cell.roundedCellBG.layer.borderWidth = 1
        
        //Here add a func to switch by using selector
        cell.stepCompleteSwitch.addTarget(self, action: #selector(itemCompleted(sender:)), for: .valueChanged)
        //to define which one has been modified
        cell.stepCompleteSwitch.tag = indexPath.section
        
        //Fetches the appropriate step for the data source layout.
        let step = self.projectDetail?.projectStep[indexPath.section]
        
        cell.stepTitle.text = step?.description
        cell.stepCompleteSwitch.isOn = (step?.complete)!
        
        //when add a new - step complete == false
        self.delegate?.reloadTableView()
        return cell
    }
    //control cell spacing height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(10)//cell spacing height
    }
    
    
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    @objc func itemCompleted (sender: UISwitch){
        let updatedStep = projectDetail?.projectStep[sender.tag]
        ProjectListRepository.instance.updateStepCompletionStatus(step: updatedStep!, isComplete: sender.isOn)
        self.tableView.reloadData()
        //here we call a masters (Boss) delegate function to reload its data
        self.delegate?.reloadTableView()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ProjectListRepository.instance.deleteProjectStep(list: projectDetail!, stepAtIndex: indexPath.section )
            self.tableView.reloadData()
            // roload data in target tableView
            self.delegate?.reloadTableView()
        }
    }
    
    //MARK: Actions
    @IBAction func addStep(_ sender: UIStoryboardSegue) {}
    
    @IBAction func unwindDetailViewController(sender: UIStoryboardSegue){// !!!--- NAME == TARGET ----!!!
        //so all this multiple changes is performs becouse:
        //row not support distance btwn cells !
        //need performBatchUpdate - multiple changes
        stepTableView.performBatchUpdates({
            //here I try to assign number of steps - 1
            let number = (projectDetail?.projectStep.count)! - 1
            //here I assign that number to IdexSet
            let indexSet = IndexSet(integer: number)
            //here I insert new section in base of number of steps
            stepTableView.insertSections( indexSet , with: .automatic)
            //here I define where I need to insert row (it is in new section but not at the same row as others)
            let newIndexPath = IndexPath(row: 0, section: (projectDetail?.projectStep.count)! - 1) //Section instead of Row
            //inseting new row
            stepTableView.insertRows(at: [newIndexPath], with: .automatic)
        }, completion: nil)
    }
    
    //passing tapped cell identifier to NewStepVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddStep" {
            //Passing projectListIdentifier to NewStepViewController
            let destinationVC = segue.destination as! NewStepViewController
            destinationVC.uniqueID = projectListIdentifier!
        }
    }
    
    //back to previous view
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
*/
