
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
//MARK: OK
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
    
    lazy var profileConfigurationButton: UIButton = {
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
        button.addTarget(self, action: #selector(handleUserAccountDeletion(_:)), for: .touchUpInside)
        button.isHidden = self.user == nil ? true : false
        return button
    }()
    
    lazy var circleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.init(white: 0, alpha: 0.7).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 17
        view.isHidden = self.user == nil ? true : false
        return view
    }()
    
    lazy var deleteButtonLabel: UILabel = {
        let label = UILabel()
        label.text = "Delete Profile"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.init(white: 55/255, alpha: 1)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.isHidden = self.user == nil ? true : false
        return label
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

        view.addSubview(profileConfigurationButton)
        view.addSubview(darkCircleView)
        view.addSubview(lightCircleView)
        view.addSubview(logoutButton)
        view.addSubview(loginButton)
        view.addSubview(contentTextView)
        view.addSubview(circleView)
        view.addSubview(deleteButtonImage)
        view.addSubview(deleteButtonLabel)
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
        })
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(logoutAction)
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
            self.circleView.isHidden = self.deleteButtonImage.isHidden
            self.deleteButtonLabel.isHidden = self.deleteButtonImage.isHidden
            //update text
            self.contentTextView.attributedText = self.formatAttributedString(title: "Hello \(userProfile.name)!", subtitle: "\(userProfile.email)")
            //change it after text update
            self.contentTextView.textAlignment = .center
            //hide login button, so only logout button is visible.
            self.loginButton.isHidden = true
        }else{
            //clear previously saved user to view controller
            self.user = nil
            //hide delete account button, when user is not logged in
            self.deleteUserAccountButton.isHidden = true
            self.cloudIcon.isHidden = true
            self.syncTitle.isHidden = true
            self.deleteButtonImage.isHidden = self.deleteUserAccountButton.isHidden
            //reveal login button
            self.loginButton.isHidden = false
            //update text
            self.contentTextView.attributedText = self.formatAttributedString(title: "Hello!", subtitle: "Access Your profile here.")
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
        
        profileConfigurationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 19).isActive = true
        profileConfigurationButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        profileConfigurationButton.widthAnchor.constraint(equalToConstant: 37).isActive = true
        profileConfigurationButton.heightAnchor.constraint(equalToConstant: 37).isActive = true
        deleteUserAccountButton.centerYAnchor.constraint(equalTo: profileConfigurationButton.centerYAnchor, constant: 0).isActive = true
        deleteUserAccountButton.leadingAnchor.constraint(equalTo: circleView.leadingAnchor, constant: 0).isActive = true
        deleteUserAccountButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        deleteUserAccountButton.widthAnchor.constraint(equalToConstant: 96).isActive = true
        cloudIcon.centerYAnchor.constraint(equalTo: profileConfigurationButton.centerYAnchor, constant: 0).isActive = true
        cloudIcon.leadingAnchor.constraint(equalTo: profileConfigurationButton.trailingAnchor, constant: 70).isActive = true
        cloudIcon.widthAnchor.constraint(equalToConstant: 36).isActive = true
        cloudIcon.heightAnchor.constraint(equalToConstant: 29).isActive = true
        
        syncTitle.leadingAnchor.constraint(equalTo: cloudIcon.trailingAnchor, constant: 0).isActive = true
        syncTitle.centerYAnchor.constraint(equalTo: cloudIcon.centerYAnchor).isActive = true
        syncTitle.widthAnchor.constraint(equalToConstant: 70).isActive = true
        syncTitle.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        circleView.leadingAnchor.constraint(equalTo: syncTitle.trailingAnchor, constant: 40).isActive = true
        circleView.centerYAnchor.constraint(equalTo: profileConfigurationButton.centerYAnchor).isActive = true
        circleView.widthAnchor.constraint(equalToConstant: 33).isActive = true
        circleView.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        deleteButtonImage.centerYAnchor.constraint(equalTo: circleView.centerYAnchor).isActive = true
        deleteButtonImage.centerXAnchor.constraint(equalTo: circleView.centerXAnchor).isActive = true
        deleteButtonImage.widthAnchor.constraint(equalToConstant: 11).isActive = true
        deleteButtonImage.heightAnchor.constraint(equalToConstant: 17).isActive = true
        
        deleteButtonLabel.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 8).isActive = true
        deleteButtonLabel.heightAnchor.constraint(equalToConstant: 33).isActive = true
        deleteButtonLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        deleteButtonLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor).isActive = true
    }
}
