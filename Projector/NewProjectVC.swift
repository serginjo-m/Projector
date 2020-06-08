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

class CreateViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //MARK: Properties
    
    //var myCategoryCollection = CategoryCollectionView(frame: CGRect(x : 15 , y : 187, width: 360, height: 66))
    var myCategoryCollection = CategoryCollectionView()
    
    //Project Image
    @IBOutlet weak var projectMainPicture: UIImageView!
    // need for indicating a selected image inside PHAsset array
    var selectedImageURLString: String?
    
    //define current date
    let createdDate: String = {
        let calendar = Calendar(identifier: .gregorian)
        let ymd = calendar.dateComponents([.year, .month, .day], from: Date())
        guard let year = ymd.year, let month = ymd.month, let day = ymd.day else {return ""}
        let myDate = "Created: \(day)/\(month)/\(year)"// compiler gives me an error type? is it becouse of guard?
        return myDate
    }()
    
    @IBOutlet weak var selectProjectCategory: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    //price configuration
    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var priceLabel: UILabel!
    //distance? configuration
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
            //description View configuration
            descriptionTextView.layer.borderWidth = 1
            descriptionTextView.layer.borderColor = UIColor(white: 0.82, alpha: 1).cgColor
            descriptionTextView.layer.cornerRadius = 4
        
            projectMainPicture.layer.cornerRadius = 4
            projectMainPicture.layer.borderWidth = 1
            projectMainPicture.layer.borderColor = UIColor(white: 0.75, alpha: 1).cgColor
        
            // Handle the text field's user input through delegate callback.
            nameTextField.delegate = self
            //Enable the Save button only if the text field has a valid project name.
            updateSaveButtonState()
        
            //Enable User Interaction for UIImageView (tapGesture won't work without this)
            projectMainPicture.isUserInteractionEnabled = true
        
            view.addSubview(myCategoryCollection)
        
            setupLayout()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //here I pre configure my labels to refer an actual value of slider when it appears
        priceLabel.text = "\(Int(round(priceSlider.value))) $"
        distanceLabel.text = "\(Int(round(distanceSlider.value))) km"
    }
    
    private func setupLayout(){
        
        myCategoryCollection.translatesAutoresizingMaskIntoConstraints = false
        
        myCategoryCollection.topAnchor.constraint(equalTo: selectProjectCategory.bottomAnchor, constant: 6).isActive = true
        myCategoryCollection.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        myCategoryCollection.widthAnchor.constraint(equalToConstant: 400).isActive = true
        myCategoryCollection.heightAnchor.constraint(equalToConstant: 66).isActive = true
        
    }
  
    // MARK: - Navigation
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        // here I pass my priceSlider value to the text label
        priceLabel.text = "\(Int(round(sender.value))) $"
    }
    @IBAction func distanceSliderValueChanged(_ sender: UISlider) {
        //passing distanceSlider value to the distance label
        distanceLabel.text = "\(Int(round(sender.value))) km"
    }
    
     //This method lets You configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

      super.prepare(for: segue, sender: sender)
    
         // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIButton, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let category = myCategoryCollection.categoryName
        let projectDescription = descriptionTextView.text ?? ""
        let totalProjectCost = Int(round(priceSlider.value))
        let distanceToGo = Int(round(distanceSlider.value))
        
    
        //create template of project
        let projectList = ProjectList()
        
        projectList.distance = distanceToGo
        projectList.totalCost = totalProjectCost
        projectList.name = name
        projectList.category = category
        projectList.comment = projectDescription
        projectList.selectedImagePathUrl = selectedImageURLString
        projectList.date = createdDate
        
        ProjectListRepository.instance.createProjectList(list: projectList)
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
    
    
    //
    @IBAction func createNewProjectLabel(_ sender: UIButton) {
    
    }
    
    
    @IBAction func tapGestureAction(_ sender: UITapGestureRecognizer) {
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
    
    //MARK: Private Methods
    private func updateSaveButtonState(){
        //Disable the Save button when text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    
    
}
