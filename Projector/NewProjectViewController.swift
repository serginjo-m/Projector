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

class NewProjectViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //unique project id for updating
    var projectId: String?
    //becouse project template needs to contain all steps
    var projectSteps: List<ProjectStep>?
    //most for reload data
    weak var delegate: EditViewControllerDelegate?
    // need for indicating a selected image inside PHAsset array
    var selectedImageURLString: String?
    //category collection view
    let newProjectCategories = CategoryCollectionView()
    
    var projectCV: UICollectionView?
    
    //MARK: Properties
    //define current date
    let createdDate: String = {
        let calendar = Calendar(identifier: .gregorian)
        let ymd = calendar.dateComponents([.year, .month, .day], from: Date())
        guard let year = ymd.year, let month = ymd.month, let day = ymd.day else {return ""}
        let myDate = "Created: \(day)/\(month)/\(year)"// compiler gives me an error type? is it becouse of guard?
        return myDate
    }()
    
    let dismissButton: UIButton = {
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
    
    //MARK: Properties
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "okButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    var projectNameTitle: UILabel = {
        let label = UILabel()
        label.text = "Your Project Name"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.placeholder = "Write Your Project Name Here"
        textField.font = UIFont.boldSystemFont(ofSize: 15)
        return textField
    }()
    
    let lineUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0.63, alpha: 1)
        return view
    }()
    
    let imagePickerButton: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(displayP3Red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = 11
        view.clipsToBounds = true
        return view
    }()
    
    var imagePickerTitle: UILabel = {
        let label = UILabel()
        label.text = "Do You Have Some Image?"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    var projectImage: UIImageView = {
        var image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    var categoryTitle: UILabel = {
        let label = UILabel()
        label.text = "What Type Your Project Is?"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var budgetTitle: UILabel = {
        let label = UILabel()
        label.text = "What is Your Budget?"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var budgetSlider: UISlider = {
        var slider = UISlider()
        slider.maximumValue = 99000
        slider.addTarget(self, action: #selector(budgetSliderValueChanged), for: UIControl.Event.valueChanged)
        slider.value = 1
        return slider
    }()
    
    var budgetValueLabel: UILabel = {
        let label = UILabel()
        label.text = "Nill"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.init(displayP3Red: 104/255, green: 104/255, blue: 104/255, alpha: 1)
        return label
    }()
    
    var distanceTitle: UILabel = {
        let label = UILabel()
        label.text = "How Far Do You Go?"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var distanceSlider: UISlider = {
        var slider = UISlider()
        slider.maximumValue = 99000
        slider.addTarget(self, action: #selector(distanceSliderValueChanged), for: UIControl.Event.valueChanged)
        slider.value = 1
        return slider
    }()
    
    var distanceValueLabel: UILabel = {
        let label = UILabel()
        label.text = "Nill"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.init(displayP3Red: 104/255, green: 104/255, blue: 104/255, alpha: 1)
        return label
    }()
    
    
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
        imagePickerButton.addSubview(imagePickerTitle)
        imagePickerButton.addSubview(projectImage)
        
        view.addSubview(categoryTitle)
        view.addSubview(newProjectCategories)
        view.addSubview(budgetTitle)
        view.addSubview(budgetSlider)
        view.addSubview(budgetValueLabel)
        view.addSubview(distanceTitle)
        view.addSubview(distanceSlider)
        view.addSubview(distanceValueLabel)
        
        //constraints
        setupLayout()
        //add tap gesture to imagePickerButton
        imageViewConfiguration()
        
        //set delegate to name text field
        nameTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //here I pre configure my labels to refer an actual value of slider when it appears
        budgetValueLabel.text = "\(Int(round(budgetSlider.value)))$"
        distanceValueLabel.text = "\(Int(round(distanceSlider.value)))km"
    }
    
    //refer slider value to label
    @objc func budgetSliderValueChanged(){
        budgetValueLabel.text = "\(Int(round(budgetSlider.value)))$"
    }
    //refer slider value to label
    @objc func distanceSliderValueChanged(){
        distanceValueLabel.text = "\(Int(round(distanceSlider.value)))km"
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //back to previous view
    @objc func saveAction(_ sender: Any) {
        dismiss(animated: true) {
            let project: ProjectList = self.defineProjectTemplate()
            if self.projectId == nil{
                //creates new project instance
                ProjectListRepository.instance.createProjectList(list: project)
                self.projectCV?.reloadData()
            }else{
                //becouse project with that id exist it perform update
                ProjectListRepository.instance.updateProjectList(list: project)
                //configure detail VC
                self.delegate?.performAllConfigurations()
                //reload parents views
                self.delegate?.reloadViews()
            }
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
        projectTemplate.category = newProjectCategories.categoryName
        projectTemplate.selectedImagePathUrl = selectedImageURLString
        projectTemplate.totalCost = Int(round(budgetSlider.value))
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
    
    //becouse tap gesture won't work inside constant configurator need to create separate function
    private func imageViewConfiguration(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        imagePickerButton.addGestureRecognizer(tap)
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
            projectImage.image = selectedImage
        }
        //Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }

    
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
        budgetTitle.translatesAutoresizingMaskIntoConstraints = false
        budgetSlider.translatesAutoresizingMaskIntoConstraints = false
        budgetValueLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceTitle.translatesAutoresizingMaskIntoConstraints = false
        distanceSlider.translatesAutoresizingMaskIntoConstraints = false
        distanceValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
        saveButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
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
        imagePickerTitle.leftAnchor.constraint(equalTo: imagePickerButton.leftAnchor, constant: 0).isActive = true
        imagePickerTitle.rightAnchor.constraint(equalTo: imagePickerButton.rightAnchor, constant: 0).isActive = true
        imagePickerTitle.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
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
        
        budgetTitle.topAnchor.constraint(equalTo: newProjectCategories.bottomAnchor, constant: 20).isActive = true
        budgetTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        budgetTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        budgetTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        budgetSlider.topAnchor.constraint(equalTo: budgetTitle.bottomAnchor, constant: 0).isActive = true
        budgetSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        budgetSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -126).isActive = true
        budgetSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        budgetValueLabel.centerYAnchor.constraint(equalTo: budgetSlider.centerYAnchor, constant: 0).isActive = true
        budgetValueLabel.leftAnchor.constraint(equalTo: budgetSlider.rightAnchor, constant: 13).isActive = true
        budgetValueLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        budgetValueLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        distanceTitle.topAnchor.constraint(equalTo: budgetSlider.bottomAnchor, constant: 8).isActive = true
        distanceTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        distanceTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        distanceTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        distanceSlider.topAnchor.constraint(equalTo: distanceTitle.bottomAnchor, constant: 0).isActive = true
        distanceSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        distanceSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -126).isActive = true
        distanceSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        distanceValueLabel.centerYAnchor.constraint(equalTo: distanceSlider.centerYAnchor, constant: 0).isActive = true
        distanceValueLabel.leftAnchor.constraint(equalTo: distanceSlider.rightAnchor, constant: 13).isActive = true
        distanceValueLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        distanceValueLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    

}
