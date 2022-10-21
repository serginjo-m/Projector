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
        //define database from realm List<Result>
        setupDatabase()
        viewControllerTitle.text = "Canvas Notes"
        viewControllerTitle.textColor = UIColor.init(white: 0.1, alpha: 1)
        view.backgroundColor = UIColor.init(white: 0.91, alpha: 1)
    }
    
    //MARK: Methods
    //reload everything
    override func updateDatabase() {
        //update data base
        canvasNotes = ProjectListRepository.instance.getCanvasNotes()
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
        for item in canvasNotes {
            items.append(item)
        }
        
    }
    
    //custom zoom in logic
    override func performZoomInForStartingImageView(startingImageView: UIView){
        
        
        self.startingImageView = startingImageView as? DrawCanvasView
        
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        //canvas
        let zoomingImageView = DrawCanvasView(frame: startingFrame!)
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingImageView.backgroundColor = .white
        
        if let drawCanvas = startingImageView as? DrawCanvasView {
            zoomingImageView.canvasObject = drawCanvas.canvasObject
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

                zoomingImageView.center = keyWindow.center
                zoomingImageView.transform = CGAffineTransform(scaleX: 2, y: 2)
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

//canvas note cell
class CanvasNoteCell: BaseCollectionViewCell<CanvasNote> {
    
    //It'll be like a template for our cell
    override var item: CanvasNote! {
        //didSet uses for logic purposes!
        didSet{
            canvas.canvasObject = item
        }
    }
    
    lazy var canvas: DrawCanvasView = {
        let canvas = DrawCanvasView()
        canvas.backgroundColor = .white
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.isUserInteractionEnabled = true
        canvas.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return canvas
    }()
    
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"projectRemoveButton"), for: .normal)
        button.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //remove item
    @objc func deleteAction (_ sender: UIButton){
        guard let delegate = self.delegate else {return}
        //remove object
        ProjectListRepository.instance.deleteCanvasNote(note: item)
        //update cv
        delegate.updateDatabase()
    }
    
    //call to zoom in logic
    @objc func handleZoomTap(sender: UITapGestureRecognizer){
        
        guard let delegate = self.delegate else {return}
        
        if let canvasView = sender.view as? DrawCanvasView{
            //parent func that run all logic
            delegate.performZoomInForStartingImageView(startingImageView: canvasView)
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
        
        addSubview(canvas)
        addSubview(deleteButton)
                
        deleteButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 11).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -11).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        canvas.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        canvas.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        canvas.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        canvas.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
}

// Pinterest Layout Configurations
extension CanvasNotesCollectionViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let imageHeight = Double(items[indexPath.item].canvasMaxHeight) / 3.5
        return CGFloat(imageHeight)
    }
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
}
