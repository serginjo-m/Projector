//
//  StepItemViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 10.05.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.


import UIKit
import RealmSwift
//MARK: OK
class StepItemViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var realm: Realm!
    
    var stepID: String?
    
    var projectStep: ProjectStep? {
        get{
            if let id = self.stepID {
                return ProjectListRepository.instance.getProjectStep(id: id)
            }
            return nil
        }
    }

    var stepItem: StepItem?
    
    //cancel button
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close"), for: .normal)
        button.imageView?.contentMode = .center
        button.addTarget(self, action: #selector(backAction(button:)), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let dismissButtonTitle: UILabel = {
        let label = UILabel()
        label.text = "Close"
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "save"), for: .normal)
        button.imageView?.contentMode = .center
        button.addTarget(self, action: #selector(saveAction(button:)), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let saveButtonTitle: UILabel = {
        let label = UILabel()
        label.text = "Save"
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    let viewControllerTitle: UILabel = {
        let label = UILabel()
        label.text = "New Step Item"
        label.textColor = UIColor.init(white: 0.7, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        let mutableString = NSMutableAttributedString(string: "Item Title *", attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.mainPink, range: NSRange(location: 11, length: 1))
        label.attributedText = mutableString
        return label
    }()
    
    lazy var itemTitleTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.placeholder = "Write Your Item Title Here"
        textField.font = UIFont.boldSystemFont(ofSize: 15)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let lineUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0.63, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let descriptionTitle: UILabel = {
        let label = UILabel()
        label.text = "Add Your Note Here"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var noteTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 6
        textView.backgroundColor = UIColor.init(white: 239/255, alpha: 1)
        textView.font = UIFont.boldSystemFont(ofSize: 17)
        textView.textColor = UIColor.init(white: 0.3, alpha: 1)
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    var noteTextViewBottomAnchor: NSLayoutConstraint!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupLayout()
        realm = try! Realm()
        configureKeyboardObservers()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //prevent multiple keyboard observers
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        updateSaveButtonState()
    }
    
    //MARK: Methods
    fileprivate func configureKeyboardObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification){
        
        if let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            
            noteTextViewBottomAnchor.constant = -10
            
            UIView.animate(withDuration: keyboardDuration, delay: 0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification){
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        
        if let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            if let keyboardRectangle = keyboardFrame?.cgRectValue {
                noteTextViewBottomAnchor.constant = -(keyboardRectangle.height - 15)
                
                UIView.animate(withDuration: keyboardDuration, delay: 0) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    private func updateSaveButtonState(){
        guard let text = itemTitleTextField.text else {return}
        saveButton.isEnabled = !text.isEmpty
        saveButtonTitle.textColor = saveButton.isEnabled == true ? .darkGray : .lightGray
    }
    
    //Dismiss
    @objc func backAction( button: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveAction(button: UIButton){
        
        guard let step = self.projectStep,
              let title = self.itemTitleTextField.text,
              let text = self.noteTextView.text else {return}
        //update old one
        if let item = self.stepItem  {
            UserActivitySingleton.shared.createUserActivity(description: "Step Item : \(text) was updated in \(step.name)")
            
            ProjectListRepository.instance.updateStepItemTitle(stepItemTitle: title, stepItem: item)
            ProjectListRepository.instance.updateStepItemText(text: text, stepItem: item)
            
        }else{//create new one
            
            UserActivitySingleton.shared.createUserActivity(description: "New Item: \(text) was added to \(step.name) step")
            
            let stepItem = StepItem()
            stepItem.title = title
            stepItem.text = text
            
            ProjectListRepository.instance.addItemToStep(item: stepItem, step: step)
        }
        
        dismiss(animated: true)
    }
    
    //MARK: Text Field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldEditing(_ textfield: UITextField) {
        updateSaveButtonState()
    }
    
    //MARK: Constraints
    private func setupLayout(){
        [viewControllerTitle, dismissButton, dismissButtonTitle, saveButton, saveButtonTitle, titleLabel, itemTitleTextField, lineUIView, descriptionTitle, noteTextView].forEach {
            view.addSubview($0)
        }
        
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        dismissButtonTitle.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: -4).isActive = true
        dismissButtonTitle.leadingAnchor.constraint(equalTo: dismissButton.leadingAnchor).isActive = true
        dismissButtonTitle.trailingAnchor.constraint(equalTo: dismissButton.trailingAnchor).isActive = true
        dismissButtonTitle.heightAnchor.constraint(equalToConstant: 14).isActive = true
        
        saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        saveButtonTitle.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: -4).isActive = true
        saveButtonTitle.leadingAnchor.constraint(equalTo: saveButton.leadingAnchor).isActive = true
        saveButtonTitle.trailingAnchor.constraint(equalTo: saveButton.trailingAnchor).isActive = true
        saveButtonTitle.heightAnchor.constraint(equalToConstant: 14).isActive = true
        
        viewControllerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        viewControllerTitle.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor, constant: 0).isActive = true
        viewControllerTitle.widthAnchor.constraint(equalToConstant: 120).isActive = true
        viewControllerTitle.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 30).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 37).isActive = true
        
        itemTitleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        itemTitleTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        itemTitleTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        itemTitleTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        lineUIView.topAnchor.constraint(equalTo: itemTitleTextField.bottomAnchor, constant: 3).isActive = true
        lineUIView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        lineUIView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        lineUIView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        descriptionTitle.topAnchor.constraint(equalTo: lineUIView.bottomAnchor, constant: 30).isActive = true
        descriptionTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        descriptionTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        descriptionTitle.heightAnchor.constraint(equalToConstant: 37).isActive = true
        
        noteTextView.topAnchor.constraint(equalTo: descriptionTitle.bottomAnchor, constant: 10).isActive = true
        noteTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        noteTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        noteTextViewBottomAnchor = noteTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        noteTextViewBottomAnchor.isActive = true
    }
}
