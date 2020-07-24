//
//  EditStepViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 22.07.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//
import UIKit
import RealmSwift
import os.log
import Photos

class EditStepViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    //MARK: Properties
    var realm: Realm!//create a var
    var stepCategory = NewStepCategory()
    var stepImages = NewStepImages()
    
    // need for indicating a selected images inside PHAsset array
    var selectedPhotoURLStringArray = [String]()
    
    
    //Save Button
    let stepSaveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.blue , for: .normal)
        button.setTitleColor(UIColor(white: 0.75, alpha: 1), for: .disabled)
//        button.addTarget(self, action: #selector(saveButtonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    //Cancel button
    let cancelButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "backArrow")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backAction(button:)), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    //Date Label
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Step"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    //Titles
    let nameTitle: UILabel = {
        let label = UILabel()
        label.text = "Step Name"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    //name text field
    let stepNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Your Step Name Here"
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.autocorrectionType = UITextAutocorrectionType.yes
        textField.keyboardType = .default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let categoryTitle: UILabel = {
        let label = UILabel()
        label.text = "Select Category"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let photoTitle: UILabel = {
        let label = UILabel()
        label.text = "Photo"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let priceTitle: UILabel = {
        let label = UILabel()
        label.text = "How Much Can It Cost?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let stepPriceSlider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(priceSliderValueChanged(_:)), for: .valueChanged)
        slider.maximumValue = 99000
        slider.value = 1
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    let stepPriceValueLabel: UILabel = {
        let label = UILabel()
        label.text = "300$"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let distanceTitle: UILabel = {
        let label = UILabel()
        label.text = "How Far To Go?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let stepDistanceSlider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(distanceSliderValueChanged(_:)), for: .valueChanged)
        slider.maximumValue = 9000
        slider.value = 1
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    let stepDistanceValueLabel: UILabel = {
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
        let myDate = "\(day)/\(month)/\(year)"// compiler gives me an error type? is it becouse of guard?
        return myDate
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
        //need to change becouse by default it is black
        view.backgroundColor = .white
        
        [stepNameTextField, stepSaveButton, cancelButton, titleLabel, nameTitle, categoryTitle, stepCategory, photoTitle, stepImages, priceTitle, stepPriceSlider, stepPriceValueLabel, distanceTitle, stepDistanceSlider, stepDistanceValueLabel].forEach {
            view.addSubview($0)
        }
        // constraints configuration
        setupLayout()
        
        // Handle the text field's user input through delegate callback.
        stepNameTextField.delegate = self

/*------------------------- have an issue here becouse delegate can be used only once ---------------------------
        
        // handle image picker appearance, through delegate callback!! :>)
        //it is very important to define, what instances of view controllers are
        //notice that I have this optional delegate var
        stepImages.delegate = self
  -------------------------------------------------------------------------*/
        //Enable the Save button only if the text field has a valid project name.
        updateSaveButtonState()
        // ----------------- maybe not needed --------------------------
        //realm = try! Realm()//create an instance of object
        
        //show an actual value of slider
        stepPriceValueLabel.text = "\(Int(round(stepPriceSlider.value))) $"
        stepDistanceValueLabel.text = "\(Int(round(stepDistanceSlider.value))) km"
    }

    private func setupLayout(){
        [stepNameTextField, stepSaveButton, cancelButton, titleLabel, nameTitle, categoryTitle, stepCategory, photoTitle, stepImages, priceTitle, stepPriceSlider, stepPriceValueLabel, distanceTitle, stepDistanceSlider, stepDistanceValueLabel].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        stepDistanceValueLabel.centerYAnchor.constraint(equalTo: stepDistanceSlider.centerYAnchor).isActive = true
        stepDistanceValueLabel.leftAnchor.constraint(equalTo: stepDistanceSlider.rightAnchor, constant:  28).isActive = true
        stepDistanceValueLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        stepDistanceValueLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        stepDistanceSlider.topAnchor.constraint(equalTo: distanceTitle.bottomAnchor, constant:  6).isActive = true
        stepDistanceSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        stepDistanceSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -120).isActive = true
        stepDistanceSlider.heightAnchor.constraint(equalToConstant: 29).isActive = true
        
        distanceTitle.topAnchor.constraint(equalTo: stepPriceSlider.bottomAnchor, constant:  12).isActive = true
        distanceTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        distanceTitle.widthAnchor.constraint(equalToConstant: 250).isActive = true
        distanceTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        stepPriceValueLabel.centerYAnchor.constraint(equalTo: stepPriceSlider.centerYAnchor).isActive = true
        stepPriceValueLabel.leftAnchor.constraint(equalTo: stepPriceSlider.rightAnchor, constant:  28).isActive = true
        stepPriceValueLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        stepPriceValueLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        stepPriceSlider.topAnchor.constraint(equalTo: priceTitle.bottomAnchor, constant:  6).isActive = true
        stepPriceSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        stepPriceSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -120).isActive = true
        stepPriceSlider.heightAnchor.constraint(equalToConstant: 29).isActive = true
        
        priceTitle.topAnchor.constraint(equalTo: stepImages.bottomAnchor, constant:  12).isActive = true
        priceTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        priceTitle.widthAnchor.constraint(equalToConstant: 250).isActive = true
        priceTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        stepImages.topAnchor.constraint(equalTo: photoTitle.bottomAnchor, constant:  4).isActive = true
        stepImages.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        stepImages.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        stepImages.heightAnchor.constraint(equalToConstant: 148).isActive = true
        
        photoTitle.topAnchor.constraint(equalTo: stepCategory.bottomAnchor, constant:  17).isActive = true
        photoTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        photoTitle.widthAnchor.constraint(equalToConstant: 110).isActive = true
        photoTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        categoryTitle.topAnchor.constraint(equalTo: stepNameTextField.bottomAnchor, constant:  17).isActive = true
        categoryTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        categoryTitle.widthAnchor.constraint(equalToConstant: 110).isActive = true
        categoryTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        stepCategory.topAnchor.constraint(equalTo: categoryTitle.bottomAnchor, constant:  4).isActive = true
        stepCategory.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        stepCategory.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        stepCategory.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        nameTitle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant:  40).isActive = true
        nameTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        nameTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        nameTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        stepNameTextField.topAnchor.constraint(equalTo: nameTitle.bottomAnchor, constant:  0).isActive = true
        stepNameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  16).isActive = true
        stepNameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        stepNameTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  10).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  26).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 8).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        stepSaveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  10).isActive = true
        stepSaveButton.leftAnchor.constraint(equalTo: view.rightAnchor, constant:  -58).isActive = true
        stepSaveButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        stepSaveButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  10).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
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
    
    //MARK: Private Methods
    private func updateSaveButtonState(){
        //Disable the Save button when text field is empty.
        let text = stepNameTextField.text ?? ""
        stepSaveButton.isEnabled = !text.isEmpty
    }
    
    //IMAGE PICKER
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
            stepImages.photoArray.append(selectedImage)
            //reload when picker closes
            stepImages.imageCollectionView.reloadData()
        }
        
        //Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
}
