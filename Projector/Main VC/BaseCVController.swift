//
//  SampleCVController.swift
//  Projector
//
//  Created by Serginjo Melnik on 20.05.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

//Base for collection View controller
class BaseCollectionViewController<T: BaseCollectionViewCell<U>, U >: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    let cellId = "cellId"
    
    //data base
    var items = [U]()
    
    //navigation
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
        label.text = "Camera Notes"
        label.textColor = UIColor.init(white: 0.7, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        collectionView.backgroundColor = .white
        //refer to cell, that is need to be passed when initialize class
        collectionView.register(T.self, forCellWithReuseIdentifier: cellId)
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //Collection View 
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BaseCollectionViewCell<U>
        
        cell.item = items[indexPath.row]
        
        return cell
    }
}

class BaseCollectionViewCell<U>: UICollectionViewCell {
    
    var item: U!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .yellow
    }
    
}

class PhotoNotesCollectionViewController: BaseCollectionViewController<PhotoNoteCell, CameraNote> {
    
    var cameraNotes: Results<CameraNote>{
        get{
           return ProjectListRepository.instance.getCameraNotes()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //---------------------------- why here?? --------------------------------
        if let layout = collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        
        //--------------- not so efficient, but it works ----------------
        for item in cameraNotes {
            items.append(item)
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
            
            image.image = retreaveImageForProject(myUrl: item.picture)
        }
    }
    
    //return UIImage by URL
    func retreaveImageForProject(myUrl: String) -> UIImage{
        var projectImage: UIImage = UIImage(named: "defaultImage")!
        let url = URL(string: myUrl)
        let data = try? Data(contentsOf: url!)
        if let imageData = data{
            projectImage = UIImage(data: imageData)!
        }
        return projectImage
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
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"projectRemoveButton"), for: .normal)
        return button
    }()
    
    //call to zoom in logic
    @objc func handleZoomTap(sender: UITapGestureRecognizer){
        if let imageView = sender.view as? UIImageView{
            //parent func that run all logic
//            self.categoryItemsController?.performZoomInForStartingImageView(startingImageView: imageView)
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
        addSubview(deleteButton)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        image.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        image.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 9).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -9).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        deleteButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 11).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -11).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
}
