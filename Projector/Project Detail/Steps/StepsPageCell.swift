//
//  StepsPageCell.swift
//  Projector
//
//  Created by Serginjo Melnik on 01.11.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class StepsPageCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    //initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var cellId = "cellID"
    
    //here creates a horizontal collectionView
    lazy var stepsCategoryCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 3
        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this instance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clear
        
        //specify delegate & datasourse for generating our individual horizontal cells
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        //Class is need to be registered in order of using inside
        collectionView.register(StepCell.self, forCellWithReuseIdentifier: cellId)
        
        return collectionView
    }()
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StepCell
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: 60)
    }
    
    fileprivate func setupViews(){
        addSubview(stepsCategoryCollectionView)
        
        
        stepsCategoryCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        stepsCategoryCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        stepsCategoryCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        stepsCategoryCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
    
    
    
}
