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
    
    var user: User? {
        get{
            let users = ProjectListRepository.instance.getAllUsers()
            //only one user must be inside local database
            return users.first
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

    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 159/255, green: 195/255, blue: 208/255, alpha: 1)

        view.addSubview(transitionButton)
        view.addSubview(darkCircleView)
        view.addSubview(lightCircleView)
        view.addSubview(logoutButton)
        view.addSubview(loginButton)
        view.addSubview(contentTextView)
        
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
            
            let user = ProjectListRepository.instance.getAllUsers().first
            
            guard let self = self, let userProfile = user  else {return}
            
            //update text
            self.contentTextView.attributedText = self.formatAttributedString(title: "Hello \(userProfile.name)!", subtitle: "\(userProfile.email)")
            //for some reasons, need to change it every time text was updated
            self.contentTextView.textAlignment = .center
            //hide button, so only logout button is visible.
            self.loginButton.isHidden = true
            
            
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
                //reveal login button
                self.loginButton.isHidden = false
                //update text
                self.contentTextView.attributedText = self.formatAttributedString(title: "Hello!", subtitle: "Access Your profile here.")
                //center it
                self.contentTextView.textAlignment = .center
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
    }
}
