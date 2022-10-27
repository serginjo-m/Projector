//
//  CanvasImageView.swift
//  Projector
//
//  Created by Serginjo Melnik on 27/10/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit

class CanvasImageView: UIView {
    
    lazy var canvas: DrawCanvasView = {
        let canvas = DrawCanvasView()
        canvas.backgroundColor = .white
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.isHidden = true//----------------------------- attention here! --------------------------------
        canvas.isUserInteractionEnabled = true
        return canvas
    }()
    
    lazy var photoView: UIImageView = {
        let photo = UIImageView()
        photo.translatesAutoresizingMaskIntoConstraints = false
        photo.contentMode = .scaleAspectFill
        photo.isUserInteractionEnabled = true
        return photo
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoView)
        addSubview(canvas)
        
        canvas.topAnchor.constraint(equalTo: topAnchor).isActive = true
        canvas.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        canvas.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        canvas.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        photoView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        photoView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        photoView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        photoView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
