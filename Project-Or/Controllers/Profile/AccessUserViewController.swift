//
//  AccessUserViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 27/04/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit
//MARK: OK
class AccessUserViewController: UIViewController {
    
    lazy var skipButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 18
        button.backgroundColor = UIColor.init(white: 55/255, alpha: 1)
        button.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.translatesAutoresizingMaskIntoConstraints = false
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
            }
        )
        
        view.passwordTextField.displayButton.isHidden = false
        view.passwordTextField.textField.isSecureTextEntry = true
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
            }, didTapRestoreCompletionHandler: { [weak self] in
                
                guard let self = self else {return}
                
                let viewController = ForgotPasswordViewController()
                viewController.modalPresentationStyle = .popover
                viewController.view.backgroundColor = .white
                self.present(viewController, animated: true)
                
            }
        )
        view.passwordTextField.displayButton.isHidden = false
        view.passwordTextField.textField.isSecureTextEntry = true
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
    
    var imageTopAnchor: NSLayoutConstraint!
    
    //inputs animation approach
    var userInputStackLeftConstraint: NSLayoutConstraint!
    var userInputStackRightConstraint: NSLayoutConstraint!
    
    //update parent VC
    var didTapDismissCompletionHandler: (() -> Void)
    //MARK: Init
    //Good way to init view controller
    init(didTapDismissCompletionHandler: @escaping (() -> Void), nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        
        //Call parent vc, so it tryies to update itself
        self.didTapDismissCompletionHandler = didTapDismissCompletionHandler
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(skipButton)
        view.addSubview(image)
        view.addSubview(registerLoginNavStack)
        view.addSubview(userInputStack)
        
        self.view.backgroundColor = .white
        setupConstraints()
        configureKeyboardObservers()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //prevent multiple keyboard observers
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Methods
    fileprivate func configureKeyboardObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification){
        
        if let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            
            imageTopAnchor.constant = -250
            
            UIView.animate(withDuration: keyboardDuration, delay: 0) {
                self.image.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification){
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        
        if let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            if let keyboardRectangle = keyboardFrame?.cgRectValue {
                imageTopAnchor.constant = -(keyboardRectangle.height + 180)
                
                UIView.animate(withDuration: keyboardDuration, delay: 0) {
                    self.image.alpha = 0
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
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
        skipButton.widthAnchor.constraint(equalToConstant: 37).isActive = true
        skipButton.heightAnchor.constraint(equalToConstant: 37).isActive = true
        
        image.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageTopAnchor = image.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -250)
        imageTopAnchor.isActive = true
        image.widthAnchor.constraint(equalToConstant: 303).isActive = true
        image.heightAnchor.constraint(equalToConstant: 139).isActive = true
        
        
        registerLoginNavStack.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 30).isActive = true
        registerLoginNavStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 31).isActive = true
        registerLoginNavStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -31).isActive = true
        registerLoginNavStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        userInputStack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        userInputStackLeftConstraint = userInputStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        //...but this is not active now
        userInputStackRightConstraint = userInputStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0)

        userInputStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2).isActive = true

        userInputStack.topAnchor.constraint(equalTo: registerLoginNavStack.bottomAnchor, constant: 20).isActive = true

        userInputStackLeftConstraint.isActive = true
        
    }
}
