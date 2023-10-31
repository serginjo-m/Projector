//
//  CanvasCVViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 09.06.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift
//MARK: OK
class TextNotesCollectionViewController: BaseCollectionViewController<TextNoteCell, TextNote>{
    
    //MARK: Properties
    var textNotes: Results<TextNote>{
        get{
            return ProjectListRepository.instance.getTextNotes()
        }
        set{
            //update after delete
        }
    }
    
    //animation start point
    var startingFrame: CGRect?
    //black bg
    var blackBackgroundView: UIView?
    //view to zoom in
    var startingImageView: UIView?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //define database from realm List<Result>
        setupDatabase()
        viewControllerTitle.text = "Text Notes"
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateDatabase()
    }
    
    //MARK: Methods
    //reload everything
    override func updateDatabase() {
        //update data base
        textNotes = ProjectListRepository.instance.getTextNotes()
        //from realm to array
        setupDatabase()
        //reload cv
        itemsCollectionView.reloadData()
    }
    
    //convert Realm Result<...> to an array of object.
    func setupDatabase() {
        
        //clear old data from array
        items.removeAll()
        
        //not so efficient, but it works
        for item in textNotes {
            items.append(item)
        }
        
    }
    
    @objc override func convertToEvent(_ sender: UIButton){
        guard let index = self.sectionOptionsContainer.currentNoteIndex else {return}
        let quickNote = items[index]
        let newEventViewController = NewEventViewController()
        newEventViewController.modalTransitionStyle = .coverVertical
        newEventViewController.modalPresentationStyle = .fullScreen
        newEventViewController.descriptionTextView.text = quickNote.text
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
            
            ProjectListRepository.instance.deleteTextNote(textNote: quickNote)
            UserActivitySingleton.shared.createUserActivity(description: "Text note was deleted" )
            self.sectionOptionsContainer.isHidden = true

            self.updateDatabase()
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertVC.addAction(deleteAction)
        alertVC.addAction(cancelAction)
        
        //shows an alert window
        present(alertVC, animated: true, completion: nil)
    }
    
    override func convertNoteToStep(index: Int, project: ProjectList) {
        
        let textNote = textNotes[index]
        
        let wordsArray = textNote.text.components(separatedBy: " ")
        
        var compoundTitleForStep = ""
        
        if wordsArray.count < 3 {
            guard let firstWord = wordsArray.first else {return}
            compoundTitleForStep = firstWord
        }else{
            for number in 0...2 {
                if number < 2 {
                    compoundTitleForStep.append("\(wordsArray[number]) ")
                }else{
                    compoundTitleForStep.append("\(wordsArray[number])...")
                }
            }
        }
        
        let newStepViewController = NewStepViewController()
        newStepViewController.projectId = project.id
        newStepViewController.viewControllerTitle.text = project.name
        newStepViewController.stepNameTextField.text = compoundTitleForStep
        newStepViewController.comment = textNote.text
        newStepViewController.descriptionTextView.text = textNote.text
        newStepViewController.modalPresentationStyle = .fullScreen
        optionsMenuToggle(toggle: true)
        sectionOptionsContainer.isHidden = true
        present(newStepViewController, animated: true)
    }
    

    //custom zoom in logic
    override func performZoomInForStartingImageView(startingImageView: UIView){
        
        if sectionOptionsContainer.isHidden == false {
            optionsMenuToggle(toggle: true)
            sectionOptionsContainer.isHidden = true
        }
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true

        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)

        guard let textNoteCell = startingImageView as? TextNoteCell, let noteText = textNoteCell.textLabel.text else {return}
            
        //textNote
        let zoomingTextView = TextNoteView(text: noteText, frame: startingFrame!)
        zoomingTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow{
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.alpha = 0
            blackBackgroundView?.backgroundColor = .black

            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingTextView)

            //proportion with one side
            //h2 / w2 = h1 / w1
            //h2 = h1 / w1 * w2

            var height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
            if height >= keyWindow.frame.height {
                height = keyWindow.frame.height
            }

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                zoomingTextView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingTextView.center = keyWindow.center

            }, completion: nil)

        }
        
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutView = tapGesture.view {
            guard let zoom = zoomOutView as? TextNoteView else {return}
            zoomOutView.layer.cornerRadius = 5
            zoomOutView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                
                zoom.textLabel.font = UIFont.boldSystemFont(ofSize: 15)
                
                [zoom.textLabelTopAnchorConstraint, zoom.textLabelLeadingAnochorConstraint, zoom.textLabelTrailingAnchorConstraint, zoom.textLabelBottomAnchorConstraint].forEach { constraint in
                    constraint.isActive = false
                }
                
                [zoom.textLabelHeightAnchorConstraint, zoom.textLabelWidthAnchorConstraint, zoom.textLabelCenterYAnchorConstraint, zoom.textLabelCenterXAnchorConstraint].forEach { constraint in
                    constraint.isActive = true
                }
                
                zoom.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            }) { (completed: Bool) in
                
                //remove it completely
                zoomOutView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }
}

