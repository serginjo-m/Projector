//
//  CanvasCVViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 09.06.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class TextNotesCollectionViewController: BaseCollectionViewController<TextNoteCell, TextNote>{
    var textNotes: Results<TextNote>{
        get{
            return ProjectListRepository.instance.getTextNotes()
        }
        set{
            //need this option for updating after delete
        }
    }
    //reload everything
    override func updateDatabase() {
        //update data base
        textNotes = ProjectListRepository.instance.getTextNotes()
        //from realm to array
        setupDatabase()
        //reload cv
        itemsCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //define database from realm List<Result>
        setupDatabase()
        viewControllerTitle.text = "Text Notes"
        view.backgroundColor = .white
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
}

//Photo note cell
class TextNoteCell: BaseCollectionViewCell<TextNote> {
    
    //It'll be like a template for our cell
    override var item: TextNote! {
        //didSet uses for logic purposes!
        didSet{
            textLabel.text = item.text
        }
    }
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = NSTextAlignment.left
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
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
        ProjectListRepository.instance.deleteTextNote(textNote: item)
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
        
        addSubview(deleteButton)
        addSubview(textLabel)
        
        textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        textLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        textLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 11).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -11).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
}

// Pinterest Layout Configurations
extension TextNotesCollectionViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let cellHeight = CGFloat(items[indexPath.row].height + 20)
        return cellHeight
    }
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
}
