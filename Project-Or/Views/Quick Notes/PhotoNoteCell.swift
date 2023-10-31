//
//  PhotoNoteCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 29/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class PhotoNoteCell: BaseCollectionViewCell<CameraNote> {
    //MARK: Properties
    override var item: CameraNote! {
        didSet{
            titleLabel.text = item.title != "" ? item.title : ""
            image.retreaveImageUsingURLString(myUrl: item.picture)
        }
    }
    
    lazy var image: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "scheduledStepEvent")
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textColor = UIColor.white
        return label
    }()
    
    //MARK: initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: Methods
    func setupViews(){
        layer.masksToBounds = true
        layer.cornerRadius = 5
        
        addSubview(image)
        addSubview(titleLabel)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        image.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        image.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 9).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -9).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    @objc func handleZoomTap(sender: UITapGestureRecognizer){
        guard let delegate = self.delegate else {return}
        if let imageView = sender.view as? UIImageView{
    
            delegate.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
}

