
//
//  UserProfileViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 19/03/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import FirebaseAuth

class UserProfileViewController: UIViewController, CircleTransitionable {
    //MARK: Properties
    var user: User? {
        get{
            let users = ProjectListRepository.instance.getAllUsers()
            //only one user must be inside local database
            return users.first
        }
        set{
            //update
        }
    }
    
    lazy var transitionButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 18
        button.backgroundColor = UIColor.init(white: 55/255, alpha: 1)
        button.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
        
   lazy var loginButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 65
        button.backgroundColor = .white
        button.setImage(UIImage(named: "closed_lock"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(loginUser(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = user != nil
        return button
    }()
    
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 65
        button.backgroundColor = .white
        button.setImage(UIImage(named: "lock"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(logoutUser(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var deleteUserAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Delete Profile", for: .normal)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(handleUserAccountDeletion(_:)), for: .touchUpInside)
        button.setTitleColor(UIColor.init(white: 0, alpha: 0.7), for: .normal)
        button.isHidden = self.user == nil ? true : false
        return button
    }()
    
    lazy var deleteButtonImage: UIImageView = {
        let originalImage = UIImage(named: "binIcon")
        let tintedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        
        let image = UIImageView(image: tintedImage)
        image.tintColor = UIColor.init(white: 0, alpha: 0.7)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isHidden = self.user == nil ? true : false
        return image
    }()
    
    lazy var cloudIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "cloud"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = self.user == nil ? true : false
        return imageView
    }()
    
    lazy var syncTitle: UILabel = {
        let label = UILabel()
        label.text = "Sync is not Available"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.init(white: 55/255, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = self.user == nil ? true : false
        return label
    }()
        
    //login button dark circle
    let darkCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.04)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 86
        return view
    }()
    //login button light circle
    let lightCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.07)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 94
        return view
    }()
 
    //----- Probably uses to create view snapshot? ---------
    var mainView: UIView {
        return view
    }
    
    lazy var contentTextView : UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false

        var title = ""
        var subtitle = ""
        //Logged in user or not.
        if let user = user {
            title = "Hello \(user.name)!"
            subtitle = "\(user.email)"
        }else{
            title = "Hello!"
            subtitle = "Access Your profile here."
        }
        
        textView.attributedText = formatAttributedString(title: title , subtitle: subtitle)
        textView.textAlignment = .center
        textView.textAlignment = .center
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 159/255, green: 195/255, blue: 208/255, alpha: 1)

        view.addSubview(transitionButton)
        view.addSubview(darkCircleView)
        view.addSubview(lightCircleView)
        view.addSubview(logoutButton)
        view.addSubview(loginButton)
        view.addSubview(contentTextView)
        view.addSubview(deleteButtonImage)
        view.addSubview(deleteUserAccountButton)
        view.addSubview(cloudIcon)
        view.addSubview(syncTitle)
        
        //setup constraints
        setupConstraints()
    }
    
    //MARK: Methods
    
