//
//  NewUserInputView.swift
//  Projector
//
//  Created by Serginjo Melnik on 07.10.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

class NewUserInputView: UIView{
    
    let nameTextField = CustomTextField(textFieldPlaceholder: "Name")
    let emailTextField = CustomTextField(textFieldPlaceholder: "Email address")
    let passwordTextField = CustomTextField(textFieldPlaceholder: "Password")
    
    lazy var registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("REGISTER", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(registerNewUser), for: .touchUpInside)
        button.backgroundColor = UIColor.init(red: 28/255, green: 198/255, blue: 224/255, alpha: 1)
        return button
    }()
    
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
            
        nameTextField.lineView.backgroundColor = name.isEmpty == true ? .red : .gray
        emailTextField.lineView.backgroundColor = email.isEmpty == true ? .red : .gray
        passwordTextField.lineView.backgroundColor = password.isEmpty == true ? .red : .gray
        
        if name.isEmpty || email.isEmpty || password.isEmpty{
            return
        }else{
            didTapRegisterCompletionHandler()
        }
    }
    
    func setupNewUserInputContainer(){

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
