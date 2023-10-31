//
//  CustomTabBarController.swift
//  Projector
//
//  Created by Serginjo Melnik on 31.10.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
import Photos
//MARK: OK
class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    //MARK: Properties
    
    var photoLibraryStatus = PHPhotoLibrary.authorizationStatus()
    
    //date as a starting point for the calendar
    let date = Date()
    
    //list of holidays received from the server
    var listOfHolidays = [HolidayDetail](){
        didSet{
            DispatchQueue.main.async {
                //creates grouped holidays dictionary
                self.convertHolidaysToEvents()
            }
        }
    }
    
    //get ALL events, to check, if database contains previously downloaded holidays from the server
    var events: Results<Event>{
        get{
            return ProjectListRepository.instance.getEvents()
        }
        set{
            //update
        }
    }
    
    lazy var popoverMessageView: PopoverMessageView = {
        let view = PopoverMessageView()
        view.frame = CGRect(x: (self.view.frame.width / 2) - 125, y: self.view.frame.height , width: 250, height: 50)
        return view
    }()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        
        //check if data was downloaded
        downloadHolidayEvents()
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        } else {
            //
        }
        
        self.delegate = self
        
        viewControllers = [
            createNavControllerWithTitle(viewController: ProjectViewController(), title: "Home", imageName: "home"),
            createCalendarViewController(),
            createNavControllerWithTitle(viewController: NewProjectViewController(), title: "Add", imageName: "addButton"),
            
            //with this type of init I can pass different type of layout (Pinterest or default)
            createNavControllerWithTitle(viewController: StatisticsViewController(), title: "Spendings", imageName: "money"),
            createNavControllerWithTitle(viewController: NotificationsViewController(), title: "Notifications", imageName: "bell")
        ]
    }
    
    override func viewDidLayoutSubviews() {
        
        if let keyWindow = UIApplication.shared.keyWindow{
            keyWindow.addSubview(popoverMessageView)
        }
    }
    
    //MARK: Methods
    
    private func showPermissionAlert(){
        let ac = UIAlertController(title: "Access to Photo Library is Denied", message: "To turn on access to photo library, please go to Settings > Notifications > Projector", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }
    
    fileprivate func configureCanvasViewController(){
        let newCanvasNoteVC = CanvasViewController()
        newCanvasNoteVC.modalTransitionStyle = .coverVertical
        newCanvasNoteVC.modalPresentationStyle = .overCurrentContext
        let viewControllers = ["Create Canvas Note": newCanvasNoteVC]
        configureAddItemAction(newObjectVC: viewControllers)
    }
    
    func configureAddItemAction(newObjectVC: [String: UIViewController]){
        let alert = UIAlertController(title: "Select Creation Type", message: "Please select the desired creation type", preferredStyle: .actionSheet)
        for (key, value) in newObjectVC {
            let action = UIAlertAction(title: key, style: .default) { (action: UIAlertAction) in
                //so view did appear update detail view controller
                value.modalPresentationStyle = .fullScreen
                self.present(value, animated: true, completion: nil)
            }
            alert.addAction(action)
        }
        
        let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            //
        }
        alert.addAction(action3)
        present(alert, animated: true, completion: nil)
    }
    
    private func createCalendarViewController() -> UINavigationController {
        let calendarViewController = CalendarViewController(baseDate: date) { (date) in
            //
        }
        return createNavControllerWithTitle(viewController: calendarViewController, title: "Calendar", imageName: "calendarIcon")
    }
    
    private func createNavControllerWithTitle(viewController: UIViewController, title: String, imageName: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: viewController)
        navController.setNavigationBarHidden(true, animated: false)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
    }
    
    private func handlePopoverMessageAnimation(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.popoverMessageView.frame = CGRect(x: (self.view.frame.width / 2) - 125, y: self.view.frame.height - 170, width: 250, height: 50)
        }) { completed in
            UIView.animate(withDuration: 0.5, delay: 1, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut) {
                self.popoverMessageView.frame = CGRect(x: (self.view.frame.width / 2) - 125, y: self.view.frame.height, width: 250, height: 50)
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        //get index of selected value
        guard let index = viewControllers?.firstIndex(of: viewController) else {
            return false
        }
        
        // index == 2 (add button)
        if index == 2 {
            
            //get the currently displaying ViewController
            guard let currentViewController = (self.selectedViewController as! UINavigationController).topViewController else {return false}
            
            //class identifier for logic purposes
            var lastVCClass: String = ""
            
            lastVCClass = "\(currentViewController.classForCoder)"
            //apply logic based on the last displayed ViewController class
            switch lastVCClass {
                
            case "PhotoNotesCollectionViewController":
                let newPhotoNoteVC = CameraShot()
                newPhotoNoteVC.modalTransitionStyle = .coverVertical
                newPhotoNoteVC.modalPresentationStyle = .overCurrentContext
                let viewControllers = ["Create Photo Note": newPhotoNoteVC]
                configureAddItemAction(newObjectVC: viewControllers)
                
            case "CanvasNotesCollectionViewController":
                
                switch self.photoLibraryStatus {
                case .authorized:
                    
                    configureCanvasViewController()
                    
                case .denied:
                    showPermissionAlert()
                case .notDetermined:
                    PHPhotoLibrary.requestAuthorization({status in
                        self.photoLibraryStatus = status
                        
                        if self.photoLibraryStatus == .authorized {
                            DispatchQueue.main.async {
                                self.configureCanvasViewController()
                            }
                        }
                    })
                case .restricted:
                    print("restricted")
                    // probably alert the user that photo access is restricted
                case .limited:
                    print("limited")
                @unknown default:
                    print("unknown case!")
                }
                
            case "TextNotesCollectionViewController":
                let newTextNoteVC = TextNoteViewController()
                newTextNoteVC.modalTransitionStyle = .coverVertical
                newTextNoteVC.modalPresentationStyle = .overCurrentContext
                let viewControllers = ["Create Text Note": newTextNoteVC]
                configureAddItemAction(newObjectVC: viewControllers)
                
            case "DetailViewController":
                
                guard let detailVC = currentViewController as? DetailViewController else {return false}
                
                //because case: DetailViewController,I can access its properties to perform modifications.
                //let currentViewControllerId = ((self.selectedViewController as! UINavigationController).topViewController as! DetailViewController).projectListIdentifier ?? ""
                
                let newStep = NewStepViewController()
                newStep.projectId = detailVC.projectListIdentifier
                
                let viewControllers = [
                    "Create New Step": newStep
                ]
                
                configureAddItemAction(newObjectVC: viewControllers)
                
            case "ProjectViewController":
            
                //create it out of Dictionary
                let newProjectViewController = NewProjectViewController()
                //Dictionary ["view controller name" : viewController]
                let viewControllers = [
                    "New Project": newProjectViewController
                ]
                //configure appearance
                for (_, value) in viewControllers{
                    value.modalTransitionStyle = .coverVertical
                    value.modalPresentationStyle = .overCurrentContext
                }
                configureAddItemAction(newObjectVC: viewControllers)
                
            case "StepViewController":
                
                guard let stepVC = currentViewController as? StepViewController else {return false}
                
                let newStepItemViewController = StepItemViewController()
                newStepItemViewController.stepID = stepVC.stepID
                
                let viewControllers = [
                    "Create Step Item" : newStepItemViewController
                ]
                
                configureAddItemAction(newObjectVC: viewControllers)
                
            case "CalendarViewController":
                
                let viewControllers = [
                    "Create New Event": NewEventViewController()
                ]
                
                configureAddItemAction(newObjectVC: viewControllers)
                
            default:
                //show info message
                handlePopoverMessageAnimation()
                break
            }
            
            return false
        }
        return true
    }
    
}