    //back to previous view
    @objc func backAction(_ sender: UIButton) {
       
        if let navController = self.navigationController{
            let transitionCoordinator = TransitionCoordinator()
            navController.delegate = transitionCoordinator
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    //login button action
    @objc fileprivate func loginUser(_ sender: Any){
        //init view controller with callback function
        let accessUserViewController = AccessUserViewController { [weak self] in
            guard let self = self else {return}
            self.reloadViewController()
            
            //MARK: SAILSJS
            //After login or register user, it tries to fetch users object, witch than should be saved for app
//            Service.shared.fetchUserProfile { (res) in
//                switch res{
//                case .success(let user):
//                    let userProfile = User()
//                    userProfile.name = user.fullName
//                    userProfile.email = user.emailAddress
//                    userProfile.isLogined = true
//                    
//                    //It is not the best solution but for this purpose it will be alright
//                    //So the plan is when logged in, create user and delete when logout
//                    ProjectListRepository.instance.createUser(user: userProfile)
//                    //update text
//                    self.contentTextView.attributedText = self.formatAttributedString(title: "Hello \(userProfile.name)!", subtitle: "\(userProfile.email)")
//                    //for some reasons, need to change it every time text was updated
//                    self.contentTextView.textAlignment = .center
//                    //hide button, so only logout button is visible.
//                    self.loginButton.isHidden = true
//                case .failure(let err):
//                    print("Failed to fetch user profile: ", err)
//                }
//            }
        }
        accessUserViewController.modalPresentationStyle = .fullScreen
        self.present(accessUserViewController, animated: true)
    }
    
    //function that define attributed string (title, subtitle)
    fileprivate func formatAttributedString(title: String, subtitle: String) -> NSMutableAttributedString{
        let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                               NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 26.0)]
        let storyAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                               NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20.0)]
        
        let mutableAttrString = NSMutableAttributedString(string: "\(title)\n", attributes:titleAttributes)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        mutableAttrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, mutableAttrString.length))
        mutableAttrString.append(NSAttributedString(string: subtitle, attributes:storyAttributes))
        
        return mutableAttrString
    }
    
    //logout function
    @objc fileprivate func logoutUser(_ sender: Any){
    
        //create new alert window
        let alertVC = UIAlertController(title: "Logout User?", message: "Are You sure want to logout?", preferredStyle: .alert)
        
        //cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        //delete button
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive, handler: {(UIAlertAction) -> Void in
            
            //logout user
            FirebaseService.shared.handleLogout {
                self.reloadViewController()
            }
            
            
            //MARK: SAILSJS
//            Service.shared.handleLogout { (res) in
//                switch res {
//                case .success(let res):
//                    print("user logout status is: ", res.message)
//                    //It is not the best solution but for this purpose it will be alright
//                    //So the plan is when logged in create user and delete when logout
//                    let users = ProjectListRepository.instance.getAllUsers()
//                    //delete from database
//                    for user in users {
//                        ProjectListRepository.instance.deleteUser(user: user)
//                    }
//                    
//                    //reveal login button
//                    self.loginButton.isHidden = false
//                    //update text
//                    self.contentTextView.attributedText = self.formatAttributedString(title: "Hi there!", subtitle: "Access Your profile here.")
//                    //center it
//                    self.contentTextView.textAlignment = .center
//                case .failure(let err):
//                    print(err)
//                }
//            }
        })
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(logoutAction)
        //shows an alert window
        present(alertVC, animated: true, completion: nil)
        
    }
    
    @objc fileprivate func handleUserAccountDeletion(_ sender: Any){
        
        //create new alert window
        let alertVC = UIAlertController(title: "Delete Profile?", message: "Are You sure You want to delete this user profile?", preferredStyle: .alert)
        
        //delete button
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
            
            FirebaseService.shared.deleteUserAccount { error in
                
                if let error = error {
                    switch error {
                    case .userNotAuthenticated:
                        //user is not authenticated
                        self.showServerResponseAlert(title: "Error", message: "User is not authenticated")
                    case .genericError(error: let error):
                        self.showServerResponseAlert(title: "Error", message: "\(error)")
                    }
                }else{
                    //here is no error, so account was deleted successfully!
                    //reload current view controller
                    self.reloadViewController()
                    //Send a message to user .................
                    self.showServerResponseAlert(title: "Profile Deleted", message: "Your User Profile was Deleted Successfully!")
                    
                }
            }
            
        })
        
        //cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertVC.addAction(deleteAction)
        alertVC.addAction(cancelAction)
        
        //shows an alert window
        present(alertVC, animated: true, completion: nil)
        
    }
    
    
    private func showServerResponseAlert(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }
    
    private func reloadViewController(){
        
        let user = ProjectListRepository.instance.getAllUsers().first
        
        if let userProfile = user {
            //reveal delete account button, because user is logged in
            self.deleteUserAccountButton.isHidden = false
            self.cloudIcon.isHidden = false
            self.syncTitle.isHidden = false
            self.deleteButtonImage.isHidden = self.deleteUserAccountButton.isHidden
            //update text
            self.contentTextView.attributedText = self.formatAttributedString(title: "Hello \(userProfile.name)!", subtitle: "\(userProfile.email)")
            //for some reasons, need to change it every time text was updated
            self.contentTextView.textAlignment = .center
            //hide button, so only logout button is visible.
            self.loginButton.isHidden = true
            
        }else{
            //Here I assume that I try to reload page with no user
            //clear previously saved user to view controller
            self.user = nil
            //hide delete account button, because user is not logged in
            self.deleteUserAccountButton.isHidden = true
            self.cloudIcon.isHidden = true
            self.syncTitle.isHidden = true
            self.deleteButtonImage.isHidden = self.deleteUserAccountButton.isHidden
            //reveal login button
            self.loginButton.isHidden = false
            //update text
            self.contentTextView.attributedText = self.formatAttributedString(title: "Hello!", subtitle: "Access Your profile here.")
            //center it
            self.contentTextView.textAlignment = .center
        }
    }
    
    //MARK: Constraints
    fileprivate func setupConstraints(){
        
        contentTextView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIScreen.main.bounds.height * 0.22).isActive = true
        contentTextView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        contentTextView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        contentTextView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        
        loginButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIScreen.main.bounds.height * 0.526).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 130).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 130).isActive = true
        
        logoutButton.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor, constant: 0).isActive = true
        logoutButton.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor, constant: 0).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 130).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 130).isActive = true

    
        darkCircleView.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor).isActive = true
        darkCircleView.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor).isActive = true
        darkCircleView.widthAnchor.constraint(equalToConstant: 174).isActive = true
        darkCircleView.heightAnchor.constraint(equalToConstant: 174).isActive = true
        
        lightCircleView.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor).isActive = true
        lightCircleView.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor).isActive = true
        lightCircleView.widthAnchor.constraint(equalToConstant: 188).isActive = true
        lightCircleView.heightAnchor.constraint(equalToConstant: 188).isActive = true
        
        transitionButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 19).isActive = true
        transitionButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        transitionButton.widthAnchor.constraint(equalToConstant: 37).isActive = true
        transitionButton.heightAnchor.constraint(equalToConstant: 37).isActive = true
        
        deleteButtonImage.centerYAnchor.constraint(equalTo: deleteUserAccountButton.centerYAnchor).isActive = true
        deleteButtonImage.leadingAnchor.constraint(equalTo: deleteUserAccountButton.leadingAnchor).isActive = true
        deleteButtonImage.widthAnchor.constraint(equalToConstant: 11).isActive = true
        deleteButtonImage.heightAnchor.constraint(equalToConstant: 17).isActive = true
        
        deleteUserAccountButton.centerYAnchor.constraint(equalTo: transitionButton.centerYAnchor, constant: 0).isActive = true
        deleteUserAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        deleteUserAccountButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        deleteUserAccountButton.widthAnchor.constraint(equalToConstant: 113).isActive = true
        
        cloudIcon.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 20).isActive = true
        cloudIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cloudIcon.widthAnchor.constraint(equalToConstant: 36).isActive = true
        cloudIcon.heightAnchor.constraint(equalToConstant: 29).isActive = true
        
        syncTitle.topAnchor.constraint(equalTo: cloudIcon.bottomAnchor, constant: 0).isActive = true
        syncTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        syncTitle.widthAnchor.constraint(equalToConstant: 70).isActive = true
        syncTitle.heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
}
