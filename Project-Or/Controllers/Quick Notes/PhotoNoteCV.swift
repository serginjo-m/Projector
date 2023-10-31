//
//  PhotoNoteCV.swift
//  Projector
//
//  Created by Serginjo Melnik on 20.06.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
//MARK: OK
class PhotoNotesCollectionViewController: BaseCollectionViewController<PhotoNoteCell, CameraNote> {
    
    //MARK: Properties
    var cameraNotes: Results<CameraNote>{
        get{
            return ProjectListRepository.instance.getCameraNotes()
        }
        set{
            //update after delete...
        }
    }
    
    //animation start point
    var startingFrame: CGRect?
    //black bg
    var blackBackgroundView: UIView?
    //view to zoom in
    var startingImageView: UIImageView?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //define database from realm List<Result>
        setupDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateDatabase()
    }
    
    //MARK: Methods
    override func updateDatabase() {
        //update data base
        cameraNotes = ProjectListRepository.instance.getCameraNotes()
        //from realm to array
        setupDatabase()
        //reload cv
        itemsCollectionView.reloadData()
    }
    
    //convert Realm Result<...> to an array of objects
    func setupDatabase() {
        //clear old data from array
        items.removeAll()
        items.append(contentsOf: cameraNotes)
    }
    
    override func convertNoteToStep(index: Int, project: ProjectList) {
        
        let cameraNote = cameraNotes[index]
        let newStepViewController = NewStepViewController()
        newStepViewController.newStepImages.photoArray.append(cameraNote.picture)
        newStepViewController.projectId = project.id
        newStepViewController.stepNameTextField.text = cameraNote.title
        newStepViewController.viewControllerTitle.text = project.name
        newStepViewController.modalPresentationStyle = .fullScreen
        optionsMenuToggle(toggle: true)
        sectionOptionsContainer.isHidden = true
        present(newStepViewController, animated: true)
    }
    
    @objc override func convertToEvent(_ sender: UIButton){
       
        guard let index = self.sectionOptionsContainer.currentNoteIndex else {return}
        let quickNote = items[index]
        let newEventViewController = NewEventViewController()
        newEventViewController.modalTransitionStyle = .coverVertical
        newEventViewController.modalPresentationStyle = .fullScreen
        newEventViewController.imageHolderView.retreaveImageUsingURLString(myUrl: quickNote.picture)
        newEventViewController.nameTextField.text = quickNote.title
        newEventViewController.pictureUrl = quickNote.picture
        optionsMenuToggle(toggle: true)
        sectionOptionsContainer.isHidden = true
        present(newEventViewController, animated: true, completion: nil)
       
    }
    
    override func removeQuickNote(_ sender: UIButton) {
        guard let index = self.sectionOptionsContainer.currentNoteIndex else {return}
        let quickNote = items[index]
        //create new alert window
        let alertVC = UIAlertController(title: "Delete Text Note?", message: "Are You sure You want to delete this note?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
            
            ProjectListRepository.instance.deleteCameraNote(note: quickNote)

            self.sectionOptionsContainer.isHidden = true

            self.updateDatabase()
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertVC.addAction(deleteAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
    }
   
    //custom zoom in logic
    override func performZoomInForStartingImageView(startingImageView: UIView){
        
        if sectionOptionsContainer.isHidden == false {
            optionsMenuToggle(toggle: true)
            sectionOptionsContainer.isHidden = true
        }
        
        self.startingImageView = startingImageView as? UIImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingImageView.backgroundColor = .red
        if let imageView = startingImageView as? UIImageView, let image = imageView.image {
            zoomingImageView.image = image
        }
        
        
        
        if let keyWindow = UIApplication.shared.keyWindow{
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.alpha = 0
            blackBackgroundView?.backgroundColor = .black
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            //proportion with one side
            //h2 / w2 = h1 / w1
            //h2 = h1 / w1 * w2
            
            let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
            
        }
        
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view {
            
            zoomOutImageView.layer.cornerRadius = 5
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            }) { (completed: Bool) in
                
                //remove it completely
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }
}
