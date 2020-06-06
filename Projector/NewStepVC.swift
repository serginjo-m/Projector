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


class NewStepViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NewStepImagesDelegate {
    
    //MARK: Properties
    var realm: Realm!//create a var
    var newStepCategory = NewStepCategory(frame: CGRect(x: 15, y: 175, width: 345, height: 90))
    var newStepImages = NewStepImages(frame: CGRect(x: 15, y: 306, width: 345, height: 148))
    
    // need for indicating a selected images inside PHAsset array
    var selectedPhotoURLStringArray = [String]()
    
    //name text field
    let stepNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Your Step Name Here"
        
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.autocorrectionType = UITextAutocorrectionType.yes
        textField.keyboardType = .default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        return textField
    }()
    //Save Button
    let stepSaveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.blue , for: .normal)
        button.setTitleColor(UIColor(white: 0.75, alpha: 1), for: .disabled)
        button.addTarget(self, action: #selector(saveButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    //Cancel button
    let cancelButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "backArrow")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backAction(button:)), for: .touchDown)
        return button
    }()
    //Date Label
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add New Step"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.darkGray
        return label
    }()
    //Titles
    let nameTitle: UILabel = {
        let label = UILabel()
        label.text = "Step Name"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        return label
    }()
    let categoryTitle: UILabel = {
        let label = UILabel()
        label.text = "Select Category"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        return label
    }()
    let photoTitle: UILabel = {
        let label = UILabel()
        label.text = "Photo"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        return label
    }()
    let priceTitle: UILabel = {
        let label = UILabel()
        label.text = "Price"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        return label
    }()
    let stepPriceSlider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(priceSliderValueChanged(_:)), for: .valueChanged)
        slider.maximumValue = 1000
        slider.value = 1
        return slider
    }()
    let stepPriceValueLabel: UILabel = {
        let label = UILabel()
        label.text = "300$"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    let distanceTitle: UILabel = {
        let label = UILabel()
        label.text = "Distance"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        return label
    }()
    let stepDistanceSlider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(distanceSliderValueChanged(_:)), for: .valueChanged)
        slider.maximumValue = 1000
        slider.value = 1
        return slider
    }()
    let stepDistanceValueLabel: UILabel = {
        let label = UILabel()
        label.text = "300km"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    
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
        
        view.addSubview(stepNameTextField)
        view.addSubview(stepSaveButton)
        view.addSubview(cancelButton)
        view.addSubview(titleLabel)
        view.addSubview(nameTitle)
        view.addSubview(categoryTitle)
        view.addSubview(newStepCategory)
        view.addSubview(photoTitle)
        view.addSubview(newStepImages)
        //price slider section
        view.addSubview(priceTitle)
        view.addSubview(stepPriceSlider)
        view.addSubview(stepPriceValueLabel)
        //distance slider section
        view.addSubview(distanceTitle)
        view.addSubview(stepDistanceSlider)
        view.addSubview(stepDistanceValueLabel)
    
        stepNameTextField.frame = CGRect(x: 15, y: 106, width: 345, height: 30)
        stepSaveButton.frame = CGRect(x: 328, y: 26, width: 32, height: 29)
        cancelButton.frame = CGRect(x: 15, y: 30, width: 36, height: 22)
        titleLabel.frame = CGRect(x: 112, y: 30, width: 150, height: 22)
        nameTitle.frame = CGRect(x: 15, y: 75, width: 80, height: 30)
        categoryTitle.frame = CGRect(x: 15, y: 144, width: 110, height: 30)
        photoTitle.frame = CGRect(x: 15, y: 271, width: 110, height: 30)
        priceTitle.frame = CGRect(x: 15, y: 467, width: 110, height: 30)
        stepPriceSlider.frame = CGRect(x: 15, y: 500, width: 243, height: 30)
        stepPriceValueLabel.frame = CGRect(x: 270, y: 500, width: 91, height: 30)
        //distance
        distanceTitle.frame = CGRect(x: 15, y: 547, width: 110, height: 30)
        stepDistanceSlider.frame = CGRect(x: 15, y: 580, width: 243, height: 30)
        stepDistanceValueLabel.frame = CGRect(x: 270, y: 580, width: 91, height: 30)
        
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
        
        //show an actual value of slider
        stepPriceValueLabel.text = "\(Int(round(stepPriceSlider.value))) $"
        stepDistanceValueLabel.text = "\(Int(round(stepDistanceSlider.value))) km"
    }
    
    // MARK: - Navigation
    
    //Dismiss View Controller
    @objc func backAction( button: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    //This is my save button action!?
    @objc func saveButtonAction(_ sender: Any){
        performSegue(withIdentifier: "backToDetailViewController", sender: stepSaveButton)
    }
    
    @objc func priceSliderValueChanged(_ sender: UISlider) {
        // here I pass my priceSlider value to the text label
        stepPriceValueLabel.text = "\(Int(round(sender.value))) $"
    }
    @objc func distanceSliderValueChanged(_ sender: UISlider) {
        // here I pass my priceSlider value to the text label
        stepDistanceValueLabel.text = "\(Int(round(sender.value))) km"
    }
    
    //This method lets You configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any? ) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let stepButton = sender as? UIButton, stepButton === stepSaveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let stepName = stepNameTextField.text ?? ""
        let stepCategory = newStepCategory.selectedCategory
        
        //Set the projectList to be passed to ProjectViewController after the unwind segue.
        //an issue is that it creates an individual item in realm
        let newStep = ProjectStep()
        newStep.name = stepName
        newStep.category = stepCategory
        newStep.cost = Int(round(stepPriceSlider.value))
        newStep.distance = Int(round(stepDistanceSlider.value))
        
        
        
        //add selected images url to step model
        for item in selectedPhotoURLStringArray{
            newStep.selectedPhotosArray.append(item)
        }
        
        try! self.realm!.write ({//here we actualy add a new object called projectList
            self.detailList?.projectStep.append(newStep)
        })
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
        //projectNameLabel.text = textField.text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Disable the Save button while editing.
        stepSaveButton.isEnabled = false
    }
    
    func stepSaveAction(_ sender: UIButton) {
        
    }
    
    //MARK: Private Methods
    private func updateSaveButtonState(){
        //Disable the Save button when text field is empty.
        let text = stepNameTextField.text ?? ""
        stepSaveButton.isEnabled = !text.isEmpty
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
