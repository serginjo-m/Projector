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
//Bottom Navigation
class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    //MARK: Properties
    
    var photoLibraryStatus = PHPhotoLibrary.authorizationStatus()
    
    //date as a start point for calendar
    let date = Date()
    
    //list of holidays received from server
    var listOfHolidays = [HolidayDetail](){
        didSet{
            //Dispatch, so it works indipendently and not slow down all app
            DispatchQueue.main.async {
                //creates grouped holidays dictionary
                self.convertHolidaysToEvents()
            }
        }
    }
    
    //get ALL events, for checking, is data base contain previously downloaded holidays from server
    var events: Results<Event>{
        get{
            return ProjectListRepository.instance.getEvents()
        }
        set{
            //update?
        }
    }
    
    //message that displays if plus button hasn't action to current viewController
    lazy var popoverMessageView: PopoverMessageView = {
        let view = PopoverMessageView()
        view.frame = CGRect(x: (self.view.frame.width / 2) - 125, y: self.view.frame.height , width: 250, height: 50)
        return view
    }()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        
        //check if holiday data was downloaded
        downloadHolidayEvents()
        //tab bar style changes at the bottom of view controller, so define constant style to it
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
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
        
        //get my add items nav view controller for setting its stack view controllers in func
         //let targetNavController = viewController as! UINavigationController
        
        //ALERT MENU
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
            // Do nothing
        }
        
        
        alert.addAction(action3)
        
        present(alert, animated: true, completion: nil)
    }
    
    //Build Calendar and then calls create nav controller
    private func createCalendarViewController() -> UINavigationController {
        let calendarViewController = CalendarViewController(baseDate: date) { (date) in
            
            //Do Nothing here !!
            //So maybe modify logic ?
        }
        return createNavControllerWithTitle(viewController: calendarViewController, title: "Calendar", imageName: "calendarIcon")
    }
    
    //Template for navigation items
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
        
        // index == 2 corresponds to add button
        if index == 2 {
            
            //get current visualized view controller
            guard let currentViewController = (self.selectedViewController as! UINavigationController).topViewController else {return false}
            
            //class identifier for logic purposes
            var lastVCClass: String = ""
            
            //base for switch cases logic
            lastVCClass = "\(currentViewController.classForCoder)"
            
            
            
            //perform logic based on last visualized view controller class
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
                
                //because case: DetailViewController, I can access it property for adding or modification
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

//MARK: Extension
extension CustomTabBarController {
    
    //check if holiday objects was downloaded
    func downloadHolidayEvents() {
        //Holiday database
        var holidays: Results<HolidayEvent> {
            get{
                return ProjectListRepository.instance.getHolidays()
            }
        }
        
        
        //------------------------------- What if country has no holidays? ------------------------------------
        //Download only once
        if holidays.count == 0{
            getHolidayResults()
        }
        
        
    }
    
    
    func getHolidayResults() {
        
        let holidayRequest = HolidayRequest(countryCode: "IT")//Italian Holidays
        holidayRequest.getHolidays {[weak self] result in//weak self prevent any retain cycles
            self?.listOfHolidays = result
        }
    }
    
    //convert Holiday obj to Event obj
    func convertHolidaysToEvents(){
        //TODO: need to revise it a bit
        //------------------------- need to optimize a bit 2x holiday version storage ------------------------
        self.listOfHolidays.forEach{
            //Holiday objects database. For now it holds a year when it was downloaded
            let holidayEvent = HolidayEvent()
            holidayEvent.category = "holiday"
            holidayEvent.title = $0.name
            holidayEvent.date = $0.date.datetime.dateObject
            holidayEvent.descr = $0.description
            holidayEvent.year = $0.date.datetime.year
            ProjectListRepository.instance.createHoliday(holidayEvent: holidayEvent)
            
            
            //All Events database (holidays, steps, user events)
            let event = Event()
            
            //configure holiday duration
            var dayComponent    = DateComponents()
            dayComponent.day    = 1 // For removing one day (yesterday): -1
            dayComponent.second = -1 // Actual Holiday duration will be 23:59:59, not one day
            let theCalendar     = Calendar.current
            if let holidayEventDate = holidayEvent.date {
                let nextDay = theCalendar.date(byAdding: dayComponent, to: holidayEventDate)
                event.endTime = nextDay
            }
            
            event.category = holidayEvent.category
            event.title = holidayEvent.title
            event.date = holidayEvent.date
            event.startTime = holidayEvent.date
            
            event.descr = holidayEvent.descr
            ProjectListRepository.instance.createEvent(event: event)
            
        }
    }
}

class PopoverMessageView: UIView {
    
    var textMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Nothing to Add Here"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textMessageLabel)
        
        self.backgroundColor = UIColor.init(red: 100/255, green: 209/255, blue: 130/255, alpha: 1)
        self.layer.cornerRadius = 11
        self.layer.masksToBounds = true
        
        textMessageLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textMessageLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textMessageLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
