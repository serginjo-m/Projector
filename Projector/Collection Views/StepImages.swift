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

//Connection btwn ....
protocol NewStepImagesDelegate: class{
    //delete image url from parent array that will be used for saving object
    func deleteUrl(int: Int)
    //opens parent VC image picker
    func showImagePicker()
}

class NewStepImages: UIStackView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var delegate: NewStepImagesDelegate?
    
    //this property need for cells
    private let cellID = "cellId"
    //array contains default 'plus' image
    var photoArray = [UIImage(named: "plusIconV2")]
    
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
        
        layout.sectionInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        //layout.itemSize = CGSize(width: 120, height: 45)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 28
        
        
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
        
        //hide scrollbar
        imageCollectionView.showsVerticalScrollIndicator = false
        imageCollectionView.showsHorizontalScrollIndicator = false
        
        //Class is need to be registered in order of using inside
        imageCollectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": imageCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": imageCollectionView]))
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //here we don't need to use view.frame.height becouse our CategoryCell have it
        return CGSize(width: 59, height: 59)
    }
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //default number
        var numberOfCells = 8
        //if all cells contain picture, adds more
        if photoArray.count > 8 {
            numberOfCells = photoArray.count
        }
        return numberOfCells
    }
    
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ImageCollectionViewCell
        
        //tap gesture recognizer for UIImageView
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        
        //delete image button configuration
        cell.deleteButton.addTarget(self, action: #selector(removeImage(button:)), for: .touchUpInside)
        cell.deleteButton.tag = indexPath.row
        
        //append img to cell only if it exist
        if indexPath.row < photoArray.count{
            cell.deleteButton.isHidden = false
            cell.photoView.image = photoArray[indexPath.row]
        }else{
            cell.deleteButton.isHidden = true
            //default image
            cell.photoView.image = UIImage(named: "border")
        }
        //plus cell
        if indexPath.row == 0{
            cell.backgroundColor = .white
            cell.photoView.addGestureRecognizer(tap)
            cell.deleteButton.isHidden = true
        }
        
        return cell
    }
    
    //remove image mechanism
    @objc func removeImage(button: UIButton){
        
//        photoArray.remove(at: button.tag)
        self.delegate?.deleteUrl(int: button.tag)
        imageCollectionView.reloadData()
    }
    
    //add image mechanism
    @objc func handleTap(_ sender: UITapGestureRecognizer){
        //delegate callback function
        self.delegate?.showImagePicker()
    }
}

class ImageCollectionViewCell: UICollectionViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.init(displayP3Red: 63/255, green: 63/255, blue: 63/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.setBackgroundImage(UIImage(named: "cross"), for: .normal)
        button.clipsToBounds = true
        button.isHidden = true
        return button
    }()
    
    let photoView: UIImageView = {
        let photo = UIImageView()
        photo.image = UIImage(named: "border")
        photo.contentMode = .scaleAspectFill
        photo.clipsToBounds = true
        photo.isUserInteractionEnabled = true
        photo.layer.cornerRadius = 6
        return photo
    }()
    
    func setupViews(){
        addSubview(photoView)
        addSubview(deleteButton)

        photoView.frame = CGRect(x: 0, y: 0, width: 59, height: 59)
        deleteButton.frame = CGRect(x: 43, y: -6, width: 22, height: 22)

    }
}
