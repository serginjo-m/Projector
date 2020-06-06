//
//  NewStepImages.swift
//  Projector
//
//  Created by Serginjo Melnik on 02.05.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift


protocol NewStepImagesDelegate: class{
    func showImagePicker()
}

class NewStepImages: UIStackView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var delegate: NewStepImagesDelegate?
    
    //this property need for cells
    private let cellID = "cellId"
    //array contains default 'plus' image
    var photoArray = [UIImage(named: "addPhoto")]
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageCollectionView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupImageCollectionView()
    }
    
    //here creates a horizontal collectionView inside stackView
    let imageCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //layout.itemSize = CGSize(width: 120, height: 45)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        
        
        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        collectionView.backgroundColor = UIColor.clear
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    func setupImageCollectionView(){
        // Add a collectionView to the stackView
        addArrangedSubview(imageCollectionView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        //Class is need to be registered in order of using inside
        imageCollectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": imageCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": imageCollectionView]))
    }
    
    //add image mechanism
    @objc func handleTap(_ sender: UITapGestureRecognizer){
        //delegate callback function
        self.delegate?.showImagePicker()
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //here we don't need to use view.frame.height becouse our CategoryCell have it
        return CGSize(width: 64, height: 64)
    }
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //default array
        return photoArray.count
    }
    
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ImageCollectionViewCell
        
        //tap gesture recognizer for UIImageView
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        cell.photoView.addGestureRecognizer(tap)
        //add image
        cell.photoView.image = photoArray[indexPath.row]
        return cell
    }
}

class ImageCollectionViewCell: UICollectionViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        //layer.cornerRadius = 3
        //layer.masksToBounds = true
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let photoView: UIImageView = {
        let photo = UIImageView()
        photo.contentMode = .scaleAspectFill
        photo.clipsToBounds = true
        photo.isUserInteractionEnabled = true
        return photo
    }()
    
    func setupViews(){
        backgroundColor = UIColor.lightGray
        addSubview(photoView)
        photoView.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
    }
}
