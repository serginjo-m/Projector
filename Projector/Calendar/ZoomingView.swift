//
//  ZoomingView.swift
//  Projector
//
//  Created by Serginjo Melnik on 21/07/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import Foundation
import UIKit

class ZoomingView: UIView {

    var event: Event
    
    var dismissView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "closeButton"))
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isUserInteractionEnabled = true
        image.alpha = 0
        return image
    }()
    
    lazy var removeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.setImage(UIImage(named: "binIcon"), for: .normal)
        button.backgroundColor = UIColor.init(displayP3Red: 255/255, green: 224/255, blue: 224/255, alpha: 1)
        button.alpha = 0
        return button
    }()
    
    lazy var editButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 6
        button.setImage(UIImage(named: "editIcon"), for: .normal)
        button.backgroundColor = UIColor.init(displayP3Red: 198/255, green: 250/255, blue: 211/255, alpha: 1)
        button.alpha = 0
        return button
    }()
    
    lazy var title: UILabel = {
        let label = UILabel()
        label.text = event.title
        label.textColor = event.category == "projectStep" ? .white : .black
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    lazy var clockImageView: UIImageView = {
        let originalImage = UIImage(named: "clock-1")
        let tintedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        let image = UIImageView(image: tintedImage)
        image.tintColor = event.category == "projectStep" ? .white : UIColor.init(white: 0.3, alpha: 1)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.alpha = 0
        return image
    }()
    
    lazy var eventTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = event.category == "projectStep" ? .white : .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let startTimeString = dateFormatter.string(from: event.date ?? Date())
        let endTimeString = dateFormatter.string(from: event.endTime ?? Date())
        label.text = "\(startTimeString) - \(endTimeString)"
        return label
    }()
    
    var thinUnderline: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 175/255, alpha: 1)
        view.alpha = 0
        return view
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        if let descriptionText = event.descr{
            label.text = descriptionText
        }
        label.textColor = event.category == "projectStep" ? .white : .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var eventLink: UILabel = {
        let label = UILabel()
        label.text = self.event.category == "projectStep" ? "Go To Project Step >>" : "Calendar Event"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .systemPurple
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.alpha = 0
        return label
    }()
    
    var linkUnderline: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemPurple
        view.alpha = 0
        return view
    }()
    
    lazy var eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        if let pictureURL =  event.picture  {
            imageView.retreaveImageUsingURLString(myUrl: pictureURL)
        }else{
            imageView.image = UIImage(named: "scheduledStepEvent")
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = event.category == "projectStep" ? false : true
        return imageView
    }()
    
    lazy var darkView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 32/255, alpha: 1)
        view.isHidden = event.category == "projectStep" ? false : true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //zoomOut configurations
    var titleTopAnchor: NSLayoutConstraint!
    var titleLeadingAnchor: NSLayoutConstraint!
    var titleHeightAnchor: NSLayoutConstraint!
    var titleTrailingAnchor: NSLayoutConstraint!
    var eventTimeLeadingAnchor: NSLayoutConstraint!
    var eventTimeTopAnchor: NSLayoutConstraint!
    var eventTimeHeightAnchor: NSLayoutConstraint!
    var descriptionLabelTopAnchor: NSLayoutConstraint!
    var descriptionLabelHeightAnchor: NSLayoutConstraint!
    var dismissButtonRightPadding: NSLayoutConstraint!
    var darkViewHeightAnchor: NSLayoutConstraint!
    
    init(event: Event, frame: CGRect) {
        self.event = event
        super.init(frame: frame)
        
        configureViewDisplay()
        
    }
    
    func configureViewDisplay(){
        
        self.clipsToBounds = true
        self.backgroundColor = event.category == "projectStep" ? UIColor.init(white: 32/255, alpha: 1) : UIColor.init(white: 241/255, alpha: 1)
        self.layer.cornerRadius = 11

        addSubview(eventImageView)
        addSubview(darkView)
        addSubview(dismissView)
        addSubview(removeButton)
        addSubview(editButton)
        addSubview(title)
        addSubview(clockImageView)
        addSubview(eventTimeLabel)
        addSubview(thinUnderline)
        addSubview(descriptionLabel)
        addSubview(eventLink)
        addSubview(linkUnderline)
        
        removeButton.topAnchor.constraint(equalTo: topAnchor, constant: 22).isActive = true
        removeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22).isActive = true
        removeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        removeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        editButton.topAnchor.constraint(equalTo: topAnchor, constant: 22).isActive = true
        editButton.leadingAnchor.constraint(equalTo: removeButton.trailingAnchor, constant: 22).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        editButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        dismissView.topAnchor.constraint(equalTo: topAnchor, constant: 26).isActive = true
        dismissButtonRightPadding = dismissView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -26)// -26
        dismissButtonRightPadding.isActive = true
        dismissView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        dismissView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        
        let initialTitleTop: CGFloat = eventImageView.isHidden ? CGFloat(85) : CGFloat(180)
        
        titleTopAnchor = title.topAnchor.constraint(equalTo: topAnchor, constant: initialTitleTop)
        titleLeadingAnchor = title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        titleTrailingAnchor = title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22)
        titleHeightAnchor = title.heightAnchor.constraint(equalToConstant: 30)
        titleLeadingAnchor.isActive = true
        titleHeightAnchor.isActive = true
        titleTrailingAnchor.isActive = true
        titleTopAnchor.isActive = true

        clockImageView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 45).isActive = true
        clockImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22).isActive = true
        clockImageView.heightAnchor.constraint(equalToConstant: 13).isActive = true
        clockImageView.widthAnchor.constraint(equalToConstant: 13).isActive = true
        
        eventTimeTopAnchor = eventTimeLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 45)
        eventTimeLeadingAnchor = eventTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 43)
        eventTimeLeadingAnchor.isActive = true
        eventTimeTopAnchor.isActive = true
        eventTimeHeightAnchor = eventTimeLabel.heightAnchor.constraint(equalToConstant: 13)
        eventTimeHeightAnchor.isActive = true
        eventTimeLabel.trailingAnchor.constraint(equalTo: title.trailingAnchor).isActive = true
        
        thinUnderline.leadingAnchor.constraint(equalTo: title.leadingAnchor).isActive = true
        thinUnderline.heightAnchor.constraint(equalToConstant: 1).isActive = true
        thinUnderline.trailingAnchor.constraint(equalTo: title.trailingAnchor).isActive = true
        thinUnderline.topAnchor.constraint(equalTo: clockImageView.bottomAnchor, constant: 20).isActive = true
        //TODO: Height needs to be calculated dynamically
        //TODO: Can I use textField here?
        descriptionLabelTopAnchor = descriptionLabel.topAnchor.constraint(equalTo: eventTimeLabel.bottomAnchor, constant: 33)
        descriptionLabel.leadingAnchor.constraint(equalTo: title.leadingAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: title.trailingAnchor).isActive = true
        descriptionLabelHeightAnchor = descriptionLabel.heightAnchor.constraint(equalToConstant: 150)
        descriptionLabelTopAnchor.isActive = true
        descriptionLabelHeightAnchor.isActive = true
        
        eventLink.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35).isActive = true
        eventLink.leadingAnchor.constraint(equalTo: title.leadingAnchor).isActive = true
        eventLink.trailingAnchor.constraint(equalTo: title.trailingAnchor).isActive = true
        eventLink.heightAnchor.constraint(equalToConstant: 17).isActive = true
        
        linkUnderline.leadingAnchor.constraint(equalTo: eventLink.leadingAnchor).isActive = true
        linkUnderline.heightAnchor.constraint(equalToConstant: 5).isActive = true
        linkUnderline.trailingAnchor.constraint(equalTo: eventLink.trailingAnchor).isActive = true
        linkUnderline.topAnchor.constraint(equalTo: eventLink.bottomAnchor, constant: 5).isActive = true
        
        eventImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        eventImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        eventImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        eventImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        darkView.topAnchor.constraint(equalTo: title.topAnchor, constant: -30).isActive = true
        darkViewHeightAnchor = darkView.heightAnchor.constraint(equalTo: title.heightAnchor, constant: 400)
        darkView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        darkView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        darkViewHeightAnchor.isActive = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
