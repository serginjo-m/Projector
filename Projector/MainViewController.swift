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

class ProjectViewController: UIViewController, DetailViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    //an instance of project detail vc
    let projectDetailViewController = DetailViewController()
    
    var recentActivitiesCV = RecentActivitiesCollectionView()
    var viewByCategoryCV = ViewByCategoryCollectionView()
    var statisticsStackView = StatisticsStackView()
    
    //MARK: Properties
    var proJects: Results<ProjectList> {//This property is actually get updated version of my project list
        get {
            return ProjectListRepository.instance.getProjectLists()
        }
    }
    
    //MARK: Properties
    let cellID = "cellId"
    
    //here creates a horizontal collectionView inside stackView
    let projectsCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        collectionView.backgroundColor = UIColor.clear
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    //MARK: Methods
    func setupProjectCollectionView(){
        
        // Add a collectionView to the stackView
        recentProjectsStackView.addSubview(projectsCollectionView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        projectsCollectionView.dataSource = self
        projectsCollectionView.delegate = self
        
        projectsCollectionView.showsHorizontalScrollIndicator = false
        projectsCollectionView.showsVerticalScrollIndicator = false
        
        
        //Class is need to be registered in order of using inside
        projectsCollectionView.register(ProjectCell.self, forCellWithReuseIdentifier: cellID)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": projectsCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": projectsCollectionView]))
        
    }
    
    //container for all items on the page
    var scrollViewContainer = UIScrollView()
    var contentUIView = UIView()
    
    //stack view for recent projects collection view
    var recentProjectsStackView = UIStackView()
    
    //Profile Button
    var userProfileButton: UIButton = {
        let button = UIButton()
        button.layer.backgroundColor = UIColor.yellow.cgColor
        button.layer.cornerRadius = 18
        let image = UIImage(named: "profile")
        button.setImage(image, for: .normal)
        button.contentMode = .center
        button.clipsToBounds = true
        return button
    }()
    
    //Titles
    var mainTitle: UILabel = {
        let label = UILabel()
        label.text = "Hi Sergiy. Let's do it today!"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.init(red: 101/255, green: 101/255, blue: 101/255, alpha: 1)
        return label
    }()

    var projectsTitle: UILabel = {
        let label = UILabel()
        label.text = "Your Projects "
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var recentActivitiesTitle: UILabel = {
        let label = UILabel()
        label.text = "Recent Activities"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var viewByCategoryTitle: UILabel = {
        let label = UILabel()
        label.text = "View By Category"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var statisticsTitle: UILabel = {
        let label = UILabel()
        label.text = "Statistics"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    
    
    //I realy don't know how it works, but maybe that is solution
    //to my issue with camera roll access
    // seems it speed up loading?
    let status = PHPhotoLibrary.authorizationStatus()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //don't know if it helps with camera roll access for app
        if status == .notDetermined  {
            PHPhotoLibrary.requestAuthorization({status in})
        }
        
        //include number of projects to the title text
        projectsTitle.text = "Your Projects (\(proJects.count))"

        
        //temporary location
        //adjust scroll view
        
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        contentUIView.addSubview(mainTitle)
        contentUIView.addSubview(projectsTitle)
        contentUIView.addSubview(recentProjectsStackView)
        contentUIView.addSubview(userProfileButton)
        contentUIView.addSubview(recentActivitiesTitle)
        contentUIView.addSubview(recentActivitiesCV)
        contentUIView.addSubview(viewByCategoryTitle)
        contentUIView.addSubview(viewByCategoryCV)
        contentUIView.addSubview(statisticsTitle)
        contentUIView.addSubview(statisticsStackView)
        //setup constraints
        setupLayout()
        
        //setup recent projects collection view
        setupProjectCollectionView()
        
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        statisticsStackView.progressAnimation()
    }
    
    //open new step VC
    @objc func addNewProject(_ sender: Any){
        show(NewProjectViewController(), sender: sender)
    }
    
    
    
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return proJects.count
    }
    
    //don't know what was an issue with index path, but it works right now!?
    //defining what actually our cell is
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ProjectCell
        //data for every project cell
        cell.template = proJects[indexPath.item]
        
        //image configuration
        if let validUrl = proJects[indexPath.item].selectedImagePathUrl{
            cell.projectImage.image = retreaveImageForProject(myUrl: validUrl)
        }else{
            cell.projectImage.image = UIImage(named: "defaultImage")
        }
        //configure delete feature
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(deleteProject(button:)), for: .touchUpInside)
        return cell
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 188, height: recentProjectsStackView.frame.height)
    }
    //action when user selects the cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //search step by sected item index
        let selectedProject = proJects[indexPath.row]
        projectDetailViewController.projectListIdentifier = selectedProject.id
        projectDetailViewController.delegate = self
        navigationController?.pushViewController(projectDetailViewController, animated: true)
    }
    
    //delete project function
    @objc func deleteProject(button: UIButton){
        
        //create new alert window
        let alertVC = UIAlertController(title: "Delete Project", message: "Are You sure want delete this project?", preferredStyle: .alert)
        //cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        //delete button
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
            //remove project from database
            ProjectListRepository.instance.deleteProjectList(list: self.proJects[button.tag])
            //reload view
            self.reloadTableView()
        })
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(deleteAction)
        //shows an alert window
        present(alertVC, animated: true, completion: nil)
    }
    
    // it is a required part of delegate mechanism (Boss)
    func reloadTableView() {
        //projects collection view reload data
        self.projectsCollectionView.reloadData()

        //update number of projects in projects CV title
        projectsTitle.text = "Your Projects (\(proJects.count))"
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
    
    //perforn all positioning configurations
    private func setupLayout(){
        
        //becouse by default it is black
        view.backgroundColor = .white
        
        mainTitle.translatesAutoresizingMaskIntoConstraints = false
        projectsTitle.translatesAutoresizingMaskIntoConstraints = false
        scrollViewContainer.translatesAutoresizingMaskIntoConstraints = false
        contentUIView.translatesAutoresizingMaskIntoConstraints = false
        recentProjectsStackView.translatesAutoresizingMaskIntoConstraints = false
        userProfileButton.translatesAutoresizingMaskIntoConstraints = false
        recentActivitiesTitle.translatesAutoresizingMaskIntoConstraints = false
        recentActivitiesCV.translatesAutoresizingMaskIntoConstraints = false
        viewByCategoryTitle.translatesAutoresizingMaskIntoConstraints = false
        viewByCategoryCV.translatesAutoresizingMaskIntoConstraints = false
        statisticsTitle.translatesAutoresizingMaskIntoConstraints = false
        statisticsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        statisticsStackView.topAnchor.constraint(equalTo: statisticsTitle.bottomAnchor, constant: 0).isActive = true
        statisticsStackView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        statisticsStackView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        statisticsStackView.heightAnchor.constraint(equalToConstant: 192).isActive = true
        
        statisticsTitle.topAnchor.constraint(equalTo: viewByCategoryCV.bottomAnchor, constant: 0).isActive = true
        statisticsTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        statisticsTitle.widthAnchor.constraint(equalToConstant: 200).isActive = true
        statisticsTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        viewByCategoryCV.topAnchor.constraint(equalTo: viewByCategoryTitle.bottomAnchor, constant: 0).isActive = true
        viewByCategoryCV.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        viewByCategoryCV.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: 0).isActive = true
        viewByCategoryCV.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        viewByCategoryTitle.topAnchor.constraint(equalTo: recentActivitiesCV.bottomAnchor, constant: 0).isActive = true
        viewByCategoryTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        viewByCategoryTitle.widthAnchor.constraint(equalToConstant: 200).isActive = true
        viewByCategoryTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        recentActivitiesCV.topAnchor.constraint(equalTo: recentActivitiesTitle.bottomAnchor, constant: 0).isActive = true
        recentActivitiesCV.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        recentActivitiesCV.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        recentActivitiesCV.heightAnchor.constraint(equalToConstant: 109).isActive = true
        
        recentActivitiesTitle.topAnchor.constraint(equalTo: recentProjectsStackView.bottomAnchor, constant: 0).isActive = true
        recentActivitiesTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        recentActivitiesTitle.widthAnchor.constraint(equalToConstant: 200).isActive = true
        recentActivitiesTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        userProfileButton.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 10).isActive = true
        userProfileButton.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        userProfileButton.widthAnchor.constraint(equalToConstant: 37).isActive = true
        userProfileButton.heightAnchor.constraint(equalToConstant: 37).isActive = true
        
        mainTitle.centerYAnchor.constraint(equalTo: userProfileButton.centerYAnchor, constant: 0).isActive = true
        mainTitle.leftAnchor.constraint(equalTo: userProfileButton.rightAnchor, constant: 15).isActive = true
        mainTitle.widthAnchor.constraint(equalToConstant: 250).isActive = true
        mainTitle.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
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
        
        projectsTitle.topAnchor.constraint(equalTo: userProfileButton.bottomAnchor, constant: 20).isActive = true//constant: 20
        projectsTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        projectsTitle.widthAnchor.constraint(equalToConstant: 200).isActive = true
        projectsTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        recentProjectsStackView.topAnchor.constraint(equalTo: projectsTitle.bottomAnchor, constant: 0).isActive = true
        recentProjectsStackView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        recentProjectsStackView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor).isActive = true
        recentProjectsStackView.heightAnchor.constraint(equalToConstant: 267).isActive = true
    }
}

