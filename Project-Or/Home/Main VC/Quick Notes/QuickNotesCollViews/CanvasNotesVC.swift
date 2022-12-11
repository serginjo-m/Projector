//
//  CanvasCVViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 09.06.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class CanvasNotesCollectionViewController: BaseCollectionViewController<CanvasNoteCell, CanvasNote>{
    
    //MARK: Properties
    var canvasNotes: Results<CanvasNote>{
        get{
            return ProjectListRepository.instance.getCanvasNotes()
        }
        set{
            //need this option for updating after delete
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
        viewControllerTitle.text = "Canvas Notes"
        viewControllerTitle.textColor = UIColor.init(white: 0.1, alpha: 1)
        view.backgroundColor = UIColor.init(white: 1, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateDatabase()
    }
    
    
    //MARK: Methods
    //reload everything
    override func updateDatabase() {
        //clear old data from array
        items.removeAll()
        //update data base
        items.append(contentsOf: ProjectListRepository.instance.getCanvasNotes())
        //from realm to array
        //reload cv
        itemsCollectionView.reloadData()
    }
    
    override func convertNoteToStep(index: Int, project: ProjectList) {
        
        let canvasNote = canvasNotes[index]
        
        let newStepViewController = NewStepViewController()
        newStepViewController.newStepImages.photoArray.append(canvasNote.imageUrl)
        newStepViewController.projectId = project.id
        newStepViewController.viewControllerTitle.text = project.name
        newStepViewController.modalPresentationStyle = .fullScreen
        newStepViewController.stepNameTextField.text = "Canvas Note"
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
        newEventViewController.imageHolderView.retreaveImageUsingURLString(myUrl: quickNote.imageUrl)
        newEventViewController.pictureUrl = quickNote.imageUrl
        optionsMenuToggle(toggle: true)
        sectionOptionsContainer.isHidden = true
        //show new event view controller
        present(newEventViewController, animated: true, completion: nil)
    }
    
    override func removeQuickNote(_ sender: UIButton) {
        guard let index = self.sectionOptionsContainer.currentNoteIndex else {return}

        let quickNote = items[index]
        //create new alert window
        let alertVC = UIAlertController(title: "Delete Text Note?", message: "Are You sure You want to delete this note?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
            
            ProjectListRepository.instance.deleteCanvasNote(note: quickNote)

            self.sectionOptionsContainer.isHidden = true

            self.updateDatabase()
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertVC.addAction(deleteAction)
        alertVC.addAction(cancelAction)
        
        //shows an alert window
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
            
            //math? of proportion with one side
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
//MARK: Cell
//canvas note cell
class CanvasNoteCell: BaseCollectionViewCell<CanvasNote> {
    
    //It'll be like a template for our cell
    override var item: CanvasNote! {
        //didSet uses for logic purposes!
        didSet{
            image.retreaveImageUsingURLString(myUrl: item.imageUrl)
        }
    }
    
    lazy var image: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "river")
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    
    //call to zoom in logic
    @objc func handleZoomTap(sender: UITapGestureRecognizer){
        guard let delegate = self.delegate else {return}
        if let imageView = sender.view as? UIImageView{
            //parent func that run all logic
            delegate.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    
    //initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        layer.masksToBounds = true
        layer.cornerRadius = 5
        
        addSubview(image)
        
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        image.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        image.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
    }
}

// Pinterest Layout Configurations
extension CanvasNotesCollectionViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(items[indexPath.item].height)
    }
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(items[indexPath.item].width)
    }
}