//
//  StepsCategoryCollectionView.swift
//  Projector
//
//  Created by Serginjo Melnik on 07.11.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

protocol StepsCollectionViewDelegate: AnyObject {
    //show view at the point
    func showView(startingUIButton: UIButton)
}


class StepsCategoryCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, StepsCollectionViewDelegate{
    //menu that contains progress options
    lazy var progressMenu: StepProgressMenu = {
        let menu = StepProgressMenu()
        menu.translatesAutoresizingMaskIntoConstraints = false
        return menu
    }()

    let cellId = "cellId"
    
    var projectSteps = [ProjectStep]()
    //the only reason it here, it's because I need to have an access to navigationController.push...
    
    //access DetailViewController (reload, push, setupViews)
    weak var customDelegate: EditViewControllerDelegate?{
        didSet{
            progressMenu.delegate = customDelegate
        }
    }
    
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
    
    //variable constraints for animation
    var statusOptionsRightConstraint: NSLayoutConstraint?
    var statusOptionsTopConstraint: NSLayoutConstraint?
    
    
    //menu position next to the selected cell button
    func showView(startingUIButton: UIButton) {
        //view position
        let properCoordinates = self.superview?.convert(self.frame, to: nil)
        //button position
        let startingFrame = startingUIButton.superview?.convert(startingUIButton.frame, to: nil)
        guard let topOffset = startingFrame?.origin.y, let rightOffset = startingFrame?.origin.x else {return}
        statusOptionsTopConstraint?.constant = topOffset - properCoordinates!.origin.y
        statusOptionsRightConstraint?.constant = rightOffset - 30
        self.layoutIfNeeded()
        //select step using buttons tag, that corresponds to the cell number
        progressMenu.projectStep = projectSteps[startingUIButton.tag]
    }
    
    func setupLayout(){
        
        addSubview(progressMenu)
        backgroundColor = UIColor.clear
        
        statusOptionsTopConstraint = progressMenu.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        statusOptionsRightConstraint = progressMenu.rightAnchor.constraint(equalTo: leftAnchor, constant: 0)
        statusOptionsRightConstraint?.isActive  = true
        statusOptionsTopConstraint?.isActive = true
        
        progressMenu.heightAnchor.constraint(equalToConstant: 160).isActive = true
        progressMenu.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        
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
        cell.delegate = self
        //buttons tag corresponds to step index in projectSteps
        cell.optionsButton.tag = indexPath.item
        cell.template = projectSteps[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //use DetailViewController for segue
        self.customDelegate?.pushToViewController(stepId: projectSteps[indexPath.item].id)
    }
    
}
