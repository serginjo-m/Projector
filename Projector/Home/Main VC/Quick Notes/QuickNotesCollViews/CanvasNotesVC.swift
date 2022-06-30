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
    var canvasNotes: Results<CanvasNote>{
        get{
            return ProjectListRepository.instance.getCanvasNotes()
        }
        set{
            //need this option for updating after delete
        }
    }
    //reload everything
    override func updateDatabase() {
        //update data base
        canvasNotes = ProjectListRepository.instance.getCanvasNotes()
        //from realm to array
        setupDatabase()
        //reload cv
        itemsCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //define database from realm List<Result>
        setupDatabase()
        viewControllerTitle.text = "Canvas Notes"
        viewControllerTitle.textColor = UIColor.init(white: 0.1, alpha: 1)
        view.backgroundColor = UIColor.init(white: 0.91, alpha: 1)
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
    
    let canvas = DrawCanvasView()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"projectRemoveButton"), for: .normal)
        button.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
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
        
        addSubview(canvas)
        addSubview(deleteButton)
        
        canvas.backgroundColor = .white
        
        
        canvas.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
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
