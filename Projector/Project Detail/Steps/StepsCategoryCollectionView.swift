//
//  StepsCategoryCollectionView.swift
//  Projector
//
//  Created by Serginjo Melnik on 07.11.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

class StepsCategoryCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    let cellId = "cellId"
    
    var projectSteps = [ProjectStep]()
    //the only reason it here, it's because I need to have an access to navigationController.push...
    weak var customDelegate: EditViewControllerDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupLayout()
        //define delegate in Pinterest Layout, so it change cell size
        if let layout = self.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        } 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout(){
        
        
        backgroundColor = UIColor.clear
        
        //specify delegate & datasourse for generating our individual horizontal cells
        dataSource = self
        delegate = self
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        //Class is need to be registered in order of using inside
        register(StepCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projectSteps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StepCell
        cell.template = projectSteps[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        self.customDelegate?.pushToViewController(stepId: projectSteps[indexPath.item].id)
    }
    
}
