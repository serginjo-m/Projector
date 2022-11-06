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
import Firebase
import FirebaseCore

class ProjectViewController: UIViewController, DetailViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CircleTransitionable  {
    
    //global database reference
    var ref: DatabaseReference?
    
    //MARK: Properties
    //user defines title format
    var user: User?

    //animation required
    var mainView: UIView {
        return view
    }
    
    lazy var recentActivitiesCV: RecentActivitiesCollectionView = {
        let collectionView = RecentActivitiesCollectionView()
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandRecentActivity(_:))))
        return collectionView
    }()
    
    //constraints animation approach
    var maxTopAnchor: NSLayoutConstraint?
    var minTopAnchor: NSLayoutConstraint?
    var maxHeightAnchor: NSLayoutConstraint?
    var minHeightAnchor: NSLayoutConstraint?
    
    
    lazy var viewByCategoryCV: ViewByCategoryCollectionView = {
        let category = ViewByCategoryCollectionView()
        category.delegate = self
        return category
    }()

    var statisticsStackView = StatisticsStackView()
    
    var projects: Results<ProjectList> {//This property is actually get updated version of my project list
        get {
            return ProjectListRepository.instance.getProjectLists()
        }
        set {
            //update!
        }
    }
    
    //Widget data source & to find out: is object already exist or need to create new one
    var dayActivities: Results<DayActivity> {
        get {
            return ProjectListRepository.instance.getDayActivities()
        }
    }

    let cellID = "cellId"
    
    //container for all items on the page
    var scrollViewContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    var contentUIView = UIView()
    
    //stack view for recent projects collection view
    var recentProjectsStackView = UIStackView()
    
    lazy var noProjectsBannerView: NoProjectsBannerView = {
        let view = NoProjectsBannerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentViewController)))
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.isHidden = projects.count == 0 ? false : true
        return view
    }()
    
    //Profile Button
    lazy var transitionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.init(white: 55/255, alpha: 1)
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(openProfileSettings), for: .touchUpInside)
        button.setImage(UIImage(named: "settings"), for: .normal)
        button.contentMode = .center
        button.clipsToBounds = true
        return button
    }()
    //Titles
    var contentTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.boldSystemFont(ofSize: 18)
        textView.textColor = UIColor.init(white: 55/255, alpha: 1)
        textView.isEditable = false
        return textView
    }()

    var projectsTitle: UILabel = {
        let label = UILabel()
        label.text = "Your Projects "
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var recentActivitiesTitle: UILabel = {
        let label = UILabel()
        label.text = "Last 30 Days Activity"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var viewByCategoryTitle: UILabel = {
        let label = UILabel()
        label.text = "Quick Notes"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var statisticsTitle: UILabel = {
        let label = UILabel()
        label.text = "Progress"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    //here creates a horizontal collectionView inside stackView
    let projectsCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        //because every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        collectionView.backgroundColor = UIColor.clear
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    
    // maybe that is solution to my issue with camera roll access
    // seems it speed up loading?
    let status = PHPhotoLibrary.authorizationStatus()
    
    //MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set global database url reference
        self.ref = Database.database(url: "https://projectorfirebase-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        
        //Camera
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                //access granted
            }
        }
        
        //helps with camera roll access for app
        if status == .notDetermined  {
            PHPhotoLibrary.requestAuthorization({status in})
        }
        
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        contentUIView.addSubview(recentProjectsStackView)
        contentUIView.addSubview(noProjectsBannerView)
        contentUIView.addSubview(contentTextView)
        contentUIView.addSubview(projectsTitle)
        contentUIView.addSubview(transitionButton)
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
        projects = ProjectListRepository.instance.getProjectLists()
        
        self.projectsCollectionView.reloadData()
        
        //include number of projects to the title text
        projectsTitle.text = "Your Projects (\(projects.count))"
        //hide or reveal noProjetsBannerView if there is no project for now
        noProjectsBannerView.isHidden = projects.count == 0 ? false : true
        //if user is logged in update view controllers title
        checkUserProfile()
        //transition progress inside statistics widget
        statisticsStackView.progressAnimation()
        
        //dayActivity object for today
        createDayActivity()
        //check if app is lounch for the first time, so intro view controller shows
        isAppAlreadyLaunchedOnce()
    }
    
    //MARK: Methods
    //this func is for elements that have no access to navigation controller
    func pushToViewController(controllerType: Int){
        
        let viewController = viewControllerType(for: controllerType)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func viewControllerType(for contollerType: Int) -> UIViewController {
        
        switch contollerType {
        case 0:
            return PhotoNotesCollectionViewController()//photo note
        case 1:
            return CanvasNotesCollectionViewController()//canvas note
        case 2:
            return TextNotesCollectionViewController()// text note
        default:
            return UIViewController()
        }
        
    }
    
    fileprivate func checkUserProfile(){
        
        //check if user exist in database or logout
        let users = ProjectListRepository.instance.getAllUsers()
        if users.count > 0 {
            
            user = users.first
            guard let user = user else {return}
            contentTextView.text = "Hello \(user.name)!"
        }else if users.count == 0 {
            user = nil
            contentTextView.text = "Hi there! Let's start projecting."
        }
    }
    //transition to profile VC with custom animation
    @objc func openProfileSettings(){
        if let navController = navigationController{
            let transitionCoordinator = TransitionCoordinator()
            navController.delegate = transitionCoordinator
            let userProfileVC = UserProfileViewController()
            navController.pushViewController(userProfileVC, animated: true)
        }
    }
    
    @objc func presentViewController(){
        let newProjectViewController = NewProjectViewController()
        newProjectViewController.modalPresentationStyle = .fullScreen
        present(newProjectViewController, animated: true)
    }
    
    //user activity object for today
    func createDayActivity (){
        
        //---------------------------------------------------------------------------------------------------
        //Here I want to have a logic that keep my database up to 30 items
        //---------------------------------------------------------------------------------------------------
        
        //keep recent activities CV always updated
        recentActivitiesCV.collectionViewDataSource = self.dayActivities
        recentActivitiesCV.recentActivitiesCollectionView.reloadData()
        
        //create day string == to object day string
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let dayString = formatter.string(from: Date())
        //check if there is already object with current date
        for day in dayActivities{
            if day.date == dayString{
                //if object was created today, set shared class to it
                UserActivitySingleton.shared.currentDayActivity = day
                return
            }
        }
        
        //create new DayActivity instance
        UserActivitySingleton.shared.currentDayActivity = DayActivity()
        //set date to current date
        UserActivitySingleton.shared.currentDayActivity.date = dayString
        //save it to data base
        ProjectListRepository.instance.createDayActivity(dayActivity: UserActivitySingleton.shared.currentDayActivity)
        
    }
    
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
    
    //recent activity tap animation
    @objc func expandRecentActivity(_ sender: UITapGestureRecognizer){
        
        guard let minHeight = minHeightAnchor else {return}
        if minHeight.isActive == true{
            //ORDER REQUIRED, else constraints error
            minTopAnchor?.isActive = false
            minHeightAnchor?.isActive = false
            maxHeightAnchor?.isActive = true
            maxTopAnchor?.isActive = true
            
            //open state width
            self.recentActivitiesCV.visualLayoutConstraints.featuredWidth = 250
            self.recentActivitiesCV.visualLayoutConstraints.standardWidth = 20
            
        }else{
            //ORDER REQUIRED, else constraints error
            maxHeightAnchor?.isActive = false
            maxTopAnchor?.isActive = false
            minTopAnchor?.isActive = true
            minHeightAnchor?.isActive = true
            
            //close state width
            self.recentActivitiesCV.visualLayoutConstraints.featuredWidth = 54
            self.recentActivitiesCV.visualLayoutConstraints.standardWidth = 54
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    //open new project VC
    @objc func addNewProject(_ sender: Any){
        show(NewProjectViewController(), sender: sender)
    }
    
    //delete project function
    @objc func deleteProject(button: UIButton){
        
        //create new alert window
        let alertVC = UIAlertController(title: "Delete Project", message: "Are You sure want delete this project?", preferredStyle: .alert)
        //cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        //delete button
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
            
            UserActivitySingleton.shared.createUserActivity(description: "\(self.projects[button.tag].name) was removed")
            //remove project from database
            ProjectListRepository.instance.deleteProjectList(list: self.projects[button.tag])
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
        projectsTitle.text = "Your Projects (\(projects.count))"
        //hide or reveal noProjetsBannerView if there is no project for now
        noProjectsBannerView.isHidden = projects.count == 0 ? false : true
        //update progress widget
        statisticsStackView.progressAnimation()
    }
    
    //return UIImage by URL
    func retreaveImageForProject(myUrl: String) -> UIImage{
        var projectImage: UIImage = UIImage(named: "scheduledStepEvent")!
        let url = URL(string: myUrl)
        let data = try? Data(contentsOf: url!)
        if let imageData = data{
            projectImage = UIImage(data: imageData)!
        }
        return projectImage
    }
    
    //MARK: Collection View Section
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projects.count
    }
    
    //don't know what was an issue with index path, but it works right now!?
    //defining what actually our cell is
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ProjectCell
        //data for every project cell
        cell.template = projects[indexPath.item]
        
        //image configuration
        if let validUrl = projects[indexPath.item].selectedImagePathUrl{
            cell.projectImage.image = retreaveImageForProject(myUrl: validUrl)
        }else{
            cell.projectImage.image = UIImage(named: "scheduledStepEvent")
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
        
        //an instance of project detail vc
        let projectDetailViewController = DetailViewController()
        //search step by sected item index
        let selectedProject = projects[indexPath.item]
        projectDetailViewController.projectListIdentifier = selectedProject.id
        projectDetailViewController.delegate = self
        navigationController?.pushViewController(projectDetailViewController, animated: true)
    }
    
    
    
    //MARK: Constraints
    //perforn all positioning configurations
    private func setupLayout(){
        
        //because by default it is black
        view.backgroundColor = .white
        
        [contentTextView, projectsTitle, scrollViewContainer, contentUIView, recentProjectsStackView, transitionButton, recentActivitiesTitle, recentActivitiesCV, viewByCategoryTitle, viewByCategoryCV, statisticsTitle, statisticsStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        scrollViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollViewContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollViewContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        contentUIView.topAnchor.constraint(equalTo: scrollViewContainer.topAnchor).isActive = true
        contentUIView.leftAnchor.constraint(equalTo: scrollViewContainer.leftAnchor).isActive = true
        contentUIView.rightAnchor.constraint(equalTo: scrollViewContainer.rightAnchor).isActive = true
        contentUIView.bottomAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor).isActive = true
        contentUIView.widthAnchor.constraint(equalTo: scrollViewContainer.widthAnchor).isActive = true
        contentUIView.heightAnchor.constraint(equalToConstant: 920).isActive = true
        
        //animation approach
        minTopAnchor = recentActivitiesCV.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 433)
        minHeightAnchor = recentActivitiesCV.heightAnchor.constraint(equalToConstant: 109)
        
        maxTopAnchor = recentActivitiesCV.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15)
        maxHeightAnchor = recentActivitiesCV.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        
        recentActivitiesCV.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        recentActivitiesCV.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        
        minTopAnchor?.isActive = true
        minHeightAnchor?.isActive = true
        
        recentActivitiesTitle.bottomAnchor.constraint(equalTo: recentActivitiesCV.topAnchor, constant: -11).isActive = true
        recentActivitiesTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        recentActivitiesTitle.widthAnchor.constraint(equalToConstant: 200).isActive = true
        recentActivitiesTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        
        
        statisticsStackView.topAnchor.constraint(equalTo: statisticsTitle.bottomAnchor, constant: 0).isActive = true
        statisticsStackView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        statisticsStackView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        statisticsStackView.heightAnchor.constraint(equalToConstant: 192).isActive = true
        
        statisticsTitle.topAnchor.constraint(equalTo: viewByCategoryCV.bottomAnchor, constant: 0).isActive = true
        statisticsTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        statisticsTitle.widthAnchor.constraint(equalToConstant: 200).isActive = true
        statisticsTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        viewByCategoryCV.topAnchor.constraint(equalTo: viewByCategoryTitle.bottomAnchor, constant: 11).isActive = true
        viewByCategoryCV.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        viewByCategoryCV.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: 0).isActive = true
        viewByCategoryCV.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        viewByCategoryTitle.topAnchor.constraint(equalTo: recentActivitiesCV.bottomAnchor, constant: 11).isActive = true
        viewByCategoryTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        viewByCategoryTitle.widthAnchor.constraint(equalToConstant: 200).isActive = true
        viewByCategoryTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
    
        transitionButton.bottomAnchor.constraint(equalTo: projectsTitle.topAnchor, constant: -29).isActive = true
        transitionButton.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        transitionButton.widthAnchor.constraint(equalToConstant: 37).isActive = true
        transitionButton.heightAnchor.constraint(equalToConstant: 37).isActive = true
                
        contentTextView.centerYAnchor.constraint(equalTo: transitionButton.centerYAnchor, constant: 0).isActive = true
        contentTextView.leftAnchor.constraint(equalTo: transitionButton.rightAnchor, constant: 5).isActive = true
        contentTextView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: 0).isActive = true
        contentTextView.heightAnchor.constraint(equalToConstant: 37).isActive = true
        
        projectsTitle.bottomAnchor.constraint(equalTo: recentProjectsStackView.topAnchor, constant: -11).isActive = true//constant: 20
        projectsTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        projectsTitle.widthAnchor.constraint(equalToConstant: 200).isActive = true
        projectsTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        recentProjectsStackView.bottomAnchor.constraint(equalTo: recentActivitiesTitle.topAnchor, constant: -11).isActive = true
        recentProjectsStackView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        recentProjectsStackView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor).isActive = true
        recentProjectsStackView.heightAnchor.constraint(equalToConstant: 267).isActive = true
        
        noProjectsBannerView.topAnchor.constraint(equalTo: recentProjectsStackView.topAnchor).isActive = true
        noProjectsBannerView.bottomAnchor.constraint(equalTo: recentProjectsStackView.bottomAnchor).isActive = true
        noProjectsBannerView.leadingAnchor.constraint(equalTo: recentProjectsStackView.leadingAnchor).isActive = true
        noProjectsBannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
    }
}