class ProjectCell: UICollectionViewCell{
    
    //It'll be like a template for our cell
    var template: ProjectList? {
        //didSet uses for logic purposes!
        didSet{
            
            if let name = template?.name {
                projectName.text = name
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 8
        layer.masksToBounds = true
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    let projectName:UILabel = {
        let pn = UILabel()
        pn.text = "Travel to Europe on Motorcycle"
        pn.textAlignment = NSTextAlignment.left
        pn.font = UIFont.boldSystemFont(ofSize: 15)
        pn.textColor = UIColor.white
        pn.numberOfLines = 3
        return pn
    }()
    
    let projectImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "interior")
        image.contentMode = .scaleAspectFill
        return image
    }()
    //adds contrast to project title
    let gradient: CAGradientLayer =  {
        let gradient = CAGradientLayer()
        let topColor = UIColor.init(red: 1/255, green: 1/255, blue: 1/255, alpha: 0).cgColor//black transparent
        let middleColor = UIColor.init(red: 1/255, green: 1/255, blue: 1/255, alpha: 0.16).cgColor//black 16% opacity
        let bottomColor = UIColor.init(red: 2/255, green: 2/255, blue: 2/255, alpha: 0.56).cgColor//black 56% opacity
        gradient.colors = [topColor, middleColor, bottomColor]
        gradient.locations = [0.0, 0.5, 1.0]
        return gradient
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"projectRemoveButton"), for: .normal)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    func setupViews(){
        
        
        backgroundColor = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1)
        
        //deleteButton.frame = CGRect(x:frame.width - 25, y: 9, width:16, height: 16)
        
        addSubview(projectImage)
        addSubview(projectName)
        
        
        //gradient under project title
        layer.insertSublayer(gradient, at: 2)
        gradient.frame = CGRect(x: 0, y: 188, width: frame.width, height: frame.height - 188)
        
        addSubview(deleteButton)
        
        projectName.translatesAutoresizingMaskIntoConstraints = false
        projectImage.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        deleteButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 11).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -11).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        projectName.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        projectName.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 13).isActive = true
        projectName.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        projectName.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        projectImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        projectImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        projectImage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        projectImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
    }
}
