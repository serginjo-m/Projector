//
//  ProjectViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 08.11.2019.
//  Copyright © 2019 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
import Foundation
import os
import Photos


class ProjectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DetailViewControllerDelegate {

    //MARK: Properties
    var proJects: Results<ProjectList> {//This property is actually get updated version of my project list
        get {
            return ProjectListRepository.instance.getProjectLists()
        }
    }
    
    var mainTitle: UILabel = {
        let label = UILabel()
        label.text = "All Projects"
        label.font = .systemFont(ofSize: 25)
        return label
    }()
    
    //I realy don't know how it works, but maybe that is solution
    //to my issue with camera roll access
    // seems it speed up loading?
    let status = PHPhotoLibrary.authorizationStatus()
    
    @IBOutlet weak var addButton: UIButton!// +
    
    @IBOutlet var RestartedTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    let cellIdentifier = "ProjectTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //don't know if it helps with camera roll access for app
        if status == .notDetermined  {
            PHPhotoLibrary.requestAuthorization({status in})
        }
        
        RestartedTableView.delegate = self
        RestartedTableView.dataSource = self

        view.addSubview(mainTitle)
        
        //setup constraints
        setupLayout()
    }
    
    //perforn all positioning configurations
    private func setupLayout(){
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        mainTitle.translatesAutoresizingMaskIntoConstraints = false
       
        mainTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 13).isActive = true
        mainTitle.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        mainTitle.widthAnchor.constraint(equalToConstant: 400).isActive = true
        mainTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
   
        addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant:  16).isActive = true
        addButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        addButton.layer.cornerRadius = 30
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
        //get image for project
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

        return cell
    }
    
    //control cell spacing height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
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
        
        //here perform some actions...
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