extension ProjectViewController {
    
    func isAppAlreadyLaunchedOnce(){
        
        let defaults = UserDefaults.standard
        
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce") {
//
////           app is already launched once!
//            let layout = UICollectionViewFlowLayout()
//            layout.scrollDirection = .horizontal
//
//            let swipingController = SwipingController(didTapDismissCompletionHandler: { [weak self] in
//                guard let self = self else {return}

                
                //MARK: SAILSJS
//                Service.shared.fetchUserProfile { (res) in
//                    switch res {
//                    case .success(let res):
//
//                        //check for any user inside DB before creating new one
//                        let users = ProjectListRepository.instance.getAllUsers()
//                        if users.count > 0{
//                            for user in users {
//                                ProjectListRepository.instance.deleteUser(user: user)
//                            }
//                        }
//
//                        let user = User()
//                        user.name = res.fullName
//                        user.email = res.emailAddress
//                        user.isLogined = true
//
//                        ProjectListRepository.instance.createUser(user: user)
//
//                        self.user = user
//
//                        self.contentTextView.text = "Hello \(user.name)!"
//
//
//                    case .failure(let err):
//                        print("Failed to fetch user: ", err)
//
//                    }
//                }
//
//
//            }, collectionViewLayout: layout)
//
//            navigationController?.present(swipingController, animated: true, completion: nil)
            
            
        } else {
            
            //App launched first time
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            

            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal

            let swipingController = SwipingController(didTapDismissCompletionHandler: { [weak self] in
                
                
                
                //MARK: SAILSJS
//                guard let self = self else {return}
                //as user is logged in, try to fetch user from WEB, create user inside local DB an update VC elem.
//                Service.shared.fetchUserProfile { (res) in
//                    switch res {
//                    case .success(let res):
//
//                        //check and clear any user inside DB before creating new one
//                        let users = ProjectListRepository.instance.getAllUsers()
//                        if users.count > 0{
//                            for user in users {
//                                ProjectListRepository.instance.deleteUser(user: user)
//                            }
//                        }
//                        //create
//                        let user = User()
//                        user.name = res.fullName
//                        user.email = res.emailAddress
//                        user.isLogined = true
//
//                        ProjectListRepository.instance.createUser(user: user)
//                        //update user object inside VC
//                        self.user = user
//                        //update VC title
//                        self.contentTextView.text = "Hello \(user.name)!"
//
//
//                    case .failure(let err):
//                        print("Failed to fetch user: ", err)
//
//                    }
//                }
                
            }, collectionViewLayout: layout)


            navigationController?.present(swipingController, animated: true, completion: nil)
            
        }
    }
}
