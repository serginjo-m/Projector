 //
//  StepAddItemCell.swift
//  Projector
//
//  Created by Serginjo Melnik on 07.05.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
 
 //created for learning purposes, not by really necessarity
 extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated(){
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints  = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
 }

class StepAddItemCell: UICollectionViewCell{
    //when cell is tapped change its value true & relesed to false
    override var isHighlighted: Bool{
        didSet{
            //condition
            backgroundColor = isHighlighted ? UIColor(white: 0.90, alpha: 1) : UIColor(white: 1, alpha: 1)
        }
    }
    
    //every time value is changed by collection view this var change name and image!! 
    var setting: Setting? {
        didSet{
            //because setting?.name was set by collectionView
            nameLabel.text = setting?.name
            
            if let imageName = setting?.imageName{
                iconImageView.image = UIImage(named: imageName)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //layer.cornerRadius = 3
        //layer.masksToBounds = true
        
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "Description Note"
        return label
    }()
    let iconImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "descriptionNote")
        image.contentMode = .left
        
        return image
    }()
    
    func setupViews(){
        
//        backgroundColor = UIColor(white: 0, alpha: 0.1)
        
        addSubview(nameLabel)
        addSubview(iconImageView)
        //using extension custom function for constraints allows set up more easily
        //v1 -  is dynamically sized & have a rest of the space
        addConstraintsWithFormat(format: "H:|-16-[v0(21)]-15-[v1]|", views:iconImageView, nameLabel)
        
        addConstraintsWithFormat(format: "V:|[v0]|", views: nameLabel)
        //v0(30) - establish height of view
        //--- strangely creates an issue
        //addConstraintsWithFormat(format: "V:|[v0(14)]|", views: iconImageView)
        
        //icon center align inside cell
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal , toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
    }
 }
