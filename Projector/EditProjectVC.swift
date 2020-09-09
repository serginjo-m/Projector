//
//  CreateViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 07.11.2019.
//  Copyright © 2019 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
import Foundation
import os
import Photos

class EditProjectViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //MARK: Properties
    
    var realm: Realm!//create a var
    
    //most for reload data
    weak var delegate: EditViewControllerDelegate?
    
    let categoryCollectionView = CategoryCollectionView()
    // need to indicate selected image inside PHAsset array
    var selectedImageURLString: String?
    //unique project id for updating
    var projectId: String?
    //becouse project template needs to contain all steps
    var projectSteps: List<ProjectStep>?
    
    //Cancel button
    let cancelButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "backArrow")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backAction(button:)), for: .touchDown)
        return button
    }()
    //Save Button
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.blue , for: .normal)
        button.setTitleColor(UIColor(white: 0.75, alpha: 1), for: .disabled)
        button.addTarget(self, action: #selector(saveAction(button:)), for: .touchDown)
        return button
    }()
    //VC title
    let vcTitle: UILabel = {
        let title = UILabel()
        title.text = "Edit Project"
        title.textAlignment = NSTextAlignment.center
        title.textColor = UIColor.darkGray
        title.font = UIFont.systemFont(ofSize: 15)
        return title
    }()
    //project name title
    let nameTitle: UILabel = {
        let label = UILabel()
        label.text = "Project Name"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        return label
    }()
    //name text field
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Your Step Name Here"
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.autocorrectionType = UITextAutocorrectionType.yes
        textField.keyboardType = .default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        return textField
    }()
    //project category title
    let categoryTitle: UILabel = {
        let label = UILabel()
        label.text = "Project Category"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        return label
    }()
    //project image selected by user
    let projectMainPicture: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "plusBG")
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        image.clipsToBounds = true
        image.layer.cornerRadius = 4
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor(white: 0.75, alpha: 1).cgColor
        return image
    }()
    //comment to image picker
    let mainPictureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Do You Have Some Image?"
        label.textColor = .gray
        return label
    }()
    //project category title
    let descriptionTitle: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        return label
    }()
    //text field for project description
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(white: 0.82, alpha: 1).cgColor
        textView.layer.cornerRadius = 4
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = UIColor(white: 0.4, alpha: 1)
        return textView
    }()
    //price slider
    let priceTitle: UILabel = {
        let label = UILabel()
        label.text = "How much can it cost?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        return label
    }()
    let priceSlider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(priceSliderValueChanged(_:)), for: .valueChanged)
        slider.maximumValue = 99000
        slider.value = 1
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    let priceValueLabel: UILabel = {
        let label = UILabel()
        label.text = "300$"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    //distance slider
    let distanceTitle: UILabel = {
        let label = UILabel()
        label.text = "How Far To Go?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let distanceSlider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(distanceSliderValueChanged(_:)), for: .valueChanged)
        slider.maximumValue = 9000
        slider.value = 1
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    let distanceValueLabel: UILabel = {
        let label = UILabel()
        label.text = "300km"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    //define current date
    let createdDate: String = {
        let calendar = Calendar(identifier: .gregorian)
        let ymd = calendar.dateComponents([.year, .month, .day], from: Date())
        guard let year = ymd.year, let month = ymd.month, let day = ymd.day else {return ""}
        let myDate = "Created: \(day)/\(month)/\(year)"// compiler gives me an error type? is it becouse of guard?
        return myDate
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        //adds each element to view
        [saveButton, cancelButton, vcTitle, nameTitle, nameTextField, categoryTitle, categoryCollectionView, projectMainPicture, mainPictureLabel, descriptionTitle, descriptionTextView, priceTitle, priceSlider, priceValueLabel,distanceTitle, distanceSlider, distanceValueLabel].forEach{
            view.addSubview($0)
        }
        
        //setup constraints
        setupLayout()
     
        
        // Handle the text field's user input through delegate callback.
        nameTextField.delegate = self
        //Enable the Save button only if the text field has a valid project name.
        updateSaveButtonState()

        
        //imageView
        imageViewConfiguration()
        
        //show an actual value of slider
        priceValueLabel.text = "\(Int(round(priceSlider.value))) $"
        distanceValueLabel.text = "\(Int(round(distanceSlider.value))) km"
    }
    //Dismiss View Controller
    @objc func backAction( button: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    //becouse tap gesture won't work inside constant configurator need to create separate function
    private func imageViewConfiguration(){
        //Enable User Interaction for UIImageView (tapGesture won't work without this)
        projectMainPicture.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        projectMainPicture.addGestureRecognizer(tap)
    }
    
    private func setupLayout(){
        
        //each item in view must ...
        [saveButton, cancelButton, vcTitle, nameTitle, nameTextField, categoryTitle, categoryCollectionView, projectMainPicture, mainPictureLabel, descriptionTitle, descriptionTextView, priceTitle, priceSlider, priceValueLabel, distanceTitle, distanceSlider, distanceValueLabel].forEach{$0.translatesAutoresizingMaskIntoConstraints = false}
        
        saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  10).isActive = true
        saveButton.leftAnchor.constraint(equalTo: view.rightAnchor, constant:  -58).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  10).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  26).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 8).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        vcTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  10).isActive = true
        vcTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        vcTitle.widthAnchor.constraint(equalToConstant: 300).isActive = true
        vcTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        nameTitle.topAnchor.constraint(equalTo: vcTitle.bottomAnchor, constant:  20).isActive = true
        nameTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        nameTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        nameTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        nameTextField.topAnchor.constraint(equalTo: nameTitle.bottomAnchor, constant:  0).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        categoryTitle.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant:  14).isActive = true
        categoryTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        categoryTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        categoryTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        categoryCollectionView.topAnchor.constraint(equalTo: categoryTitle.bottomAnchor, constant: 4).isActive = true
        categoryCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        categoryCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant:  0).isActive = true
        categoryCollectionView.heightAnchor.constraint(equalToConstant: 66).isActive = true
        
        projectMainPicture.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 17).isActive = true
        projectMainPicture.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        projectMainPicture.widthAnchor.constraint(equalToConstant: 107).isActive = true
        projectMainPicture.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        mainPictureLabel.centerYAnchor.constraint(equalTo: projectMainPicture.centerYAnchor).isActive = true
        mainPictureLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  167).isActive = true
        mainPictureLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        mainPictureLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        descriptionTitle.topAnchor.constraint(equalTo: projectMainPicture.bottomAnchor, constant: 12).isActive = true
        descriptionTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        descriptionTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant:  -16).isActive = true
        descriptionTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        descriptionTextView.topAnchor.constraint(equalTo: descriptionTitle.bottomAnchor, constant:  2).isActive = true
        descriptionTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        descriptionTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        descriptionTextView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        
        priceTitle.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 10).isActive = true
        priceTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        priceTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant:  -16).isActive = true
        priceTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        priceSlider.topAnchor.constraint(equalTo: priceTitle.bottomAnchor, constant:  6).isActive = true
        priceSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        priceSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -120).isActive = true
        priceSlider.heightAnchor.constraint(equalToConstant: 29).isActive = true
        
        priceValueLabel.centerYAnchor.constraint(equalTo: priceSlider.centerYAnchor).isActive = true
        priceValueLabel.leftAnchor.constraint(equalTo: priceSlider.rightAnchor, constant:  28).isActive = true
        priceValueLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        priceValueLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        distanceValueLabel.centerYAnchor.constraint(equalTo: distanceSlider.centerYAnchor).isActive = true
        distanceValueLabel.leftAnchor.constraint(equalTo: distanceSlider.rightAnchor, constant:  28).isActive = true
        distanceValueLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        distanceValueLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        distanceSlider.topAnchor.constraint(equalTo: distanceTitle.bottomAnchor, constant:  6).isActive = true
        distanceSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        distanceSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -120).isActive = true
        distanceSlider.heightAnchor.constraint(equalToConstant: 29).isActive = true
        
        distanceTitle.topAnchor.constraint(equalTo: priceSlider.bottomAnchor, constant:  12).isActive = true
        distanceTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        distanceTitle.widthAnchor.constraint(equalToConstant: 250).isActive = true
        distanceTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    // MARK: - Navigation
    
    @objc func priceSliderValueChanged(_ sender: UISlider) {
        // here I pass my priceSlider value to the text label
        priceValueLabel.text = "\(Int(round(sender.value))) $"
    }
    @objc func distanceSliderValueChanged(_ sender: UISlider) {
        //passing distanceSlider value to the distance label
        distanceValueLabel.text = "\(Int(round(sender.value))) km"
    }
  
    @objc func saveAction(button: UIButton){
        dismiss(animated: true) {
            let project: ProjectList = self.defineProjectTemplate()
            ProjectListRepository.instance.updateProjectList(list: project)
            //configure detail VC
            self.delegate?.performAllConfigurations()
            //reload parents views
            self.delegate?.reloadViews()
        }
        
    }
    //creates project instance from values :)))))))))
    func defineProjectTemplate() -> ProjectList{
        let projectTemplate = ProjectList()
        if let id = projectId {
            projectTemplate.id = id
        }
        projectTemplate.date = createdDate
        projectTemplate.name = nameTextField.text ?? ""
        projectTemplate.category = categoryCollectionView.categoryName
        projectTemplate.selectedImagePathUrl = selectedImageURLString
        projectTemplate.comment = descriptionTextView.text ?? ""
        projectTemplate.totalCost = Int(round(priceSlider.value))
        projectTemplate.distance = Int(round(distanceSlider.value))
        //adds steps to template
        if let stepsArray = projectSteps{
            for step in stepsArray{
                projectTemplate.projectStep.append(step)
            }
        }
        return projectTemplate
    }
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    //MARK: Private Methods
    private func updateSaveButtonState(){
        //Disable the Save button when text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        var stringURL: String?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            //print("editedImage: \(editedImage)")
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            //print("originalImage: \(originalImage)")
            selectedImageFromPicker = originalImage
        }
        
        if let imgPHAsset = info["UIImagePickerControllerPHAsset"] as? PHAsset{
            
            //retreave image URL
            imgPHAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions(), completionHandler: { (contentEditingInput, dictInfo) in
                if imgPHAsset.mediaType == .image {
                    if let strURL = contentEditingInput?.fullSizeImageURL?.description {
                        //print("IMAGE URL: ", strURL)
                        assignUrl(url: strURL)
                    }
                }
            })
        }
        
        func assignUrl(url: String){
            selectedImageURLString = url
        }
        
        //it was preaty useful feature to make a breakpoint here
        //print(info)
        
        // Set photoImageView to display the selected image.
        if let selectedImage = selectedImageFromPicker {
            projectMainPicture.image = selectedImage
        }
        //Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    
    //save button
    @IBAction func createNewProjectLabel(_ sender: UIButton) {
        
    }
    
    //add image mechanism
    @objc func handleTap(_ sender: UITapGestureRecognizer){
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        //check for libraty authorization, that allows PHAsset option using in picker
        // & it is important, becouse all mechanism is based on PHAsset image address
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined  {
            PHPhotoLibrary.requestAuthorization({status in
                
            })
        }
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
}
