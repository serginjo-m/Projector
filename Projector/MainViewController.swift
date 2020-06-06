//
//  ProjectViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 08.11.2019.
//  Copyright © 2019 Serginjo Melnik. All rights reserved.
//

import UIKit
import os.log
import RealmSwift
import Photos


class ProjectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DetailViewControllerDelegate {

    //MARK: Properties
    var proJects: Results<ProjectList> {//This property is actually get updated version of my project list
        get {
            return ProjectListRepository.instance.getProjectLists()
        }
    }
    
    //var myProgressControl = ProgressControl(frame: CGRect(x : 20 , y : 76, width: 360, height: 210))
    var myProgressControl = ProgressControl()
    
    
    
    let cellSpacing: CGFloat = 10
    let cellIdentifier = "ProjectTableViewCell"
    
    //not sure about this approach of catching image from cell
    var cellImageView: UIImageView?
    
    @IBOutlet weak var addButton: UIButton!// +
    
    @IBOutlet var RestartedTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addButton.layer.cornerRadius = 33
        
        RestartedTableView.delegate = self
        RestartedTableView.dataSource = self
        
        //print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        view.addSubview(myProgressControl)
        
        //setup constraints
        setupLayout()
        
        
        
    }
    
    //perforn all positioning configurations
    private func setupLayout(){
        
        myProgressControl.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        myProgressControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  76).isActive = true
        myProgressControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        myProgressControl.widthAnchor.constraint(equalToConstant: 400).isActive = true
        myProgressControl.heightAnchor.constraint(equalToConstant: 209).isActive = true
        
        addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant:  -16).isActive = true
        addButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 67).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 67).isActive = true
    }
    
    //MARK: Table View Section
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return proJects.count
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier , for: indexPath) as? ProjectTableViewCell else {
            fatalError( "The dequeued cell is not an instance of ProjectTableViewCell." )
        }
        
        //cell configurations
        cell.cellBg.layer.cornerRadius = 12.0
        cell.cellBg.layer.masksToBounds = true
        
        //Fetches the appropriate project for the data source layout.
        let project = proJects[indexPath.section]//let list = lists[indexPath.row] , Section instead of Row
        
        if let validUrl = project.selectedImagePathUrl {
            cell.pictureView.image = retreaveImageForProject(myUrl: validUrl)
        }else{
            cell.pictureView.image = UIImage(named: "defaultImage")
        }
        
    
        cell.pictureView.layer.cornerRadius = 12.0
        cell.pictureView.layer.masksToBounds = true
        
        cell.nameLabel.text = project.name
        cell.categoryLabel.text = project.category
        cell.dateLabel.text = "\(project.distance) km"
        cell.descriptionLabel.text = project.comment
        //cell.pictureView.image = project.image
        
        return cell
        
    }
    
    //control cell spacing height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return cellSpacing
    }
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let proj = proJects[indexPath.section]//Section instead of Row
            //delete selected project
            ProjectListRepository.instance.deleteProjectList(list: proj)
            
            self.tableView.reloadData()
            reloadTableView()
        }
    }
    
    // it is a required part of delegate mechanism (Boss)
    func reloadTableView() {
        self.tableView.reloadData()
        myProgressControl.progressCollectionView.reloadData()
    }
    
    //return UIImage by URL
    func retreaveImageForProject(myUrl: String) -> UIImage{
        var projectImage: UIImage = UIImage(named: "defaultImage")!
        let url = URL(string: myUrl)
        let data = try? Data(contentsOf: url!)
        if let imageData = data{
            projectImage = UIImage(data: imageData)!
        }
        return projectImage
    }
    
    
    // MARK: Segues
    @IBAction func unwindToProjectList(sender: UIStoryboardSegue){// !!!--- NAME == TARGET ----!!!
        //so all this multiple changes is performs becouse:
        //row not support distance btwn cells !
        //need performBatchUpdate - multiple changes
        tableView.performBatchUpdates({
            //find a target indexSet my counting number of projects - 1
            let number = (proJects.count - 1)
            //here I assign that number to IdexSet
            let indexSet = IndexSet(integer: number)
            ////here I insert new section in base of number of steps
            tableView.insertSections(indexSet, with: .automatic)
            //here I define where I need to insert row (it is in new section but not at the same row as always)
            let newIndexPath = IndexPath(row: 0, section: proJects.count - 1)
            //inseting new row
            tableView.insertRows( at: [newIndexPath] , with: .automatic)
        }, completion: nil)
        
        let indexPath = IndexPath(row: proJects.count - 1, section: 0)
        myProgressControl.progressCollectionView.insertItems(at: [indexPath])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail"{
            if let indexPath = tableView.indexPathForSelectedRow{
                let selectedProject = proJects[indexPath.section]
                let controller = segue.destination as! DetailViewController
                controller.delegate = self// am I need this? // the answer is YES!! Becouse it is a part of a delegate mechanism
                controller.projectListIdentifier = selectedProject.id
            }
            
        }
    }
    
}
