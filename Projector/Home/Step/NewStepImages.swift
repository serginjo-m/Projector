//
//  NewStepImages.swift
//  Projector
//
//  Created by Serginjo Melnik on 02.05.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
//MARK: Protocols
protocol NewStepImagesDelegate: AnyObject{
    //opens parent VC image picker
    func showImagePicker()
}
//MARK: Structs
struct NewStepImageCellTemplate {
    var imageURL: String?
    var canvas: CanvasNote?
    var tag: Int
}

class NewStepImages: UIStackView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //MARK: Properties
    var delegate: NewStepImagesDelegate?
    //this property need for cells
    private let cellID = "cellId"
    //array contains default 'plus' image
    var photoArray = List<String>()
    var canvasArray = List<CanvasNote>()
    
    //here creates a horizontal collectionView inside stackView
    let imageCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        layout.sectionInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        //layout.itemSize = CGSize(width: 120, height: 45)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 28
        
        
        //because every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        collectionView.backgroundColor = UIColor.clear
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageCollectionView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupImageCollectionView()
    }
    
    //MARK: Methods
    func setupImageCollectionView(){
        // Add a collectionView to the stackView
        addArrangedSubview(imageCollectionView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        //hide scrollbar
        imageCollectionView.showsVerticalScrollIndicator = false
        imageCollectionView.showsHorizontalScrollIndicator = false
        
        //Class is need to be registered in order of using inside
        imageCollectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": imageCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": imageCollectionView]))
    }
    
    //remove image mechanism
    @objc func removeImage(button: UIButton){
        photoArray.remove(at: button.tag - 1)
        imageCollectionView.reloadData()
        
    }
    
    //MARK: Collection View
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //here we don't need to use view.frame.height because our CategoryCell have it
        return CGSize(width: 59, height: 59)
    }
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //default number
        var numberOfCells = 8
        //if all cells contain picture, adds more
        if photoArray.count > 8 {
            numberOfCells = photoArray.count
        }
        return numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            //only view controller can present image picker
            self.delegate?.showImagePicker()
        }
    }
    
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ImageCollectionViewCell
        
        //delete image button configuration
        cell.deleteButton.addTarget(self, action: #selector(removeImage(button:)), for: .touchUpInside)
        cell.deleteButton.tag = indexPath.row
        
        //struct
        var template = NewStepImageCellTemplate(imageURL: nil, canvas: nil, tag: indexPath.item)

        //not all 8 initial cells has an image
        if photoArray.count >= indexPath.item && indexPath.item != 0{
            template.imageURL = photoArray[indexPath.item - 1]
        }
        
        //not all 8 initial cells has an image
        if canvasArray.count >= indexPath.item && indexPath.item != 0{
            template.canvas = canvasArray[indexPath.item - 1]
        }
        
        cell.template = template
        
        return cell
    }
    
    
}
//MARK: Cell
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
        button.setBackgroundImage(UIImage(named: "cross"), for: .normal)
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
