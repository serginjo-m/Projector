//
//  UIImageView.swift
//  Projector
//
//  Created by Serginjo Melnik on 18.11.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import Foundation

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    
    //---------------------------- can I do it outside main queue asyncr? ----------------------------
    //---------------------------------------- thumbnails --------------------------------------------
    //---------------------------------------- clear cache? ------------------------------------------
    //------------------------------------------------------------------------------------------------
    
    //return UIImage by URL
    func retreaveImageUsingURLString(myUrl: String){
        
        
        
        if let imageFromCache = imageCache.object(forKey: myUrl as AnyObject) as? UIImage{
            self.image = imageFromCache
            return
        }
        
        let url = URL(string: myUrl)
        let data = try? Data(contentsOf: url!)
        if let imageData = data{
            
            let imageToCache = UIImage(data: imageData)!
            
            imageCache.setObject(imageToCache, forKey: myUrl as AnyObject)
        
            self.image = imageToCache
            
        }
        
        
    }
    
    
}
