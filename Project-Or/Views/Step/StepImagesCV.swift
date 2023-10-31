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
    
    //MARK: Properties
    private let cellIdent = "cellId"

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

        let layout = UICollectionViewFlowLayout()

        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clear

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    func setupStepImages(){
        
        addArrangedSubview(stepImagesCollectionView)
        
        stepImagesCollectionView.dataSource = self
        stepImagesCollectionView.delegate = self
        
        stepImagesCollectionView.showsVerticalScrollIndicator = false
        stepImagesCollectionView.showsHorizontalScrollIndicator = false
        
        stepImagesCollectionView.register(StepImageCell.self, forCellWithReuseIdentifier: cellIdent)
    
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepImagesCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepImagesCollectionView]))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        return CGSize(width: 144, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return step.selectedPhotosArray.count
    }
    
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
