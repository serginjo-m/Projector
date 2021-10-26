//
//  SwipingCell.swift
//  Projector
//
//  Created by Serginjo Melnik on 23.09.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class SwipingCell: UICollectionViewCell{
    
    var parentVC: SwipingController?//call dismiss on parent VC
    var users: Results<User> {
        get{
            return ProjectListRepository.instance.getAllUsers()
        }
    }
    
    var page: SwipingPage? {
        didSet{
            
            guard let unwrappedPage = page else {return}
            
            image.image = UIImage(named: unwrappedPage.imageName)
            
            let attributedText = NSMutableAttributedString(string: unwrappedPage.headerString, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])
            
            attributedText.append(NSAttributedString(string: "\n\n\n\(unwrappedPage.bodyText)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray]))
            
            descriptionTextView.attributedText = attributedText
            descriptionTextView.textAlignment = .center
            
            [imageHeightConstraint, imageCenterYAnchorConstraint, imageCenterXAnchorConstraint].forEach{
                guard let constraint = $0 else {return}
                constraint.isActive = false
            }
            
            
            let height = unwrappedPage.imageConstraints.imageHeight
            let centerX = unwrappedPage.imageConstraints.imageCenterXAnchor
            let centerY = unwrappedPage.imageConstraints.imageCenterYAnchor
            let heightConstraint = Double(frame.width - 60) * height
            
            
            imageHeightConstraint = image.heightAnchor.constraint(equalToConstant: CGFloat(heightConstraint))
            imageCenterXAnchorConstraint = image.centerXAnchor.constraint(equalTo: centerXAnchor, constant: centerX)
            imageCenterYAnchorConstraint = image.centerYAnchor.constraint(equalTo: centerYAnchor, constant: centerY)
            
            
            
            
            
            [imageHeightConstraint, imageCenterYAnchorConstraint, imageCenterXAnchorConstraint].forEach{
                guard let constraint = $0 else {return}
                constraint.isActive = true
            }
            
            //------------------------ a bit weird -----------------------------------
            //----------- need to have clear logic of what login page is -------------
            registerLoginNavStack.isHidden = unwrappedPage.bodyText == "" ? false : true
            userInputStack.isHidden = unwrappedPage.bodyText == "" ? false : true
        }
    }
    
    
    private let image: UIImageView = {
        let image = UIImageView(image: UIImage(named: "workspace"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let descriptionTextView: UITextView = {
        let text = UITextView()
        let string = "Something that you want to tell your user."
        let attributedText = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])
        attributedText.append(NSAttributedString(string: "\n\n\nDive into your project very easily. Acheave your goals an d be happy.", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        text.attributedText = attributedText
        text.textAlignment = .center
        text.isEditable = false
        text.isScrollEnabled = false
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = .clear
        return text
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.init(red: 28/255, green: 198/255, blue: 224/255, alpha: 1), for: .selected)
        button.setTitleColor(UIColor.init(white: 160/255, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(toggleRegisterButton(_:)), for: .touchUpInside)
        button.isSelected = true
        return button
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.setTitleColor(UIColor.init(red: 28/255, green: 198/255, blue: 224/255, alpha: 1), for: .selected)
        button.setTitleColor(UIColor.init(white: 160/255, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(toggleLoginButton(_:)), for: .touchUpInside)
        button.isSelected = false
        return button
    }()
    
    
    lazy var registerLoginNavStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [registerButton, loginButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        stack.isHidden = true
        return stack
    }()
    // view that contains all inputs and button needed for registration of new user
    lazy var newUserInputContainer: NewUserInputView = {
        let view = NewUserInputView(
            //register button
            didTapRegisterCompletionHandler: { [weak self] in//weak self helps to avoid retaining cycles
                guard let self = self, let unwrappedParentVC = self.parentVC else {return}
                //performs new user saving
                self.saveNewUser()
                //call dismiss on parent vc
                unwrappedParentVC.dismiss(animated: true, completion: nil)
            }
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    //contains all inputs for registered user login
    lazy var registeredUserInputContainer: RegisteredUserInputView = {
        let view = RegisteredUserInputView(
            //register button
            didTapLoginCompletionHandler: { [weak self] in//weak self helps to avoid retaining cycles
                guard let self = self,
                    let unwrappedParentVC = self.parentVC,
                    let inputPassword = self.registeredUserInputContainer.passwordTextField.textField.text,
                    let inputEmail = self.registeredUserInputContainer.emailTextField.textField.text else {return}
                
                //simple login logic
                //group all user by email
                let groupedDictionary: [ String: [User]] = Dictionary(grouping: self.users, by: { (user) -> String in
                    let email = user.email
                    return email
                })
                //check for user by input
                let allUsersByEmail = groupedDictionary[inputEmail]
                //check password
                if let unwAllUsers = allUsersByEmail{
                    for user in unwAllUsers {
                        if user.password == inputPassword{
                            ProjectListRepository.instance.updateUserStatus(isLogined: true, user: user)
                            unwrappedParentVC.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                
            }
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    //login or register views
    lazy var userInputStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [newUserInputContainer,registeredUserInputContainer])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        stack.isHidden = true
        return stack
    }()
    
    //constraints for animation
    
    var imageHeightConstraint: NSLayoutConstraint!
    var imageCenterYAnchorConstraint: NSLayoutConstraint!
    var imageCenterXAnchorConstraint: NSLayoutConstraint!
    //inputs animation approach
    var userInputStackLeftConstraint: NSLayoutConstraint!
    var userInputStackRightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    //activate register button and disable login button
    @objc func toggleRegisterButton(_ sender: UIButton){
        guard sender.isSelected == false else {return}
        sender.isSelected = true
        loginButton.isSelected = false
        
       guard let leftConstraint = userInputStackLeftConstraint, let rightConstraint = userInputStackRightConstraint else {return}
        
        
        if rightConstraint.isActive == true{
            rightConstraint.isActive = false
            leftConstraint.isActive = true
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        })
        
    }
    
    //activate login button and disable register button
    @objc func toggleLoginButton(_ sender: UIButton){
        
        guard sender.isSelected == false else {return}
        sender.isSelected = true
        registerButton.isSelected = false
        
        guard let leftConstraint = userInputStackLeftConstraint, let rightConstraint = userInputStackRightConstraint else {return}
        
        
        if leftConstraint.isActive == true{
            leftConstraint.isActive = false
            rightConstraint.isActive = true
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        })
    }
    
    //save new user
    func saveNewUser() {
        guard let name = newUserInputContainer.nameTextField.textField.text, let email = newUserInputContainer.emailTextField.textField.text, let password = newUserInputContainer.passwordTextField.textField.text else {return}
        
        let user = User()
        user.name = name
        user.email = email
        user.password = password
        
        ProjectListRepository.instance.createUser(user: user)
    }
    
    //setup constraints
    func setupLayout(){
        
        hideKeyboardWhenTappedAround()
      
        addSubview(image)
        addSubview(descriptionTextView)
        addSubview(registerLoginNavStack)
        addSubview(userInputStack)
        
        
       
        
        userInputStack.heightAnchor.constraint(equalToConstant: 243).isActive = true
        userInputStackLeftConstraint = userInputStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        //...but this is not active now
        userInputStackRightConstraint = userInputStack.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
        
        userInputStack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 2).isActive = true
        
        userInputStack.topAnchor.constraint(equalTo: registerLoginNavStack.bottomAnchor, constant: 20).isActive = true
        
        userInputStackLeftConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            registerLoginNavStack.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 30),
            registerLoginNavStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 31),
            registerLoginNavStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -31),
            registerLoginNavStack.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        image.widthAnchor.constraint(equalTo: widthAnchor, constant: -60)
        imageHeightConstraint = image.heightAnchor.constraint(equalToConstant: 150)
        imageCenterYAnchorConstraint = image.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -100)
        imageCenterXAnchorConstraint = image.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 30)
        
        [imageHeightConstraint, imageCenterYAnchorConstraint, imageCenterXAnchorConstraint].forEach{
            guard let constraint = $0 else {return}
            constraint.isActive = true
        }
        
        let imagePadding = CGFloat(frame.height * 0.04)
        
        descriptionTextView.leftAnchor.constraint(equalTo: leftAnchor, constant: 25).isActive = true
        descriptionTextView.rightAnchor.constraint(equalTo: rightAnchor, constant: -25).isActive = true
        descriptionTextView.topAnchor.constraint(equalTo: image.bottomAnchor, constant: imagePadding).isActive = true
        descriptionTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
