//
//  NewUserInputView.swift
//  Projector
//
//  Created by Serginjo Melnik on 07.10.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

class RegisteredUserInputView: UIView{
    
    let emailTextField = CustomTextField(textFieldPlaceholder: "Email address")
    let passwordTextField = CustomTextField(textFieldPlaceholder: "Password")
    
    let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(loginUser), for: .touchUpInside)
        button.backgroundColor = UIColor.init(red: 28/255, green: 198/255, blue: 224/255, alpha: 1)
        return button
    }()
    
    
    //login user
    let didTapLoginCompletionHandler: (() -> Void)
    
    init(didTapLoginCompletionHandler: @escaping (() -> Void)) {
        
        self.didTapLoginCompletionHandler = didTapLoginCompletionHandler
        
        super.init(frame: CGRect.zero)
        
        setupInputContainer()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func loginUser(){
        
        guard let email = emailTextField.textField.text,
              let password = passwordTextField.textField.text else {return}
        
        let greyColor = UIColor.init(white: 215/255, alpha: 1)
        
        
        emailTextField.lineView.backgroundColor = email.isEmpty == true ? .red : greyColor
        passwordTextField.lineView.backgroundColor = password.isEmpty == true ? .red : greyColor
        
        if email.isEmpty || password.isEmpty{
            return
        }else{
            didTapLoginCompletionHandler()
        }
    }
    
    func setupInputContainer(){
//        passwordTextField.textField.isSecureTextEntry = true
        hideKeyboardWhenTappedAround()
        
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        
        emailTextField.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20).isActive = true
        
        [emailTextField, passwordTextField].forEach{ (view) in
            view.heightAnchor.constraint(equalToConstant: 37).isActive = true
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 31).isActive = true
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -31).isActive = true
        }
        
        loginButton.widthAnchor.constraint(equalToConstant: 131).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 43).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 57).isActive = true
    }
}

class NewUserInputView: UIView{
    
    let nameTextField = CustomTextField(textFieldPlaceholder: "Name")
    let emailTextField = CustomTextField(textFieldPlaceholder: "Email address")
    let passwordTextField = CustomTextField(textFieldPlaceholder: "Password")
    
    let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("REGISTER", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(registerNewUser), for: .touchUpInside)
        button.backgroundColor = UIColor.init(red: 28/255, green: 198/255, blue: 224/255, alpha: 1)
        return button
    }()
    
    //expand
    let didTapRegisterCompletionHandler: (() -> Void)
    
     init(didTapRegisterCompletionHandler: @escaping (() -> Void)) {
        
        self.didTapRegisterCompletionHandler = didTapRegisterCompletionHandler
        
        super.init(frame: CGRect.zero)
        
        setupNewUserInputContainer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func registerNewUser(){
       
        guard let name = nameTextField.textField.text,
            let email = emailTextField.textField.text,
            let password = passwordTextField.textField.text else {return}
        
        let greyColor = UIColor.init(white: 215/255, alpha: 1)
    
        nameTextField.lineView.backgroundColor = name.isEmpty == true ? .red : greyColor
        emailTextField.lineView.backgroundColor = email.isEmpty == true ? .red : greyColor
        passwordTextField.lineView.backgroundColor = password.isEmpty == true ? .red : greyColor
        
        if name.isEmpty || email.isEmpty || password.isEmpty{
            return
        }else{
            didTapRegisterCompletionHandler()
        }
    }
    
    
    
    func setupNewUserInputContainer(){
//        passwordTextField.textField.isSecureTextEntry = true
        hideKeyboardWhenTappedAround()
    
        addSubview(nameTextField)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(registerButton)
        
    
        nameTextField.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20).isActive = true
        
        [nameTextField, emailTextField, passwordTextField].forEach{ (view) in
            view.heightAnchor.constraint(equalToConstant: 37).isActive = true
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 31).isActive = true
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -31).isActive = true
        }
        
        registerButton.widthAnchor.constraint(equalToConstant: 131).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 43).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        registerButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 57).isActive = true
    }
}

class CustomTextField: UIView, UITextFieldDelegate {
    
    lazy var textField: UITextField = {
        let tField = UITextField()
        tField.translatesAutoresizingMaskIntoConstraints = false
        tField.keyboardType = .default
        tField.clearButtonMode = UITextField.ViewMode.whileEditing
        tField.font = UIFont.boldSystemFont(ofSize: 15)
        tField.autocapitalizationType = .none
        tField.delegate = self
        return tField
    }()
    
    let lineView: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor.init(white: 215/255, alpha: 1)
        return line
    }()
    
    //same input diff placeholder
    init(textFieldPlaceholder: String) {
        super.init(frame: CGRect.zero)
        textField.placeholder = textFieldPlaceholder
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func setupLayout(){
        
        translatesAutoresizingMaskIntoConstraints = false
        
        hideKeyboardWhenTappedAround()
        
        addSubview(textField)
        addSubview(lineView)
        
        textField.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 0).isActive = true
        lineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        lineView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
    }
}
