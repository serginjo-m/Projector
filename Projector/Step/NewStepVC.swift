//
//  NewStepViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 23.11.2019.
//  Copyright © 2019 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
import os.log
import Photos


class NewStepViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NewStepImagesDelegate {
    
    //most for reload data------------------------------------------------------------------------------------------
    weak var delegate: EditViewControllerDelegate?
    weak var editDelegate: StepViewControllerDelegate?
    
    //step id passed by detail VC
    var stepID: String?
    //step completion status
    var stepComplete: Bool?
    // list of items in step
    var stepItems = [String]()
    
    //MARK: Properties
    var realm: Realm!//create a var
    var newStepCategory = NewStepCategory()
    var newStepImages = NewStepImages()
    
    // need for indicating a selected images inside PHAsset array
    var selectedPhotoURLStringArray = [String]()
    
    //scroll view container
    var scrollViewContainer = UIScrollView()
    var contentUIView = UIView()
    
    //parent CV
    var stepsCV: UICollectionView?
    
    //name text field
    let stepNameTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.placeholder = "Write Your Step Name Here"
        textField.font = UIFont.boldSystemFont(ofSize: 15)
        return textField
        
    }()
    
    let lineUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0.63, alpha: 1)
        return view
    }()
    
    let stepSaveButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "okButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(saveButtonAction(_:)), for: .touchUpInside)
        button.isEnabled = false
        return button
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
        label.text = "New Step"
        label.textColor = UIColor.init(white: 0.7, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
    
    //Titles
    let nameTitle: UILabel = {
        let label = UILabel()
        label.text = "Your Step Name"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    let categoryTitle: UILabel = {
        let label = UILabel()
        label.text = "Select Category"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    let photoTitle: UILabel = {
        let label = UILabel()
        label.text = "Do You Have Some Photos?"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
   
    //define current date
    let createdDate: String = {
        let calendar = Calendar(identifier: .gregorian)
        let ymd = calendar.dateComponents([.year, .month, .day], from: Date())
        guard let year = ymd.year, let month = ymd.month, let day = ymd.day else {return ""}
        let myDate = "\(day)/\(month)/\(year)"// compiler gives me an error type? is it becouse of guard?
        return myDate
    }()
    
    //Reminder view object
    lazy var expandingReminderView = ExpandingReminder(
        //expand,close & remove button (3 in 1)
        didTapExpandCompletionHandler: { [weak self] in
            guard let self = self else {return}
            
            let applyButton = self.expandingReminderView.applyReminderButton
            let expandButton = self.expandingReminderView.reminderExpandIcon
            
            //Check what kind of animation should run
            if applyButton.isSelected == false {
                self.handleAnimate(active: false)
            }else{
                
                applyButton.isSelected = false
            }
            
        },
        //apply reminder button
        didTapApplyCompletionHandler: { [weak self] in
            guard let self = self else {return}
            
            self.handleAnimate(active: true)
        })
    
    //constraints for animation approach
    var maxHeightAnchor: NSLayoutConstraint?
    var minHeightAnchor: NSLayoutConstraint?
    
    //define selected project for adding steps to it
    var detailList: ProjectList? {
        get{
            //Retrieve a single object with unique identifier (projectListIdentifier)
            return realm.object(ofType: ProjectList.self, forPrimaryKey: uniqueID)
        }
    }
    //is an ID of tapped cell
    var uniqueID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //add scroll containers
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        
        //add all subviews
        [stepNameTextField, lineUIView, stepSaveButton, dismissButton, viewControllerTitle, nameTitle, categoryTitle, newStepCategory, photoTitle, newStepImages, expandingReminderView].forEach {
            contentUIView.addSubview($0)
        }
        
        //constraints configuration
        setupLayout()
        
        // Handle the text field's user input through delegate callback.
        stepNameTextField.delegate = self
        
        // handle image picker appearance, through delegate callback!! :>)
        //it is very important to define, what instances of view controllers are
        //notice that I have this optional delegate var
        newStepImages.delegate = self
        
        //Enable the Save button only if the text field has a valid project name.
        updateSaveButtonState()
        
        realm = try! Realm()//create an instance of object
        
        newStepCategory.backgroundColor = UIColor(white: 0.97, alpha: 1)
        
    }
    
    //animate add item menu
    fileprivate func handleAnimate(active: Bool){
    
        guard let minHeight = minHeightAnchor else {return}
        
        
        if minHeight.isActive == true{
            //hide title
            self.expandingReminderView.reminderTitle.alpha = 0
            
            minHeightAnchor?.isActive = false
            maxHeightAnchor?.isActive = true
        }else{
            maxHeightAnchor?.isActive = false
            minHeightAnchor?.isActive = true
        }
        
        //"active" can be true only when apply button is tapped
        if active == false {
            
            //rotate icon 45 degrees
            self.expandingReminderView.reminderExpandIcon.transform = self.expandingReminderView.reminderExpandIcon.transform.rotated(by: CGFloat(Double.pi/4))
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            let grayColor = UIColor.init(white: 214/255, alpha: 1)
            let greenColor = UIColor.init(red: 53/255, green: 204/255, blue: 117/255, alpha: 1)
            let blackColor = UIColor.init(white: 55/255, alpha: 1)
            
            //change color of close button
            if let maxHeight = self.maxHeightAnchor {
                self.expandingReminderView.reminderExpandIcon.tintColor = maxHeight.isActive ? blackColor : .white
                self.expandingReminderView.reminderExpandButton.backgroundColor = maxHeight.isActive ? grayColor : greenColor
            }
            //if apply button is tapped, changes background color to green
            if active == true {
                self.expandingReminderView.backgroundColor = UIColor.init(red: 211/255, green: 250/255, blue: 227/255, alpha: 1)
            }
            //show reminder title
            if minHeight.isActive == true{
                self.expandingReminderView.reminderTitle.alpha = 1
            }
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
        
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //This is my save button action!?
    @objc func saveButtonAction(_ sender: Any){

        dismiss(animated: true) {
            //use func for creating object
            let stepTemplate: ProjectStep = self.defineStepTemplate()
            
            if self.stepID != nil{
                
                ProjectListRepository.instance.editStep(step: stepTemplate)
                
                //delegate for reload
                self.editDelegate?.someKindOfFunctionThatPerformRelaod()
                
                UserActivitySingleton.shared.createUserActivity(description: "Updated \(stepTemplate.name) step")
            }else{
                
                try! self.realm!.write ({//here we actualy add a new object called projectList
                    self.detailList?.projectStep.append(stepTemplate)
                })
                
                //reload
                self.delegate?.performAllConfigurations()
                self.delegate?.reloadViews()
                
                UserActivitySingleton.shared.createUserActivity(description: "Added new step: \(stepTemplate.name)")
            }

        }
    }
    
    //creates step instance from values :)))))))))
    func defineStepTemplate() -> ProjectStep{
        let stepTemplate = ProjectStep()
        //if id exist(edit mode), replace it
        if let id = stepID {
            stepTemplate.id = id
        }
        //date
        stepTemplate.date = createdDate
        //name
        stepTemplate.name = stepNameTextField.text ?? ""
        //category
        stepTemplate.category = self.newStepCategory.selectedCategory
        //photos
        for item in selectedPhotoURLStringArray {
            stepTemplate.selectedPhotosArray.append(item)
        }
        //items
        for item in stepItems{
            stepTemplate.itemsArray.append(item)
        }
        
        if let existingNotification = self.expandingReminderView.notification{
            
            //because I won't modify existing in data base notification,
            //create new one based on existing and assign it to step
            let notification = Notification()
            notification.eventDate = existingNotification.eventDate
            notification.eventTime = existingNotification.eventTime
            notification.startDate = existingNotification.startDate
            
            //take some data from step object
            notification.name = stepTemplate.name
            notification.category = "step"
            notification.parentId = stepTemplate.id
            //finaly assign reminder to step
            stepTemplate.reminder = notification
        }
        
        //complete
        if let complete = stepComplete{
            stepTemplate.complete = complete
        }
        return stepTemplate
    }
    
    
    //NAME TEXT FIELD
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
        stepSaveButton.isEnabled = false
    }
    
    //MARK: Private Methods
    private func updateSaveButtonState(){
        //Disable the Save button when text field is empty.
        let text = stepNameTextField.text ?? ""
        stepSaveButton.isEnabled = !text.isEmpty
    }
    
    
    
    //-------------------------------------------------------------------------------------------------
    //------------------------ not realy sure ---------------------- for what?
    //------------------------ 1. Images removement won't work properly -------------------------------
    //-------------------------------------------------------------------------------------------------
    
    
    func deleteUrl(int: Int){
        selectedPhotoURLStringArray.remove(at: int)
    }
    
    func showImagePicker() {
        // Hide the keyboard.
        stepNameTextField.resignFirstResponder()
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
    
    private func setupLayout(){
        
        view.backgroundColor = .white
        newStepImages.translatesAutoresizingMaskIntoConstraints = false
        newStepCategory.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        viewControllerTitle.translatesAutoresizingMaskIntoConstraints = false
        stepSaveButton.translatesAutoresizingMaskIntoConstraints = false
        nameTitle.translatesAutoresizingMaskIntoConstraints = false
        categoryTitle.translatesAutoresizingMaskIntoConstraints = false
        photoTitle.translatesAutoresizingMaskIntoConstraints = false
       
        stepNameTextField.translatesAutoresizingMaskIntoConstraints = false
        lineUIView.translatesAutoresizingMaskIntoConstraints = false
        scrollViewContainer.translatesAutoresizingMaskIntoConstraints = false
        contentUIView.translatesAutoresizingMaskIntoConstraints = false
   
        
        
        scrollViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollViewContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollViewContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentUIView.topAnchor.constraint(equalTo: scrollViewContainer.topAnchor).isActive = true
        contentUIView.leftAnchor.constraint(equalTo: scrollViewContainer.leftAnchor).isActive = true
        contentUIView.rightAnchor.constraint(equalTo: scrollViewContainer.rightAnchor).isActive = true
        contentUIView.bottomAnchor.constraint(equalTo: scrollViewContainer.bottomAnchor).isActive = true
        contentUIView.widthAnchor.constraint(equalTo: scrollViewContainer.widthAnchor).isActive = true
        contentUIView.heightAnchor.constraint(equalToConstant: 1500).isActive = true
        
        
        dismissButton.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 15).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        viewControllerTitle.centerXAnchor.constraint(equalTo: contentUIView.centerXAnchor, constant: 0).isActive = true
        viewControllerTitle.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor, constant: 0).isActive = true
        viewControllerTitle.widthAnchor.constraint(equalToConstant: 120).isActive = true
        viewControllerTitle.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        
        expandingReminderView.bottomAnchor.constraint(equalTo: newStepImages.bottomAnchor, constant: 88).isActive = true
        expandingReminderView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        expandingReminderView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        //height constraints animation
        minHeightAnchor = expandingReminderView.heightAnchor.constraint(equalToConstant: 46)
        maxHeightAnchor = expandingReminderView.heightAnchor.constraint(equalToConstant: 432)
        minHeightAnchor?.isActive = true

        newStepImages.topAnchor.constraint(equalTo: photoTitle.bottomAnchor, constant:  20).isActive = true
        newStepImages.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        newStepImages.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        newStepImages.heightAnchor.constraint(equalToConstant: 146).isActive = true
        
        photoTitle.topAnchor.constraint(equalTo: newStepCategory.bottomAnchor, constant:  20).isActive = true
        photoTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        photoTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        photoTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        categoryTitle.topAnchor.constraint(equalTo: lineUIView.bottomAnchor, constant:  30).isActive = true
        categoryTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        categoryTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        categoryTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        newStepCategory.topAnchor.constraint(equalTo: categoryTitle.bottomAnchor, constant:  20).isActive = true
        newStepCategory.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        newStepCategory.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        newStepCategory.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        nameTitle.topAnchor.constraint(equalTo: viewControllerTitle.bottomAnchor, constant:  40).isActive = true
        nameTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        nameTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        nameTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        lineUIView.topAnchor.constraint(equalTo: stepNameTextField.bottomAnchor, constant: 3).isActive = true
        lineUIView.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        lineUIView.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        lineUIView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        stepNameTextField.topAnchor.constraint(equalTo: nameTitle.bottomAnchor, constant: 0).isActive = true
        stepNameTextField.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant: 15).isActive = true
        stepNameTextField.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        stepNameTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        stepSaveButton.topAnchor.constraint(equalTo: contentUIView.topAnchor, constant: 15).isActive = true
        stepSaveButton.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        stepSaveButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        stepSaveButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
    }
    
    //?? Am I Need It?
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
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
            selectedPhotoURLStringArray.append(url)
        }
        
        // Set photoImageView to display the selected image.
        if let selectedImage = selectedImageFromPicker {
            //add new item
            newStepImages.photoArray.append(selectedImage)
            //reload when picker closes
            newStepImages.imageCollectionView.reloadData()
        }
    
        //Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
}
