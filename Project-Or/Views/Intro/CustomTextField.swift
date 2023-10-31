//
//  CustomTextField.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 31/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class CustomTextField: UIView, UITextFieldDelegate {
    
    lazy var textField: UITextField = {
        let tField = UITextField()
        tField.translatesAutoresizingMaskIntoConstraints = false
        tField.keyboardType = .alphabet
        tField.autocorrectionType = .no
        tField.clearButtonMode = UITextField.ViewMode.never
        tField.font = UIFont.boldSystemFont(ofSize: 15)
        tField.autocapitalizationType = .none
        tField.delegate = self
        return tField
    }()
    
    lazy var displayButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "greenEye"), for: .normal)
        button.setImage(UIImage(named: "redEye"), for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .top
        button.addTarget(self, action: #selector(handlePasswordDisplayAppearance(_:)), for: .touchUpInside)
        let lightRedColor = UIColor.init(displayP3Red: 255/255, green: 227/255, blue: 227/255, alpha: 1)
        button.setBackgroundColor(lightRedColor, forState: .selected)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.isHidden = true
        return button
    }()
    
    let lineView: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor.init(white: 0.85, alpha: 1)
        return line
    }()
    
    //same input diff placeholder
    init(textFieldPlaceholder: String) {
        super.init(frame: CGRect.zero)
        textField.attributedPlaceholder = NSAttributedString(
            string: textFieldPlaceholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handlePasswordDisplayAppearance(_ sender: UIButton){
        
        sender.isSelected = !sender.isSelected
        
        textField.isSecureTextEntry = !textField.isSecureTextEntry
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setupLayout(){
        
        translatesAutoresizingMaskIntoConstraints = false
        
        hideKeyboardWhenTappedAround()
        
        addSubview(textField)
        addSubview(lineView)
        addSubview(displayButton)
        
        textField.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        displayButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor).isActive = true
        displayButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        displayButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        displayButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 0).isActive = true
        lineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        lineView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
    }
}

