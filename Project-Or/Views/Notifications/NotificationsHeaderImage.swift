//
//  NotificationsHeaderImage.swift
//  Projector
//
//  Created by Serginjo Melnik on 10.08.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

class NotificationsHeaderImage: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let titleRoundedBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 11
        return view
    }()
    
    let headerTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "Notifications"
        label.textColor = UIColor.init(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
        return label
    }()
    
    let mailBoxImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "mailBox"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let mailBoxShadowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "postShadow"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let mailIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "mail"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let shoutIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "shout"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let bellIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "bellIcon"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let bigCircleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(red: 60/255, green: 36/255, blue: 75/255, alpha: 1)
        view.layer.cornerRadius = 6
        return view
    }()
    
    let mediumCircleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(red: 60/255, green: 36/255, blue: 75/255, alpha: 1)
        view.layer.cornerRadius = 5
        return view
    }()
    
    let smallCircleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(red: 60/255, green: 36/255, blue: 75/255, alpha: 1)
        view.layer.cornerRadius = 3
        return view
    }()
    
    func setupView(){
        layer.cornerRadius = 18
        backgroundColor = UIColor.init(red: 116/255, green: 71/255, blue: 145/255, alpha: 1)
        addSubview(mailBoxShadowImageView)
        addSubview(titleRoundedBackground)
        addSubview(mailBoxImageView)
        addSubview(mailIconImageView)
        addSubview(shoutIconImageView)
        addSubview(bellIconImageView)
        addSubview(bigCircleView)
        addSubview(mediumCircleView)
        addSubview(smallCircleView)
        addSubview(headerTitle)
        
        titleRoundedBackground.topAnchor.constraint(equalTo: topAnchor, constant: 128).isActive = true
        titleRoundedBackground.leftAnchor.constraint(equalTo: leftAnchor, constant: 17).isActive = true
        titleRoundedBackground.rightAnchor.constraint(equalTo: rightAnchor, constant: -17).isActive = true
        titleRoundedBackground.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        mailBoxImageView.rightAnchor.constraint(equalTo: titleRoundedBackground.rightAnchor, constant: 0).isActive = true
        mailBoxImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        mailBoxImageView.widthAnchor.constraint(equalToConstant: 111).isActive = true
        mailBoxImageView.heightAnchor.constraint(equalToConstant: 183).isActive = true
        
        mailBoxShadowImageView.leftAnchor.constraint(equalTo: mailBoxImageView.leftAnchor, constant: -14).isActive = true
        mailBoxShadowImageView.topAnchor.constraint(equalTo: mailBoxImageView.topAnchor, constant: 12).isActive = true
        mailBoxShadowImageView.widthAnchor.constraint(equalToConstant: 62).isActive = true
        mailBoxShadowImageView.heightAnchor.constraint(equalToConstant: 135).isActive = true
        
        mailIconImageView.rightAnchor.constraint(equalTo: mailBoxImageView.leftAnchor, constant: -32).isActive = true
        mailIconImageView.bottomAnchor.constraint(equalTo: titleRoundedBackground.topAnchor, constant: -14).isActive = true
        mailIconImageView.widthAnchor.constraint(equalToConstant: 27).isActive = true
        mailIconImageView.heightAnchor.constraint(equalToConstant: 23).isActive = true
        
        shoutIconImageView.rightAnchor.constraint(equalTo: mailIconImageView.leftAnchor, constant: -25).isActive = true
        shoutIconImageView.bottomAnchor.constraint(equalTo: titleRoundedBackground.topAnchor, constant: -42).isActive = true
        shoutIconImageView.widthAnchor.constraint(equalToConstant: 38).isActive = true
        shoutIconImageView.heightAnchor.constraint(equalToConstant: 41).isActive = true
        
        bellIconImageView.rightAnchor.constraint(equalTo: shoutIconImageView.leftAnchor, constant: -32).isActive = true
        bellIconImageView.bottomAnchor.constraint(equalTo: titleRoundedBackground.topAnchor, constant: -33).isActive = true
        bellIconImageView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        bellIconImageView.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        bigCircleView.rightAnchor.constraint(equalTo: mailIconImageView.rightAnchor, constant: -10).isActive = true
        bigCircleView.bottomAnchor.constraint(equalTo: mailIconImageView.topAnchor, constant: -29).isActive = true
        bigCircleView.widthAnchor.constraint(equalToConstant: 12).isActive = true
        bigCircleView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        mediumCircleView.rightAnchor.constraint(equalTo: shoutIconImageView.leftAnchor, constant: 2).isActive = true
        mediumCircleView.bottomAnchor.constraint(equalTo: mailIconImageView.bottomAnchor, constant: -13).isActive = true
        mediumCircleView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        mediumCircleView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        smallCircleView.rightAnchor.constraint(equalTo: bellIconImageView.leftAnchor, constant: -15).isActive = true
        smallCircleView.topAnchor.constraint(equalTo: bellIconImageView.bottomAnchor, constant: 8).isActive = true
        smallCircleView.widthAnchor.constraint(equalToConstant: 6).isActive = true
        smallCircleView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        
        headerTitle.topAnchor.constraint(equalTo: titleRoundedBackground.topAnchor, constant: 0).isActive = true
        headerTitle.leftAnchor.constraint(equalTo: titleRoundedBackground.leftAnchor, constant: 19).isActive = true
        headerTitle.rightAnchor.constraint(equalTo: titleRoundedBackground.rightAnchor, constant: 0).isActive = true
        headerTitle.bottomAnchor.constraint(equalTo: titleRoundedBackground.bottomAnchor, constant: 0).isActive = true
    }
}
