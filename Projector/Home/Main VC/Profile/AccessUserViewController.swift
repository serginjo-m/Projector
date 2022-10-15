//
//  AccessUserViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 27/04/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit

class AccessUserViewController: UIViewController {
    
    lazy var skipButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(UIColor.init(white: 0.43, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    //space image
    private let image: UIImageView = {
        let image = UIImageView(image: UIImage(named: "space_p4"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("REGISTER", for: .normal)
        button.setTitleColor(UIColor.init(red: 28/255, green: 198/255, blue: 224/255, alpha: 1), for: .selected)
        button.setTitleColor(UIColor.init(white: 160/255, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(toggleRegisterButton(_:)), for: .touchUpInside)
        button.isSelected = true
        return button
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("LOGIN", for: .normal)
        button.setTitleColor(UIColor.init(red: 28/255, green: 198/255, blue: 224/255, alpha: 1), for: .selected)
        button.setTitleColor(UIColor.init(white: 160/255, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(toggleLoginButton(_:)), for: .touchUpInside)
        button.isSelected = false
        return button
    }()
    lazy var registerLoginNavStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [registerButton, loginButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        return stack
    }()
    // view that contains all inputs and button needed for registration of new user
    lazy var newUserInputContainer: NewUserInputView = {
        let view = NewUserInputView(
            //register button
            didTapRegisterCompletionHandler: { [weak self] in//weak self helps to avoid retaining cycles
                
                guard let self = self,
                      
                      let inputPassword = self.newUserInputContainer.passwordTextField.textField.text,
                      let inputEmail = self.newUserInputContainer.emailTextField.textField.text,
                      let inputName = self.newUserInputContainer.nameTextField.textField.text else {return}
                

                FirebaseService.shared.handleRegister(name: inputName, email: inputEmail, password: inputPassword) {
                    //call to update parent vc
                    self.didTapDismissCompletionHandler()
                    //call dismiss on parent vc
                    self.dismiss(animated: true, completion: nil)
                }
                
                //MARK: SAILSJS
//                Service.shared.createUser(emailAddress: inputEmail, password: inputPassword, fullName: inputName) { (res) in
//                    switch res {
//                    case .success(let apiRes):
//                        //not so necessary but for now let's leave it so.....
//                        print(apiRes.message)
//                        //call to update parent vc
//                        self.didTapDismissCompletionHandler()
//                        //call dismiss on parent vc
//                        self.dismiss(animated: true, completion: nil)
//                    case .failure(let err):
//                        print(err)
//                    }
//                }
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
                //unwrap optionals
                guard let self = self,
                    let inputPassword = self.registeredUserInputContainer.passwordTextField.textField.text,
                    let inputEmail = self.registeredUserInputContainer.emailTextField.textField.text else {return}
                                
                
                FirebaseService.shared.handleLogin(email: inputEmail, password: inputPassword) {
                    self.didTapDismissCompletionHandler()
                    self.dismiss(animated: true)
                }
                
                
                //MARK: SAILSJS
//                Service.shared.handleLogin(email: inputEmail, password: inputPassword) { (res) in
//                    switch res {
//                    case .success(let apiResponse):
//                        print(apiResponse.message as Any)
//                        //call to update parent vc
//                        self.didTapDismissCompletionHandler()
//                        //dismiss
//                        self.dismiss(animated: true, completion: nil)
//                    case .failure(let err):
//                        print("Failed to fetch user: ", err)
//                    }
//                }
                
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
        return stack
    }()
    
    //inputs animation approach
    var userInputStackLeftConstraint: NSLayoutConstraint!
    var userInputStackRightConstraint: NSLayoutConstraint!
    
    //update parent VC
    var didTapDismissCompletionHandler: (() -> Void)
    
    //Good way to init view controller
    init(didTapDismissCompletionHandler: @escaping (() -> Void), nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        
        
        //Call parent vc, so it tryies to update itself
        self.didTapDismissCompletionHandler = didTapDismissCompletionHandler
        
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(skipButton)
        view.addSubview(image)
        view.addSubview(registerLoginNavStack)
        view.addSubview(userInputStack)
        
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        setupConstraints()
    }
    
    //MARK: Methods
    //skip button action
    
    @objc private func handleDismiss(){
        dismiss(animated: true, completion: nil)
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
            self.view.layoutIfNeeded()
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
            self.view.layoutIfNeeded()
        })
    }
    
    fileprivate func setupConstraints(){
        skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22).isActive = true
        skipButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        skipButton.heightAnchor.constraint(equalToConstant: 19).isActive = true
        
        image.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        image.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 170).isActive = true
        image.widthAnchor.constraint(equalToConstant: 303).isActive = true
        image.heightAnchor.constraint(equalToConstant: 139).isActive = true
        
        
        registerLoginNavStack.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 30).isActive = true
        registerLoginNavStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 31).isActive = true
        registerLoginNavStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -31).isActive = true
        registerLoginNavStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        userInputStack.heightAnchor.constraint(equalToConstant: 243).isActive = true
        userInputStackLeftConstraint = userInputStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        //...but this is not active now
        userInputStackRightConstraint = userInputStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0)

        userInputStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2).isActive = true

        userInputStack.topAnchor.constraint(equalTo: registerLoginNavStack.bottomAnchor, constant: 20).isActive = true

        userInputStackLeftConstraint.isActive = true
        
    }
}
