//
//  NoProjectsBannerView.swift
//  Projector
//
//  Created by Serginjo Melnik on 16/10/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import UIKit

class NoProjectsImageView: UIView {
    
    let bannerTitleWords = ["Start", "Your", "First", "Project"]
   
    let firstView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(displayP3Red: 18/255, green: 14/255, blue: 32/255, alpha: 1)
        return view
    }()
    
    let secondView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(displayP3Red: 39/255, green: 15/255, blue: 36/255, alpha: 1)
        return view
    }()
    
    let thirdView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(displayP3Red: 79/255, green: 28/255, blue: 50/255, alpha: 1)
        return view
    }()
    
    let fourthView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(displayP3Red: 124/255, green: 29/255, blue: 47/255, alpha: 1)
        return view
    }()
    
    let fifthView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(displayP3Red: 161/255, green: 2/255, blue: 18/255, alpha: 1)
        return view
    }()
    
    let sixthView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(displayP3Red: 255/255, green: 51/255, blue: 51/255, alpha: 1)
        return view
    }()
    
    let imageView: UIImageView = {
        let imageV = UIImageView(image: UIImage(named: "brightRocket"))
        imageV.translatesAutoresizingMaskIntoConstraints = false
        return imageV
    }()
    
    lazy var bannerTitleStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        stack.axis = .vertical
        return stack
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        
        configureView()
        
        for word in bannerTitleWords {
            let title = UILabel()
            title.textColor = .white
            title.font = UIFont.boldSystemFont(ofSize: 48)
            title.text = word
            title.textAlignment = .left
            bannerTitleStack.addArrangedSubview(title)
        }
        
    }
    
    fileprivate func configureView(){
        addSubview(firstView)
        addSubview(secondView)
        addSubview(thirdView)
        addSubview(fourthView)
        addSubview(fifthView)
        addSubview(sixthView)
        addSubview(imageView)
        addSubview(bannerTitleStack)
        
        firstView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        firstView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        firstView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        firstView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.38).isActive = true
        
        secondView.bottomAnchor.constraint(equalTo: firstView.topAnchor).isActive = true
        secondView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        secondView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        secondView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.29).isActive = true
        
        thirdView.bottomAnchor.constraint(equalTo: secondView.topAnchor).isActive = true
        thirdView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        thirdView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        thirdView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.175).isActive = true
        
        fourthView.bottomAnchor.constraint(equalTo: thirdView.topAnchor).isActive = true
        fourthView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        fourthView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        fourthView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.065).isActive = true
        
        fifthView.bottomAnchor.constraint(equalTo: fourthView.topAnchor).isActive = true
        fifthView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        fifthView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        fifthView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.045).isActive = true
        
        sixthView.bottomAnchor.constraint(equalTo: fifthView.topAnchor).isActive = true
        sixthView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        sixthView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        sixthView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.045).isActive = true
        
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 291).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        bannerTitleStack.topAnchor.constraint(equalTo: topAnchor, constant: 37).isActive = true
        bannerTitleStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 168).isActive = true
        bannerTitleStack.widthAnchor.constraint(equalToConstant: 163).isActive = true
        bannerTitleStack.heightAnchor.constraint(equalToConstant: 170).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
