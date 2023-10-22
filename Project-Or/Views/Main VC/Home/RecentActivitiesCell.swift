//
//  RecentActivitiesCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class RecentActivitiesCell: UICollectionViewCell {
   
    //initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        //layer.cornerRadius = 3
        //layer.masksToBounds = true
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //template
    var cellTemplate: DayActivity? {
        didSet{
            if let setting = cellTemplate{

                //if object exist, meens app was opened that day
                var str = "Look\n\n\n\n"
                
                for item in setting.userActivities{
                str += "\(item.descr)\n\n"
                }
                
                listLabel.text = str
            }
        }
    }
    
    let dayOfWeekLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(white: 1, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let listLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "This is Dummy text, that \n will be used for developing."
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let dayNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(white: 1, alpha: 0.28)
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupViews(){
        
        //mask content outside cell
        layer.masksToBounds = true
        
        addSubview(dayOfWeekLabel)
        addSubview(listLabel)
        addSubview(dayNumberLabel)
        
//        listLabel.topAnchor.constraint(equalTo: dayOfWeekLabel.bottomAnchor, constant: 10).isActive = true
//        listLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
//        listLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
//        listLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40).isActive = true
        
        listLabel.topAnchor.constraint(equalTo: dayOfWeekLabel.bottomAnchor, constant: 10).isActive = true
        listLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
        listLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        listLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.87).isActive = true
        
        dayOfWeekLabel.topAnchor.constraint(equalTo: topAnchor, constant: 13).isActive = true
        dayOfWeekLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        dayOfWeekLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        dayOfWeekLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        dayNumberLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        dayNumberLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: -10).isActive = true
        dayNumberLabel.widthAnchor.constraint(equalToConstant: 64).isActive = true
        dayNumberLabel.heightAnchor.constraint(equalToConstant: 38).isActive = true
    }
    
}
