//
//  RegisteredUserInputView.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 31/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class RegisteredUserInputView: UIView{
    
    let emailTextField = CustomTextField(textFieldPlaceholder: "Email address")
    let passwordTextField = CustomTextField(textFieldPlaceholder: "Password")
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(loginUser), for: .touchUpInside)
        button.backgroundColor = UIColor.init(red: 28/255, green: 198/255, blue: 224/255, alpha: 1)
        return button
    }()
    
    lazy var restorePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Forgot Password?", for: .normal)
        button.setTitleColor(UIColor.init(red: 28/255, green: 198/255, blue: 224/255, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(passwordRecovery), for: .touchUpInside)
        return button
    }()
    
    let didTapLoginCompletionHandler: (() -> Void)
    let didTapRestoreCompletionHandler: (() -> Void)
    
    init(didTapLoginCompletionHandler: @escaping (() -> Void), didTapRestoreCompletionHandler: @escaping (() -> Void)) {
        
        self.didTapLoginCompletionHandler = didTapLoginCompletionHandler
        self.didTapRestoreCompletionHandler = didTapRestoreCompletionHandler
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
    
    @objc func passwordRecovery(){
        didTapRestoreCompletionHandler()
    }
    
    func setupInputContainer(){
        hideKeyboardWhenTappedAround()
        
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        addSubview(restorePasswordButton)
        
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
        
        restorePasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 40).isActive = true
        restorePasswordButton.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor).isActive = true
        restorePasswordButton.widthAnchor.constraint(equalToConstant: 130).isActive = true
        restorePasswordButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
}

