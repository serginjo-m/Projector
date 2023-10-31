//
//  StringToImage.swift
//  Projector
//
//  Created by Serginjo Melnik on 08.11.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

class StringToImage {
    
    static let shared = StringToImage()

    func retreaveImageForProject(myUrl: String) -> UIImage?{
        var projectImage: UIImage = UIImage(named: "scheduledStepEvent")!
        let url = URL(string: myUrl)
        let data = try? Data(contentsOf: url!)
        if let imageData = data{
            projectImage = UIImage(data: imageData)!
        }
        return projectImage
    }
}

