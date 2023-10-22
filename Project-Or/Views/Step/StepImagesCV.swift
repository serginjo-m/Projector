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
    var step: ProjectStep
    
    var parentViewController: StepViewController
    
    //MARK: Initialization
    init(parentVC: StepViewController, step: ProjectStep, frame: CGRect) {
        
        self.parentViewController = parentVC
        
        self.step = step
        super.init(frame: frame)
        setupStepImages()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let stepImagesCollectionView: UICollectionView = {
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        //because every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
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
        
        //hide scrollbar
        stepImagesCollectionView.showsVerticalScrollIndicator = false
        stepImagesCollectionView.showsHorizontalScrollIndicator = false
        
        //Class is need to be registered in order of using inside
        stepImagesCollectionView.register(StepImageCell.self, forCellWithReuseIdentifier: cellIdent)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepImagesCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepImagesCollectionView]))
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //here we don't need to use view.frame.height because our CategoryCell have it
        //144???
        return CGSize(width: 144, height: frame.height)
    }
    
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return step.selectedPhotosArray.count
    }
    
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdent, for: indexPath) as! StepImageCell
        
        cell.template = step.selectedPhotosArray[indexPath.item]
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomInCell(_:))))
        return cell
    }
    
    @objc func zoomInCell(_ tapGestrure: UITapGestureRecognizer){
        if let cell = tapGestrure.view as? StepImageCell{
            self.parentViewController.performZoomForCollectionImageView(startingImageView: cell)
        }
    }
    
}
