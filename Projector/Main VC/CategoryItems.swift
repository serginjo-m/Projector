//
//  CategoryItems.swift
//  Projector
//
//  Created by Serginjo Melnik on 26.04.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryItems: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //identifier for collection view
    var cellId = "cellID"
    
    //data source for collection view
    var cameraNotes: Results<CameraNote> {
        get{
            return ProjectListRepository.instance.getCameraNotes()
        }
    }
    
    //---------------------- realy don't want to have it separated! ------------------------
    var imagesArray: [UIImage] = []
    
    let dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBackgroundImage(UIImage(named: "backButton"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        
        return button
    }()
    
    let viewControllerTitle: UILabel = {
        let label = UILabel()
        label.text = "Camera Notes"
        label.textColor = UIColor.init(white: 0.7, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
    
    
    //here creates a horizontal collectionView
    let itemsCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = PinterestLayout()
        
        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this instance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clear
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    lazy var collectionStackView: UIStackView = {
        
        let stack = UIStackView()
        
        stack.addSubview(itemsCollectionView)
        
        //specify delegate & datasourse for generating our individual horizontal cells
        itemsCollectionView.dataSource = self
        itemsCollectionView.delegate = self
        
        itemsCollectionView.showsHorizontalScrollIndicator = false
        itemsCollectionView.showsVerticalScrollIndicator = false
        
        
        //Class is need to be registered in order of using inside
        itemsCollectionView.register(CategoryItemsCell.self, forCellWithReuseIdentifier: cellId)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": itemsCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": itemsCollectionView]))
        
        return stack
    }()
 
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        view.addSubview(collectionStackView)
        view.addSubview(dismissButton)
        view.addSubview(viewControllerTitle)
    
        setupConstraints()
        //from url arr to images arr
        defineImages()
        
        //---------------------------- why here?? --------------------------------
        if let layout = itemsCollectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
 
    //from url arr to images arr
    func defineImages(){
        if cameraNotes.count > 0 {
            for note in cameraNotes {
                let image = retreaveImageForProject(myUrl: note.picture)
                imagesArray.append(image)
            }
        }
    }
    
    //return UIImage by URL
    func retreaveImageForProject(myUrl: String) -> UIImage{
        var projectImage: UIImage = UIImage(named: "defaultImage")!
        let url = URL(string: myUrl)
        let data = try? Data(contentsOf: url!)
        if let imageData = data{
            projectImage = UIImage(data: imageData)!
        }
        return projectImage
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cameraNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CategoryItemsCell
        
        //data object
        cell.template = cameraNotes[indexPath.row]
        //delete
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
        //image
        cell.image.image = imagesArray[indexPath.row]
        
        cell.categoryItemsController = self
        
        return cell
    }
    
    //remove item
    @objc func deleteAction (_ sender: UIButton){
        ProjectListRepository.instance.deleteCameraNote(note: cameraNotes[sender.tag])
        itemsCollectionView.reloadData()
    }
    
    //custom zoom in logic
    func performZoomInForStartingImageView(startingImageView: UIImageView){
        
        let startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = .red
        zoomingImageView.image = startingImageView.image!
        
        if let keyWindow = UIApplication.shared.keyWindow{
            keyWindow.addSubview(zoomingImageView)
            
            //math?
            //h2 / w2 = h1 / w1
            //h2 = h1 / w1 * w2
            
            
            let height = startingFrame!.height / startingFrame!.width * keyWindow.frame.width
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
            
            
        }
    }
    
    func setupConstraints(){
        
        [collectionStackView, dismissButton, viewControllerTitle].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        viewControllerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        viewControllerTitle.centerYAnchor.constraint(equalTo: dismissButton.centerYAnchor, constant: 0).isActive = true
        viewControllerTitle.widthAnchor.constraint(equalToConstant: 120).isActive = true
        viewControllerTitle.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        collectionStackView.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 20).isActive = true
        collectionStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        collectionStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 7).isActive = true
        collectionStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -7).isActive = true
        
    }
}

class CategoryItemsCell: UICollectionViewCell {
    
    var categoryItemsController: CategoryItems?
    
    //It'll be like a template for our cell
    var template: CameraNote? {
        //didSet uses for logic purposes!
        didSet{
            
            if let title = template?.title {
                titleLabel.text = title
            }else{
                titleLabel.text = ""
            }
            
        }
    }
    
    lazy var image: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "river")
        image.contentMode = .scaleAspectFit
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
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"projectRemoveButton"), for: .normal)
        return button
    }()
    
    //call to zoom in logic
    @objc func handleZoomTap(sender: UITapGestureRecognizer){
        if let imageView = sender.view as? UIImageView{
            //parent func that run all logic
            self.categoryItemsController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    
    //initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        
        layer.masksToBounds = true
        layer.cornerRadius = 5
        backgroundColor = .yellow
        
        addSubview(image)
        addSubview(titleLabel)
        addSubview(deleteButton)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        image.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        image.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 9).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -9).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        deleteButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 11).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -11).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
}


// Pinterest Layout Configurations
extension CategoryItems: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return imagesArray[indexPath.item].size.height
    }
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return imagesArray[indexPath.item].size.width
    }
}
