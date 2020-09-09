//
//  ChineeseClassCollectionViewController.swift
//  Projector
//
//  Created by Serginjo Melnik on 22.03.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//
/*
import UIKit


//UICollectionViewDelegateFlowLayout allows us to ovverride sizeForItemAt
class FeaturedAppsController: UICollectionViewController, UICollectionViewDelegateFlowLayout  {
    
    private let cellId = "cellId"
    
    //this is a way to power number of categories
    var appCategories: [AppCategory]?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this will be kind of data source of our collection view
        //this will assign an array to our var
        appCategories = AppCategory.sampleAppCategory()

        collectionView?.backgroundColor = UIColor.white
        
        //we need to register our CategoryCell class otherwise our app will crash
        collectionView?.register(CategoryCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    
    //here we define what is our horizontal black? cells
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CategoryCell
        //here we want to specify app category for the cell
        cell.appCategory = appCategories?[indexPath.item]
        return cell
    }
    
    
    //here we create 3 sections (top center and bottom)
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //since the number of .. is optional we need to safely unwrap our ...
        if let count = appCategories?.count{
            // so if something exist it will return from here
            return count
        }
        // else we return 0 
        return 0
    }
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
     
    }*/
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width , height: 150)
    }
    
}
*/
