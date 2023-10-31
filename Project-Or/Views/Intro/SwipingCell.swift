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
    
    var page: SwipingPage? {
        didSet{
            
            guard let unwrappedPage = page else {return}
            
            image.image = UIImage(named: unwrappedPage.imageName)
            
            let attributedText = NSMutableAttributedString(string: unwrappedPage.headerString, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])
            
            attributedText.append(NSAttributedString(string: "\n\n\n\(unwrappedPage.bodyText)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.gray]))
            
            descriptionTextView.attributedText = attributedText
            descriptionTextView.textAlignment = .center
            
            [imageHeightConstraint, imageCenterYAnchorConstraint, imageCenterXAnchorConstraint].forEach{
                guard let constraint = $0 else {return}
                constraint.isActive = false
            }
            
            var centerY: CGFloat = 0
            
            if unwrappedPage.bodyText == "" {
                let screenHeight = UIScreen.main.bounds.height
                centerY = screenHeight <= 667 ? -(screenHeight * 0.26) : -(screenHeight * 0.23)
            }else{
                centerY = unwrappedPage.imageConstraints.imageCenterYAnchor
            }
            
            let height = unwrappedPage.imageConstraints.imageHeight
            let centerX = unwrappedPage.imageConstraints.imageCenterXAnchor
            let heightConstraint = Double(frame.width - 60) * height
            
            
            imageHeightConstraint = image.heightAnchor.constraint(equalToConstant: CGFloat(heightConstraint))
            imageCenterXAnchorConstraint = image.centerXAnchor.constraint(equalTo: centerXAnchor, constant: centerX)
            imageCenterYAnchorConstraint = image.centerYAnchor.constraint(equalTo: centerYAnchor, constant: centerY)
            
            [imageHeightConstraint, imageCenterYAnchorConstraint, imageCenterXAnchorConstraint].forEach{
                guard let constraint = $0 else {return}
                constraint.isActive = true
            }
            
            registerLoginNavStack.isHidden = unwrappedPage.bodyText == "" ? false : true
            userInputStack.isHidden = unwrappedPage.bodyText == "" ? false : true
        }
    }
    
    var image: UIImageView = {
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
        button.setTitleColor(UIColor.gray, for: .normal)
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
        button.setTitleColor(UIColor.gray, for: .normal)
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
    
    lazy var newUserInputContainer: NewUserInputView = {
        let view = NewUserInputView(
    
            didTapRegisterCompletionHandler: { [weak self] in
                
                guard let self = self,
                      
                      let unwrappedParentVC = self.parentVC,
                      let inputPassword = self.newUserInputContainer.passwordTextField.textField.text,
                      let inputEmail = self.newUserInputContainer.emailTextField.textField.text,
                      let inputName = self.newUserInputContainer.nameTextField.textField.text else {return}
                
                FirebaseService.shared.handleRegister(name: inputName, email: inputEmail, password: inputPassword) {
                    unwrappedParentVC.didTapDismissCompletionHandler()
                    unwrappedParentVC.dismiss(animated: true, completion: nil)
                }
            }
        )
        view.passwordTextField.displayButton.isHidden = false
        view.passwordTextField.textField.isSecureTextEntry = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var registeredUserInputContainer: RegisteredUserInputView = {
        let view = RegisteredUserInputView(

            didTapLoginCompletionHandler: { [weak self] in

                guard let self = self,
                    let unwrappedParentVC = self.parentVC,
                    let inputPassword = self.registeredUserInputContainer.passwordTextField.textField.text,
                    let inputEmail = self.registeredUserInputContainer.emailTextField.textField.text else {return}
                
                FirebaseService.shared.handleLogin(email: inputEmail, password: inputPassword) {
                    unwrappedParentVC.didTapDismissCompletionHandler()
                    unwrappedParentVC.dismiss(animated: true)
                }
                
            }, didTapRestoreCompletionHandler: { [weak self] in
                
                guard let self = self, let unwrappedParentVC = self.parentVC else {return}
                unwrappedParentVC.showRestoreVC()
            }
        )
        view.passwordTextField.displayButton.isHidden = false
        view.passwordTextField.textField.isSecureTextEntry = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var userInputStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [newUserInputContainer,registeredUserInputContainer])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        stack.isHidden = true
        return stack
    }()
    
    var imageHeightConstraint: NSLayoutConstraint!
    var imageCenterYAnchorConstraint: NSLayoutConstraint!
    var imageCenterXAnchorConstraint: NSLayoutConstraint!
    
    var userInputStackLeftConstraint: NSLayoutConstraint!
    var userInputStackRightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
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
    
    func setupLayout(){
        
        hideKeyboardWhenTappedAround()
      
        addSubview(image)
        addSubview(descriptionTextView)
        addSubview(registerLoginNavStack)
        addSubview(userInputStack)
        
        userInputStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        userInputStackLeftConstraint = userInputStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
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
