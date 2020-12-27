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
    let priceTitle: UILabel = {
        let label = UILabel()
        label.text = "Do You Need to Pay for It?"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    let stepPriceSlider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(priceSliderValueChanged(_:)), for: .valueChanged)
        slider.maximumValue = 99000
        slider.value = 1
        return slider
    }()

    let stepPriceValueLabel: UILabel = {
        let label = UILabel()
        label.text = "Nill"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.init(displayP3Red: 104/255, green: 104/255, blue: 104/255, alpha: 1)
        return label
    }()
    
    let distanceTitle: UILabel = {
        let label = UILabel()
        label.text = "How Far Do You Go?"
        label.font = UIFont.boldSystemFont(ofSize: 20)
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
        label.text = "Nill"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.init(displayP3Red: 104/255, green: 104/255, blue: 104/255, alpha: 1)
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
        
        //add scroll containers
        view.addSubview(scrollViewContainer)
        scrollViewContainer.addSubview(contentUIView)
        
        //add all subviews
        [stepNameTextField, lineUIView, stepSaveButton, dismissButton, viewControllerTitle, nameTitle, categoryTitle, newStepCategory, photoTitle, newStepImages, priceTitle, stepPriceSlider, stepPriceValueLabel, distanceTitle, stepDistanceSlider, stepDistanceValueLabel].forEach {
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
    //Update slider labels every time it appears
    override func viewWillAppear(_ animated: Bool) {
        //here I pre configure my labels to refer an actual value of slider when it appears
        stepPriceValueLabel.text = "\(Int(round(stepPriceSlider.value)))$"
        stepDistanceValueLabel.text = "\(Int(round(stepDistanceSlider.value)))km"
        
    }
    //Price
    @objc func priceSliderValueChanged(_ sender: UISlider) {
        // here I pass my priceSlider value to the text label
        stepPriceValueLabel.text = "\(Int(round(sender.value)))$"
    }
    //Distance
    @objc func distanceSliderValueChanged(_ sender: UISlider) {
        // here I pass my priceSlider value to the text label
        stepDistanceValueLabel.text = "\(Int(round(sender.value)))km"
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
                
            }else{
                
                try! self.realm!.write ({//here we actualy add a new object called projectList
                    self.detailList?.projectStep.append(stepTemplate)
                })
                
                //reload
                self.delegate?.performAllConfigurations()
                self.delegate?.reloadViews()
                
            }
            
            
        }
    }
    
    //creates step instance from values :)))))))))
    func defineStepTemplate() -> ProjectStep{
        let stepTemplate = ProjectStep()
        //id
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
        //price
        stepTemplate.cost = Int(round(self.stepPriceSlider.value))
        //distance
        stepTemplate.distance = Int(round(self.stepDistanceSlider.value))
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
    
    
    
    //IMAGES
    //------------------------ not realy sure ---------------------- for what?
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
        priceTitle.translatesAutoresizingMaskIntoConstraints = false
        distanceTitle.translatesAutoresizingMaskIntoConstraints = false
        stepNameTextField.translatesAutoresizingMaskIntoConstraints = false
        lineUIView.translatesAutoresizingMaskIntoConstraints = false
        scrollViewContainer.translatesAutoresizingMaskIntoConstraints = false
        contentUIView.translatesAutoresizingMaskIntoConstraints = false
        stepPriceSlider.translatesAutoresizingMaskIntoConstraints = false
        stepPriceValueLabel.translatesAutoresizingMaskIntoConstraints = false
        stepDistanceValueLabel.translatesAutoresizingMaskIntoConstraints = false
        stepDistanceSlider.translatesAutoresizingMaskIntoConstraints = false
        
        
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
        
        stepDistanceValueLabel.centerYAnchor.constraint(equalTo: stepDistanceSlider.centerYAnchor).isActive = true
        stepDistanceValueLabel.leftAnchor.constraint(equalTo: stepDistanceSlider.rightAnchor, constant:  13).isActive = true
        stepDistanceValueLabel.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        stepDistanceValueLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        stepDistanceSlider.topAnchor.constraint(equalTo: distanceTitle.bottomAnchor, constant:  13).isActive = true
        stepDistanceSlider.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        stepDistanceSlider.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -120).isActive = true
        stepDistanceSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        distanceTitle.topAnchor.constraint(equalTo: stepPriceSlider.bottomAnchor, constant:  21).isActive = true
        distanceTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        distanceTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        distanceTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        stepPriceValueLabel.centerYAnchor.constraint(equalTo: stepPriceSlider.centerYAnchor).isActive = true
        stepPriceValueLabel.leftAnchor.constraint(equalTo: stepPriceSlider.rightAnchor, constant:  13).isActive = true
        stepPriceValueLabel.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        stepPriceValueLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        stepPriceSlider.topAnchor.constraint(equalTo: priceTitle.bottomAnchor, constant:  13).isActive = true
        stepPriceSlider.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        stepPriceSlider.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -120).isActive = true
        stepPriceSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        priceTitle.topAnchor.constraint(equalTo: newStepImages.bottomAnchor, constant:  30).isActive = true
        priceTitle.leftAnchor.constraint(equalTo: contentUIView.leftAnchor, constant:  15).isActive = true
        priceTitle.rightAnchor.constraint(equalTo: contentUIView.rightAnchor, constant: -15).isActive = true
        priceTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
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
