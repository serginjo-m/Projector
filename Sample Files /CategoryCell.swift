//
//  CategoryCell.swift
//  Projector
//
//  Created by Serginjo Melnik on 23.03.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

/*
import UIKit
import Foundation

//UICollectionDelegateFlowLayout will give access to sizeForItem method that is change our cell
class CategoryCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var appCategory: AppCategory? {
        //we use didSet for a logic purposes
        didSet{
            //safely unwrapping name property of appCategory instance
            if let name = appCategory?.name{
                //assign name value to category label
                nameLabel.text = name
            }
        }
    }
    
    private let idCell = "appCellId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //that is a category title
    let nameLabel:UILabel = {
        let pn = UILabel()
        pn.text = "Travel to Europe on Motorcycle"
        pn.textAlignment = NSTextAlignment.center
        pn.font = UIFont.systemFont(ofSize: 16.0)
        pn.textColor = UIColor.white
        pn.numberOfLines = 3
        return pn
    }()
    
    //here creates a horizontal collectionView inside cell
    let appsCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        //because every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        collectionView.backgroundColor = UIColor.blue
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    func setupViews(){
        
        //changing color of our horizontal cell
        backgroundColor = UIColor.black
        
        //here we add our neewly created collectionView to our cell
        addSubview(appsCollectionView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        appsCollectionView.dataSource = self
        appsCollectionView.delegate = self
        
        //Class is need to be registered in order of using inside
        appsCollectionView.register(AppCell.self, forCellWithReuseIdentifier: idCell)
        
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[v0]-8-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": appsCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": appsCollectionView]))

    }
    
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //safely unwrap number of apps in array
        if let count = appCategory?.apps?.count{
            return count
        }
        return 0
    }
    
    //don't know what was an issue with index path, but it works right now!?
    //defining what actually our cell is
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //we do some "downcasting" when we use constant for cell????
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idCell, for: indexPath) as! AppCell
        
        //here we define ALL App Object values from our AppCategory.apps array that contains the same object
        cell.app = appCategory?.apps?[indexPath.item]
        return cell
        
    }
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //here we don't need to use view.frame.height because our CategoryCell have it
        return CGSize(width: 150, height: frame.height)
    }
}

class AppCell: UICollectionViewCell{
    
    // Think It's very clever !!!
    
    //an instance of our models App class
    var app: App? {
        //uses for a logic purposes
        didSet{
            if let name = app?.name{
                //here we assign a name value of our App Object to nameLabel
                nameLabel.text = name
            }
            
            categoryLabel.text = app?.category
            
            if let price = app?.price{
                //need to add $ sign to price value
                priceLabel.text = "$\(price)"
            }else{
                //for free apps
                priceLabel.text = ""
            }
            
            if let imageName = app?.imageName {
                imageView.image = UIImage(named: imageName)
            }
           
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 3
        layer.masksToBounds = true
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "Frozen")
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let nl = UILabel()
        nl.text = "Disney Build It: Frozen"
        nl.font = UIFont.systemFont(ofSize: 25.0)
        nl.textAlignment = NSTextAlignment.center
        nl.numberOfLines = 2
        return nl
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Enterteinment"
        label.font = UIFont.systemFont(ofSize: 35.0)
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.darkGray
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "$3.99"
        label.font = UIFont.systemFont(ofSize: 35.0)
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.darkGray
        return label
    }()
    
    func setupViews(){
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(categoryLabel)
        addSubview(priceLabel)
        
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 100)
        nameLabel.frame = CGRect(x: 0, y: frame.height, width: frame.width, height: 100)
        categoryLabel.frame = CGRect(x: 0, y: frame.height, width: frame.width, height: 100)
        priceLabel.frame = CGRect(x: 0, y: frame.height, width: frame.width, height: 100)
    }
}
*/
