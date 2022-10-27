//
//  PhotoNoteCV.swift
//  Projector
//
//  Created by Serginjo Melnik on 20.06.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class PhotoNotesCollectionViewController: BaseCollectionViewController<PhotoNoteCell, CameraNote> {
    
    var cameraNotes: Results<CameraNote>{
        get{
            return ProjectListRepository.instance.getCameraNotes()
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
    var startingImageView: UIImageView?
    
    
    //reload everything
    override func updateDatabase() {
        //update data base
        cameraNotes = ProjectListRepository.instance.getCameraNotes()
        //from realm to array
        setupDatabase()
        //reload cv
        itemsCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //define database from realm List<Result>
        setupDatabase()
    }
    
    //convert Realm Result<...> to an array of object.
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

// Pinterest Layout Configurations
extension PhotoNotesCollectionViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return CGFloat(items[indexPath.item].height)
    }
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return CGFloat(items[indexPath.item].width)
    }
}


//Photo note cell
class PhotoNoteCell: BaseCollectionViewCell<CameraNote> {
    
    //It'll be like a template for our cell
    override var item: CameraNote! {
        //didSet uses for logic purposes!
        didSet{
            titleLabel.text = item.title != "" ? item.title : ""
            //shared func for all items that need to convert a url to an image
            image.retreaveImageUsingURLString(myUrl: item.picture)
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
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textColor = UIColor.white
        return label
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
        layer.masksToBounds = true
        layer.cornerRadius = 5
        
        addSubview(image)
        addSubview(titleLabel)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        image.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        image.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 9).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -9).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
}
