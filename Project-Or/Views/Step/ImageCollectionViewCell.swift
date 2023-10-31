//
//  ImageCollectionViewCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var template: NewStepImageCellTemplate? {
        didSet{
            guard let unwrappedTemplate = template else {return}
            if unwrappedTemplate.tag == 0{
                photoView.image = UIImage(named: "plusIconV2")
                deleteButton.isHidden = true
            }else{
                if let url = unwrappedTemplate.imageURL{
                    photoView.retreaveImageUsingURLString(myUrl: url)
                    deleteButton.isHidden = false
                }else if let canvasObject = unwrappedTemplate.canvas{
                    self.canvas.canvasObject = canvasObject
                    self.canvas.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
                    self.canvas.isHidden = false
                    deleteButton.isHidden = false
                }else{
                    photoView.image = UIImage(named: "border")
                    deleteButton.isHidden = true
                }
            }
        }
    }
    
    //MARK: initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.init(displayP3Red: 63/255, green: 63/255, blue: 63/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.setImage(UIImage(named: "whiteClose"), for: .normal)
        button.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.isHidden = true
        return button
    }()
    
    let photoView: UIImageView = {
        let photo = UIImageView()
        photo.image = UIImage(named: "border")
        photo.contentMode = .scaleAspectFill
        photo.clipsToBounds = true
        photo.isUserInteractionEnabled = true
        photo.layer.cornerRadius = 6
        return photo
    }()
    
    lazy var canvas: DrawCanvasView = {
        let canvas = DrawCanvasView()
        canvas.backgroundColor = .clear
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.isUserInteractionEnabled = true
        canvas.isHidden = true
        canvas.layer.cornerRadius = 6
        canvas.layer.masksToBounds = true
        return canvas
    }()
    
    func setupViews(){
        
        addSubview(photoView)
        addSubview(canvas)
        
        addSubview(deleteButton)
        
        photoView.frame = CGRect(x: 0, y: 0, width: 59, height: 59)
        deleteButton.frame = CGRect(x: 43, y: -6, width: 22, height: 22)
        
        canvas.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        canvas.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 15).isActive = true
        canvas.widthAnchor.constraint(equalToConstant: 236).isActive = true//59
        canvas.heightAnchor.constraint(equalToConstant: 512).isActive = true//128
    }
}
