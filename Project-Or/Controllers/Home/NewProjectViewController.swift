//
//  NewProjectViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 12.11.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//
import UIKit
import RealmSwift
import Foundation
import os
import Photos

//MARK: OK

class NewProjectViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //MARK: Properties
    //update requires unique project id
    var projectId: String?
    
    // need for indicating a selected image inside PHAsset array
    var selectedImageURLString: String?
    //category collection view
    let newProjectCategories = CategoryCollectionView()
    
    var photoLibraryStatus = PHPhotoLibrary.authorizationStatus()
    
    //define current date
    let createdDate: String = {
        let calendar = Calendar(identifier: .gregorian)
        let ymd = calendar.dateComponents([.year, .month, .day], from: Date())
        guard let year = ymd.year, let month = ymd.month, let day = ymd.day else {return ""}
        let myDate = "Created: \(day)/\(month)/\(year)"
        return myDate
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        return button
    }()
    
    let viewControllerTitle: UILabel = {
        let label = UILabel()
        label.text = "New Project"
        label.textColor = UIColor.init(white: 0.7, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
        
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(named: "saveTo"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    var projectNameTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        let mutableString = NSMutableAttributedString(string: "Project Name *", attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.mainPink, range: NSRange(location: 13, length: 1))
        label.attributedText = mutableString
        return label
    }()
    
    lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.addTarget(self, action:  #selector(textFieldEditing), for: .editingChanged)
        textField.placeholder = "Write Your Project Name Here"
        textField.font = UIFont.boldSystemFont(ofSize: 15)
        return textField
    }()
    
    let lineUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0.63, alpha: 1)
        return view
    }()
    
    lazy var imagePickerButton: UIImageView = {
        let view = UIImageView(image: UIImage(named: "newEventDefault"))
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = 11
        view.clipsToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    var imagePickerTitle: UILabel = {
        let label = UILabel()
        label.text = "Add Image"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = UIColor.init(white: 0, alpha: 0.4)
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        return label
    }()
    
    var pickerTitleShadow: UILabel = {
        let label = UILabel()
        label.text = "Add Image"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .black
        label.layer.cornerRadius = 6
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        return label
    }()
    
    var projectImage: UIImageView = {
        var image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    var categoryTitle: UILabel = {
        let label = UILabel()
        label.text = "Project Category"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(dismissButton)
        view.addSubview(viewControllerTitle)
        view.addSubview(saveButton)
        view.addSubview(projectNameTitle)
        
        view.addSubview(nameTextField)
        view.addSubview(lineUIView)
        
        view.addSubview(imagePickerButton)
        imagePickerButton.addSubview(pickerTitleShadow)
        imagePickerButton.addSubview(imagePickerTitle)
        imagePickerButton.addSubview(projectImage)
        
        view.addSubview(categoryTitle)
        view.addSubview(newProjectCategories)
        
        
        //constraints
        setupLayout()
        
        //set delegate to name text field
        nameTextField.delegate = self
        
        updateSaveButtonState()
    }
    
   //MARK: Methods
    //back to previous view
    @objc func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //back to previous view
    @objc func saveAction(_ sender: Any) {
        
        //check if id/project exist
        if let ID = self.projectId{
            
            let project: ProjectList = self.defineProjectTemplate(id: ID)
            //perform update
            ProjectListRepository.instance.updateProjectList(list: project)
            
            UserActivitySingleton.shared.createUserActivity(description: "Updated \(project.name) project")
            
        }else{// if it new copy
            
            let project: ProjectList = self.defineProjectTemplate(id: nil)
            //creates new project instance
            ProjectListRepository.instance.createProjectList(list: project)
            
            UserActivitySingleton.shared.createUserActivity(description: "Created new \(project.name) project")
        }
        
        dismiss(animated: true)
    }
    
    
    
    //creates project instance from values :)))))))))
    func defineProjectTemplate(id: String?) -> ProjectList{
        
        //empty object
        let projectTemplate = ProjectList()
        projectTemplate.name = nameTextField.text ?? ""
        projectTemplate.category = newProjectCategories.categoryName
        projectTemplate.selectedImagePathUrl = selectedImageURLString
        
        
        if let ID = id {
            if let project = ProjectListRepository.instance.getProjectList(id: ID){
                //update existing copy
                projectTemplate.id = ID
                projectTemplate.date = project.date
                projectTemplate.filterIsActive = project.filterIsActive
                
                for step in project.projectStep{
                    projectTemplate.projectStep.append(step)
                }
                for statistic in project.projectStatistics{
                    projectTemplate.projectStatistics.append(statistic)
                }
            }
        }else{//unique to new instance
            //created date is just now!
            projectTemplate.date = createdDate
        }
        
        return projectTemplate
    }
    
    private func updateSaveButtonState(){
        guard let text = nameTextField.text else {return}
        saveButton.isEnabled = !text.isEmpty
    }
    
    //MARK: UITextFieldDelegate
    @objc func textFieldEditing(_ textfield: UITextField) {
        updateSaveButtonState()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    //add image mechanism
    @objc func handleTap(_ sender: UITapGestureRecognizer){
        
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        switch self.photoLibraryStatus {
        case .authorized:
            
            //lets a user pick media from their photo library.
            let imagePickerController = UIImagePickerController()
            
            // Only allow photos to be picked, not taken.
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = true
            
            // Make sure ViewController is notified when the user picks an image.
            imagePickerController.delegate = self
            
            self.present(imagePickerController, animated: true, completion: nil)
            
        case .denied:
            showPermissionAlert()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({status in
                self.photoLibraryStatus = status
            })
        case .restricted:
            print("restricted")
            // probably alert the user that photo access is restricted
        case .limited:
            print("limited")
        @unknown default:
            print("unknown case!")
        }
        
    }
    
    private func showPermissionAlert(){
        let ac = UIAlertController(title: "Access to Photo Library is Denied", message: "To turn on access to photo library, please go to Settings > Notifications > Projector", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let imgPHAsset = info["UIImagePickerControllerPHAsset"] as? PHAsset{
            
            //retreave image URL
            imgPHAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions(), completionHandler: { (contentEditingInput, dictInfo) in
                if imgPHAsset.mediaType == .image {
                    if let strURL = contentEditingInput?.fullSizeImageURL?.description {
                        assignUrl(url: strURL)
                    }
                }
            })
        }
        
        func assignUrl(url: String){
            selectedImageURLString = url
        }
        
        // Set photoImageView to display the selected image.
        if let selectedImage = selectedImageFromPicker {
            projectImage.image = selectedImage
        }
        //Dismiss picker
        dismiss(animated: true, completion: nil)
    }

    //MARK: Constraints
    private func setupLayout(){
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        viewControllerTitle.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        projectNameTitle.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        lineUIView.translatesAutoresizingMaskIntoConstraints = false
        imagePickerButton.translatesAutoresizingMaskIntoConstraints = false
        imagePickerTitle.translatesAutoresizingMaskIntoConstraints = false
        projectImage.translatesAutoresizingMaskIntoConstraints = false
        categoryTitle.translatesAutoresizingMaskIntoConstraints = false
        newProjectCategories.translatesAutoresizingMaskIntoConstraints = false
       
        
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        viewControllerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        viewControllerTitle.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor, constant: 0).isActive = true
        viewControllerTitle.widthAnchor.constraint(equalToConstant: 120).isActive = true
        viewControllerTitle.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 85).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        projectNameTitle.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20).isActive = true
        projectNameTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        projectNameTitle.widthAnchor.constraint(equalToConstant: 200).isActive = true
        projectNameTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        nameTextField.topAnchor.constraint(equalTo: projectNameTitle.bottomAnchor, constant: -8).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        lineUIView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 4).isActive = true
        lineUIView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        lineUIView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        lineUIView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        imagePickerButton.topAnchor.constraint(equalTo: lineUIView.bottomAnchor, constant: 37).isActive = true
        imagePickerButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        imagePickerButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        imagePickerButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        imagePickerTitle.centerYAnchor.constraint(equalTo: imagePickerButton.centerYAnchor).isActive = true
        imagePickerTitle.leftAnchor.constraint(equalTo: imagePickerButton.leftAnchor, constant: 20).isActive = true
        imagePickerTitle.rightAnchor.constraint(equalTo: imagePickerButton.rightAnchor, constant: -20).isActive = true
        imagePickerTitle.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        pickerTitleShadow.centerYAnchor.constraint(equalTo: imagePickerTitle.centerYAnchor, constant: 2).isActive = true
        pickerTitleShadow.widthAnchor.constraint(equalTo: imagePickerTitle.widthAnchor).isActive = true
        pickerTitleShadow.heightAnchor.constraint(equalTo: imagePickerTitle.heightAnchor).isActive = true
        pickerTitleShadow.leadingAnchor.constraint(equalTo: imagePickerTitle.leadingAnchor, constant: 2).isActive = true
        
        projectImage.topAnchor.constraint(equalTo: imagePickerButton.topAnchor, constant: 0).isActive = true
        projectImage.leftAnchor.constraint(equalTo: imagePickerButton.leftAnchor, constant: 0).isActive = true
        projectImage.rightAnchor.constraint(equalTo: imagePickerButton.rightAnchor, constant: 0).isActive = true
        projectImage.bottomAnchor.constraint(equalTo: imagePickerButton.bottomAnchor, constant: 0).isActive = true
        
        categoryTitle.topAnchor.constraint(equalTo: imagePickerButton.bottomAnchor, constant: 20).isActive = true
        categoryTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        categoryTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        categoryTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        newProjectCategories.topAnchor.constraint(equalTo: categoryTitle.bottomAnchor, constant: 6).isActive = true
        newProjectCategories.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        newProjectCategories.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        newProjectCategories.heightAnchor.constraint(equalToConstant: 122).isActive = true
    }
    

}
