//
//  StepAddItem.swift
//  Projector
//
//  Created by Serginjo Melnik on 06.05.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class Setting: NSObject{
    let name: String
    let imageName: String
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}

class StepAddItem: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    //transparent background
    let blackView = UIView()
    
    //collection view
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()//BEWARE!!!! UICollectionViewLayout != UICollectionViewFlowLayout
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(white: 1, alpha: 1)
        return cv
    }()
    
    let cellId = "cellId "
    
    var parentViewController: StepViewController?
    
    //datasource for menu
    let settings: [Setting] = {
        return [Setting(name: "Description Note", imageName: "descriptionNote"),
                Setting(name: "Shopping List", imageName: "shoppingList"),
                Setting(name: "Close", imageName: "closeIcon3")]
    }()
    
    //Add new item to the step
    @objc func showMenu(){
        //becouse I can't add blackView to view, created instance of window
        if let window = UIApplication.shared.keyWindow{
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            window.addSubview(blackView)
            window.addSubview(collectionView)
            
            let width: CGFloat = 220
            let x = window.frame.width - width
            collectionView.frame = CGRect(x: window.frame.width, y: 0, width: width, height: window.frame.height)
            blackView.frame = window.frame
            
            //animation configuration
            blackView.alpha = 0
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss(_:))))
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 3.0, options: UIView.AnimationOptions.curveEaseInOut, animations: ({
                self.blackView.alpha = 1
                
                self.collectionView.frame = CGRect(x: x, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }), completion: nil)
        }
    }
    
    @objc func handleDismiss(_ sender: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
           if let window = UIApplication.shared.keyWindow{
                self.collectionView.frame = CGRect(x: window.frame.width, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        }
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    //number
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StepAddItemCell
        
        let setting = settings[indexPath.row]
        cell.setting = setting
        return cell
    }
    //removes spacing betwen cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 3.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow{
                self.collectionView.frame = CGRect(x: window.frame.width, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }
        }) { (completed: Bool) in
            //corresponds to the values of selected cell ( name, iconName)
            let setting = self.settings[indexPath.item] //------------ realy like it! -----------------
            //shows view controller
            if setting.name != "Close"{
                
                self.parentViewController?.showControllerForSetting(setting: setting)
            }
        }
    }
    override init() {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        //it is a little bit different, becouse cell is in another file
        collectionView.register(StepAddItemCell.self, forCellWithReuseIdentifier: cellId)

    }
}
