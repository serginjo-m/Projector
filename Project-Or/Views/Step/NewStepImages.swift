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

class NewStepImages: UIStackView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //MARK: Properties
    var delegate: NewStepImagesDelegate?
    
    private let cellID = "cellId"
    
    var photoArray = List<String>()
    
    let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 28
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageCollectionView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupImageCollectionView()
    }
    
    //MARK: Methods
    func setupImageCollectionView(){
        
        addArrangedSubview(imageCollectionView)
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.showsVerticalScrollIndicator = false
        imageCollectionView.showsHorizontalScrollIndicator = false
        imageCollectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": imageCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": imageCollectionView]))
    }
    
    @objc func removeImage(button: UIButton){
        photoArray.remove(at: button.tag - 1)
        imageCollectionView.reloadData()
        
    }
    
    //MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 59, height: 59)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfCells = 8
        if photoArray.count > 8 {
            numberOfCells = photoArray.count
        }
        return numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            self.delegate?.showImagePicker()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ImageCollectionViewCell
        
        cell.deleteButton.addTarget(self, action: #selector(removeImage(button:)), for: .touchUpInside)
        cell.deleteButton.tag = indexPath.row
        
        var template = NewStepImageCellTemplate(imageURL: nil, canvas: nil, tag: indexPath.item)

        if photoArray.count >= indexPath.item && indexPath.item != 0{
            template.imageURL = photoArray[indexPath.item - 1]
        }
        
        cell.template = template
        
        return cell
    }
}
