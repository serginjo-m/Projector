//
//  SampleCVController.swift
//  Projector
//
//  Created by Serginjo Melnik on 20.05.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

class BaaseCollectionViewController<T: BaseCollectionViewCell<U>, U >: UICollectionViewController{
    
    let cellId = "cellId"
    
    var items = [U]()
    
    override func viewDidLoad() {
        super .viewDidLoad()
        collectionView.backgroundColor = .white
        //refer to cell, that is need to be passed when initialize class
        collectionView.register(T.self, forCellWithReuseIdentifier: cellId)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BaseCollectionViewCell<U>
        
        cell.item = items[indexPath.row]
        
        return cell
    }
}


struct Dog {
    let name: String
}

class DogCell: BaseCollectionViewCell<Dog> {
    override var item: Dog! {
        didSet{
            //textLabel.text = item.name
        }
    }
}

class StringCell: BaseCollectionViewCell<String> {
    override var item: String! {
        didSet{
            //textLabel?.text = "/(item)"
        }
    }
}

class DummyCollectionViewController: BaseCollectionViewController<StringCell, String>{
    
}

class SampleCollectionViewController: BaseCollectionViewController<DogCell, Dog> {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = [
            Dog(name: "Bill"),
            Dog(name: "Charley")
        ]
    }
}



class BaaseCollectionViewCell<U>: UICollectionViewCell {
    
    var item: U!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .yellow
    }
    
}
