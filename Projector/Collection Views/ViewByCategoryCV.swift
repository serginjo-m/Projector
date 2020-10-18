//
//  RecentActivitiesCV.swift
//  Projector
//
//  Created by Serginjo Melnik on 05.10.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

// template that holds configuration for every cell
class CategoryButtonSetting: NSObject{
    let imageName: String
    let cellColor: UIColor
    let buttonTitle: String
    let imageWidth: CGFloat
    let imageHeight: CGFloat
    let imageTopAnchor: CGFloat
    let imageLeftAnchor: CGFloat
    let titleLeftAnchor: CGFloat
    
    init(imageName: String, cellColor: UIColor, buttonTitle: String, imageWidth: CGFloat, imageHeight: CGFloat, imageTopAnchor: CGFloat, imageLeftAnchor: CGFloat, titleLeftAnchor: CGFloat){
        self.imageName = imageName
        self.cellColor = cellColor
        self.buttonTitle = buttonTitle
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.imageTopAnchor = imageTopAnchor
        self.imageLeftAnchor = imageLeftAnchor
        self.titleLeftAnchor = titleLeftAnchor
    }
}

class ViewByCategoryCollectionView: UIStackView,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    //this property need for cells
    private let cellID = "cellId"
    
    // cell settings
    let cellSettingsArray: [CategoryButtonSetting] = {
        return [
            CategoryButtonSetting(
                imageName: "notes",
                cellColor: UIColor.init(red: 132/255, green: 211/255, blue: 171/255, alpha: 1),
                buttonTitle: "QUICK NOTES",
                imageWidth: 49,
                imageHeight: 74,
                imageTopAnchor: 12,
                imageLeftAnchor: -2,
                titleLeftAnchor: 61
            ),
            CategoryButtonSetting(
                imageName: "rocket",
                cellColor:UIColor.init(red: 242/255, green: 98/255, blue: 98/255, alpha: 1),
                buttonTitle: "PROJECTS",
                imageWidth: 60,
                imageHeight: 77,
                imageTopAnchor: 0,
                imageLeftAnchor: 0,
                titleLeftAnchor: 43
            ),
            CategoryButtonSetting(
                imageName: "calendar",
                cellColor: UIColor.init(red: 12/255, green: 154/255, blue: 242/255, alpha: 1),
                buttonTitle: "EVENTS",
                imageWidth: 32,
                imageHeight: 60,
                imageTopAnchor: 5,
                imageLeftAnchor: 0,
                titleLeftAnchor: 52
            )
        ]
    }()
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewByCategoryView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupViewByCategoryView()
    }
    
    //here creates a horizontal collectionView inside stackView
    let viewByCategoryCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        //spacing...
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //layout.itemSize = CGSize(width: 120, height: 45)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        
        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        collectionView.backgroundColor = UIColor.clear
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    func setupViewByCategoryView(){
        
        // Add a collectionView to the stackView
        addArrangedSubview(viewByCategoryCollectionView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        viewByCategoryCollectionView.dataSource = self
        viewByCategoryCollectionView.delegate = self
        
        //Class is need to be registered in order of using inside
        viewByCategoryCollectionView.register(ViewByCategoryCell.self, forCellWithReuseIdentifier: cellID)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": viewByCategoryCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": viewByCategoryCollectionView]))
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //here we don't need to use view.frame.height becouse our CategoryCell have it
        return CGSize(width: 125, height: frame.height)
    }
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ViewByCategoryCell
        
        
        //here is IMPORTANT part, when I pass settings for every cell
        cell.imageSetting = cellSettingsArray[indexPath.row]
        
        return cell
        
    }
    
    //turn cells to be selectable
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    //action when user selects the cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //that is how I can call a selected cell !!!
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.red
    }
    //makes cells deselectable
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    //define color of deselected cell
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1)
    }
    
}

class ViewByCategoryCell: UICollectionViewCell {
    
    var imageSetting: CategoryButtonSetting? {
        didSet{
            if let setting = imageSetting{
                
                //constraints func , becouse elements needs to be positioned differently
                configureConstraints(width: setting.imageWidth, height: setting.imageHeight, top: setting.imageTopAnchor, left: setting.imageLeftAnchor, titleLeft: setting.titleLeftAnchor)
                
                //background color
                backgroundColor = setting.cellColor
                
                //title
                buttonTitleLabel.text = setting.buttonTitle
                
                //image
                buttonBackgroundImage.image = UIImage(named: setting.imageName)
            }
        }
    }
    
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
    
    let buttonTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(white: 1, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.numberOfLines = 0
        return label
    }()
    
    let buttonBackgroundImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "notes")
        return image
    }()
    
    func setupViews(){
        
        //mask content outside cell
        layer.masksToBounds = true
        layer.cornerRadius = 8
        
        addSubview(buttonTitleLabel)
        addSubview(buttonBackgroundImage)
        
        buttonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonBackgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func configureConstraints(width: CGFloat, height: CGFloat, top: CGFloat, left: CGFloat, titleLeft: CGFloat){
        buttonBackgroundImage.topAnchor.constraint(equalTo: topAnchor, constant: top).isActive = true
        buttonBackgroundImage.leftAnchor.constraint(equalTo: leftAnchor, constant: left).isActive = true
        buttonBackgroundImage.widthAnchor.constraint(equalToConstant: width).isActive = true
        buttonBackgroundImage.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        buttonTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        buttonTitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: titleLeft).isActive = true
        buttonTitleLabel.widthAnchor.constraint(equalToConstant: 71).isActive = true
        buttonTitleLabel.heightAnchor.constraint(equalToConstant: 33).isActive = true
    }
}
