//
//  StringToImage.swift
//  Projector
//
//  Created by Serginjo Melnik on 08.11.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

//retreaveImageForProject && retreaveImageUsingURLString do the same thing
//but retreaveImageUsingURLString has cache that is better
class StringToImage {
    
    static let shared = StringToImage()
    
    //return UIImage by URL
    func retreaveImageForProject(myUrl: String) -> UIImage?{
        var projectImage: UIImage = UIImage(named: "defaultImage")!
        let url = URL(string: myUrl)
        let data = try? Data(contentsOf: url!)
        if let imageData = data{
            projectImage = UIImage(data: imageData)!
        }
        return projectImage
    }
}

