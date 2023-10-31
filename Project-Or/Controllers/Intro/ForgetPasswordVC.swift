//
//  ForgotPasswordVC.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 02/01/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//
import Foundation
import UIKit
//MARK: OK
class ForgotPasswordViewController: UIViewController {
    
    let viewControllerTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Forgot Password"
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = UIColor.init(white: 0.30, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    let textField: CustomTextField = {
        let textF = CustomTextField(textFieldPlaceholder: "Email address")
        textF.translatesAutoresizingMaskIntoConstraints = false
        return textF
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(sendEmail), for: .touchUpInside)
        button.backgroundColor = UIColor.init(red: 28/255, green: 198/255, blue: 224/255, alpha: 1)
        return button
    }()
    
    lazy var skipButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(UIColor.init(white: 0.43, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        view.addSubview(skipButton)
        view.addSubview(viewControllerTitle)
        view.addSubview(textField)
        view.addSubview(sendButton)
        configureConstraints()
    }
    
    @objc func sendEmail(){
        guard let text = textField.textField.text else {
            return
        }
        
        FirebaseService.shared.handleForgotPasswordEmail(email: text) { error in
            
            if let error = error {
                switch error {
                case .genericError(error: let error):
                    self.showServerResponseAlert(title: "Error", message: "\(error)", success: false)
                }
            } else {
                self.showServerResponseAlert(title: "Email Sent Successfully", message: "We've sent you an email with a link to reset your password.", success: true)
            }
            
        }
    }
    
    @objc func handleDismiss(){
        self.dismiss(animated: true)
    }
    
    private func showServerResponseAlert(title: String, message: String, success: Bool){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
            //only success dissmiss everything, error will leave to user another try
            if success == true {
                //dismiss message
                self.dismiss(animated: true) {
                    //dismiss viewController
                    self.dismiss(animated: true)
                }
            }
        }))
        self.present(ac, animated: true)
    }
    
    fileprivate func configureConstraints(){
        viewControllerTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        viewControllerTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        viewControllerTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        viewControllerTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        textField.topAnchor.constraint(equalTo: viewControllerTitle.bottomAnchor, constant: 100).isActive = true
        textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 31).isActive = true
        textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -31).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 37).isActive = true
        
        sendButton.widthAnchor.constraint(equalToConstant: 131).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 43).isActive = true
        sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        sendButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 57).isActive = true
        
        skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22).isActive = true
        skipButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        skipButton.heightAnchor.constraint(equalToConstant: 19).isActive = true
    }
}
