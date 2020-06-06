//
//  StepVCImageCV.swift
//  Projector
//
//  Created by Serginjo Melnik on 23.04.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class StepImagesCollectionView: UIStackView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //Properties
    private let cellIdent = "cellId"
    //an instance of selected step
    var step: ProjectStep?
    //temporary image source
//    let imagesArray = ["interior","workspace", "river" ]
    var photosArray = [UIImage]()
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStepImages()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStepImages()
    }
    
    let stepImagesCollectionView: UICollectionView = {
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clear
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    func setupStepImages(){
        // Add a DataView to the stackView
        addArrangedSubview(stepImagesCollectionView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        stepImagesCollectionView.dataSource = self
        stepImagesCollectionView.delegate = self
        
        //Class is need to be registered in order of using inside
        stepImagesCollectionView.register(StepImageCell.self, forCellWithReuseIdentifier: cellIdent)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepImagesCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepImagesCollectionView]))
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //here we don't need to use view.frame.height becouse our CategoryCell have it
        return CGSize(width: 134, height: frame.height)
    }
    
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        if let urlArray = step?.selectedPhotosArray{
            return urlArray.count
        }
        
        return 0
    }
    
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdent, for: indexPath) as! StepImageCell
        
        cell.stepImage.image = photosArray[indexPath.row]
        return cell
    }
}

class StepImageCell: UICollectionViewCell{
    
    //Properties
    var stepImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "interior")
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    
    //initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 6
        layer.masksToBounds = true
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        backgroundColor = UIColor.lightGray
        
        addSubview(stepImage)
        stepImage.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
}
