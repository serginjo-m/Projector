//
//  CameraShot.swift
//  Projector
//
//  Created by Serginjo Melnik on 13.04.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
import os
import Photos


class CameraShot: UIViewController,  UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var cameraStatus: Bool = false
    var photoLibraryStatus = PHPhotoLibrary.authorizationStatus()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let viewControllerTitle: UILabel = {
        let label = UILabel()
        label.text = "New Shot"
        label.textColor = UIColor.init(white: 0.7, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    //Camera Shot Image Holder
    let pickerButtonBackground: UIImageView = {
        let image = UIImageView()
        image.isUserInteractionEnabled = true
        image.image = UIImage(named: "takeShot")
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        return image
    }()
    
    //Camera Shot Image Holder
    let photoView: UIImageView = {
        let image = UIImageView()
        image.isUserInteractionEnabled = true
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        return image
    }()
    
    //button stock picture
    lazy var imagePickerButton: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(displayP3Red: 235/255, green: 243/255, blue: 240/255, alpha: 1)
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = 11
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(takePhoto(_:))))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    var photoTitle: UILabel = {
        let label = UILabel()
        label.text = "Give it a title?"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .default
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.placeholder = "Write Your Project Name Here"
        textField.font = UIFont.boldSystemFont(ofSize: 15)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let lineUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0.63, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //.camera or .photoLibrary image source
    var imagePicker: UIImagePickerController!
    //reference to image in photo library
    var selectedImageURL: String?
    var selectedImageHeight: Int?
    var selectedImageWidth: Int?
    
    // ImageSource.camera || ImageSource.photoLibrary
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    override func viewDidLoad() {
        
        //Camera
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                //update camera access permission status for the future use
                self.cameraStatus = true
            }
        }
        
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(dismissButton)
        view.addSubview(saveButton)
        view.addSubview(viewControllerTitle)
        view.addSubview(imagePickerButton)
        imagePickerButton.addSubview(pickerButtonBackground)
        imagePickerButton.addSubview(photoView)
        view.addSubview(photoTitle)
        view.addSubview(titleTextField)
        view.addSubview(lineUIView)
        setupConstraints()
        
        
        titleTextField.delegate = self
        
        //includes keyboard dismiss func from extension
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
 
    
    private func updateSaveButtonState(){
        //Disable the Save button.
        saveButton.isEnabled = true
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //back to previous view
    @objc func saveAction(_ sender: Any) {
        
        guard let imageString = self.selectedImageURL else {return}
        
        let cameraNote = self.createCameraNote(image: imageString)
        
        ProjectListRepository.instance.createCameraNote(cameraNote: cameraNote)
        UserActivitySingleton.shared.createUserActivity(description: "Photo Note was Created")
        self.dismiss(animated: true)
        
    }
    //create note object from camera shot
    func createCameraNote(image: String) -> CameraNote{
        guard let height = self.selectedImageHeight, let width = selectedImageWidth else {fatalError()}
        let note = CameraNote()
        if self.titleTextField.text != nil {
            note.title = self.titleTextField.text
        }
        note.picture = image
        note.height = height
        note.width = width
        return note
    }
    
    //Is camera available or not?
    @objc func takePhoto(_ sender: UITapGestureRecognizer) {
        
        if self.cameraStatus == true {
            selectImageFrom(.camera)
        }else{
            
            switch self.photoLibraryStatus {
            case .authorized:
                self.selectImageFrom(.photoLibrary)
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
    }
    
    private func showPermissionAlert(){
        let ac = UIAlertController(title: "Access to Camera & Photo Library are Denied", message: "To turn on access to photo library or camera, please go to Settings > Notifications > Projector", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }
    
    //lounch image picker
    func selectImageFrom(_ source: ImageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    //Present Alert with some information
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            // we got back an error!
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            fetchLastImage(completion: selectedImageURL)
//            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    //find an address of the last image in photo library
    func fetchLastImage(completion: String?){
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if (fetchResult.firstObject != nil){
            let lastImageAsset: PHAsset = fetchResult.firstObject as! PHAsset
            //have to transfer it here, so I can grab image dimensions
            self.selectedImageHeight = lastImageAsset.pixelHeight
            self.selectedImageWidth = lastImageAsset.pixelWidth
            
            //retreave image URL
            lastImageAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions(), completionHandler: { (contentEditingInput, dictInfo) in
                if lastImageAsset.mediaType == .image {
                    if let strURL = contentEditingInput?.fullSizeImageURL?.description {
                        //print("IMAGE URL: ", strURL)
                        assignUrl(url: strURL)
                    }
                }
            })
            
            func assignUrl(url: String){
                selectedImageURL = url
            }
            
        }
    }
    
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func setupConstraints(){
        let imgHolderHeight = view.bounds.height * 0.67
        
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 85).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        viewControllerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        viewControllerTitle.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor, constant: 0).isActive = true
        viewControllerTitle.widthAnchor.constraint(equalToConstant: 120).isActive = true
        viewControllerTitle.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        imagePickerButton.topAnchor.constraint(equalTo: lineUIView.bottomAnchor, constant: 34).isActive = true
        imagePickerButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        imagePickerButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        imagePickerButton.heightAnchor.constraint(equalToConstant: imgHolderHeight).isActive = true
        
        pickerButtonBackground.leftAnchor.constraint(equalTo: imagePickerButton.leftAnchor, constant: 0).isActive = true
        pickerButtonBackground.rightAnchor.constraint(equalTo: imagePickerButton.rightAnchor, constant: 0).isActive = true
        pickerButtonBackground.centerYAnchor.constraint(equalTo: imagePickerButton.centerYAnchor, constant: 0).isActive = true
        pickerButtonBackground.heightAnchor.constraint(equalToConstant: imgHolderHeight * 0.90).isActive = true
        
        photoView.leftAnchor.constraint(equalTo: imagePickerButton.leftAnchor, constant: 0).isActive = true
        photoView.rightAnchor.constraint(equalTo: imagePickerButton.rightAnchor, constant: 0).isActive = true
        photoView.topAnchor.constraint(equalTo: imagePickerButton.topAnchor, constant: 0).isActive = true
        photoView.bottomAnchor.constraint(equalTo: imagePickerButton.bottomAnchor, constant: 0).isActive = true
        
        photoTitle.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 20).isActive = true
        photoTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        photoTitle.widthAnchor.constraint(equalToConstant: 200).isActive = true
        photoTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        titleTextField.topAnchor.constraint(equalTo: photoTitle.bottomAnchor, constant: -8).isActive = true
        titleTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        titleTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        titleTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        lineUIView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 4).isActive = true
        lineUIView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        lineUIView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        lineUIView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}


extension CameraShot: UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        
        //save action
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        updateSaveButtonState()
        
        //assign image to imageView
        photoView.image = selectedImage
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
}
