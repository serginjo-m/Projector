//
//  SampleCVController.swift
//  Projector
//
//  Created by Serginjo Melnik on 20.05.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

protocol BaseCollectionViewDelegate {
    //update after delete
    func updateDatabase()
    // zooming in & zooming out
    func performZoomInForStartingImageView(startingImageView: UIImageView)
}


//Base for collection View controller
class BaseCollectionViewController<T: BaseCollectionViewCell<U>, U >: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, BaseCollectionViewDelegate{
    
    func performZoomInForStartingImageView(startingImageView: UIImageView) {
        print("basic zoom in...")
    }
    
    
    // (override in child vc) handle update from cell
    func updateDatabase() {
        print("database was updated!")
    }
    
    let cellId = "cellId"
    
    //data base
    var items = [U]()
    
    //navigation
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
        
        //because every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this instance
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
        itemsCollectionView.register(T.self, forCellWithReuseIdentifier: cellId)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": itemsCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": itemsCollectionView]))
        
        return stack
    }()

    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(collectionStackView)
        view.addSubview(dismissButton)
        view.addSubview(viewControllerTitle)
        
         setupConstraints()
        
        //---------------------------- why here?? --------------------------------
        if let layout = itemsCollectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self as? PinterestLayoutDelegate
        }
    }
    
    //back to previous view
    @objc func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //Collection View 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BaseCollectionViewCell<U>
        cell.delegate = self
        cell.item = items[indexPath.row]
        
        return cell
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

class BaseCollectionViewCell<U>: UICollectionViewCell {
    
    var delegate: BaseCollectionViewDelegate?
    
    var item: U!
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        backgroundColor = .clear
    }
    
}
