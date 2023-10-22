//
//  EventBubbleView.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

//MARK:  Bubble
//Event view is so complicated, that it needs it own class
class EventBubbleView: UIView {
    //event object
    var event: Event
    //gives a style to based on size calculations
    var style: EventBubbleStyle
    //view constraints configurations immidiately require view sizes
    var rect: CGSize
    
    lazy var backgroundBubble: UIView = {
        let bg = UIView()
        bg.layer.cornerRadius = 11
        bg.translatesAutoresizingMaskIntoConstraints = false
        let bubbleGray = UIColor.init(white: 241/255, alpha: 1)
        let bubbleGreen = UIColor(red: 98/255, green: 197/255, blue: 84/255, alpha: 1)
        bg.backgroundColor = event.category == "holiday" ? bubbleGreen : bubbleGray
        bg.layer.masksToBounds = true
        return bg
    }()
    
    lazy var taskLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = event.picture != nil ? .white : .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = event.title
        label.numberOfLines = 0
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.isHidden = event.picture != nil ? true : false
        label.numberOfLines = 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let startTimeString = dateFormatter.string(from: event.date ?? Date())
        let endTimeString = dateFormatter.string(from: event.endTime ?? Date())
        label.text = "\(startTimeString) - \(endTimeString)"
        return label
    }()
   
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = event.descr
        label.isHidden = event.picture != nil ? true : false
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = event.picture != nil ? false : true
        return imageView
    }()
    lazy var gradientView: GradientView = {
        let topColor = UIColor.init(white: 32/255, alpha: 1)
        let middleColor = UIColor.init(white: 32/255, alpha: 1)
        let bottomColor = UIColor.init(white: 32/255, alpha: 1)
        let gradient = GradientView(gradientStartColor: topColor, gradientMiddleColor: middleColor, gradientEndColor: bottomColor)
        gradient.isHidden = event.picture != nil ? false : true
        gradient.translatesAutoresizingMaskIntoConstraints = false
        return gradient
    }()
    
    lazy var shadowLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = event.title
        label.numberOfLines = 0
//        label.backgroundColor = .systemGreen
        label.isHidden = event.picture != nil ? false : true
        return label
    }()
    
    //save configurations for expanded event view
    var taskLabelHeightConstant: CGFloat = 1
    var taskLabelTopAnchorConstant: CGFloat = 12
    var timeLabelHeightConstant: CGFloat = 30
    var descriptionLabelHeightConstant: CGFloat = 0
    
    //MARK: Initialization
    init(style: EventBubbleStyle, event: Event, viewHeight: CGFloat, viewWidth: CGFloat, frame: CGRect) {
        self.event = event
        self.style = style
        self.rect = CGSize(width: viewWidth, height: viewHeight)
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func calculateRectForLabel(size: CGFloat, text: String) -> CGRect{
        //description label height
        let rectangle = NSString(string: text).boundingRect(with: CGSize(width: rect.width - CGFloat(22), height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: size)], context: nil)

        //rounded away from zero original values
        let rect = CGRect(x: rectangle.origin.x, y: rectangle.origin.y, width: rectangle.width.rounded(.awayFromZero), height: rectangle.height.rounded(.awayFromZero))
        
        return rect
    }
    
    func setupView(){
        
        self.clipsToBounds = true
        
        switch style {
            
        //it so small, that can't realy visualize anything, apart from bubble view
        case .small:
            
            taskLabel.isHidden = true
            descriptionLabel.isHidden = true
            shadowLabel.isHidden = true
            timeLabel.isHidden = true
            //because if it visible it has 12px padding from top by default
            taskLabelTopAnchorConstant = 0
        //can show only title and bubble view
        case .short://events.count > 2 == .thin, viewHeight <= 60 == .short
            taskLabel.font = UIFont.boldSystemFont(ofSize: 14)
            shadowLabel.font = UIFont.boldSystemFont(ofSize: 14)

            let titleHeight = calculateRectForLabel(size: 14, text: taskLabel.text!).height
            taskLabelHeightConstant = titleHeight <= rect.height - 12 ? titleHeight : rect.height - 24
            descriptionLabel.isHidden = true
            timeLabel.isHidden = true
        //can include anything. The only one thing, fonts must be into small size
        case .thin://events.count > 2 == .thin, viewHeight <= 60 == .short
            
            taskLabel.font = UIFont.boldSystemFont(ofSize: 14)
            shadowLabel.font = UIFont.boldSystemFont(ofSize: 14)
            descriptionLabel.font = UIFont.systemFont(ofSize: 14)
            
            taskLabelHeightConstant = calculateRectForLabel(size: 14, text: taskLabel.text!).height + CGFloat(10)
            timeLabelHeightConstant = calculateRectForLabel(size: 14, text: timeLabel.text!).height + CGFloat(10)
            descriptionLabelHeightConstant = calculateRectForLabel(size: 14, text: descriptionLabel.text!).height
        //default style. Here I can show everything
        case .fullSize://by default it is .fullSize
            
            taskLabel.font = UIFont.boldSystemFont(ofSize: 16)
            shadowLabel.font = UIFont.boldSystemFont(ofSize: 16)
            descriptionLabel.font = UIFont.systemFont(ofSize: 16)
            taskLabelHeightConstant = calculateRectForLabel(size: 16, text: taskLabel.text!).height
            descriptionLabelHeightConstant = calculateRectForLabel(size: 16, text: descriptionLabel.text!).height
        //this style can visualize anything. But I should be accurate with view height
        case .halfWidth://by default it is .fullSize
            
            taskLabel.font = UIFont.boldSystemFont(ofSize: 16)
            shadowLabel.font = UIFont.boldSystemFont(ofSize: 16)
            descriptionLabel.font = UIFont.systemFont(ofSize: 16)
            taskLabelHeightConstant = calculateRectForLabel(size: 16, text: taskLabel.text!).height + CGFloat(10)
            let descriptionTextHeight: CGFloat = calculateRectForLabel(size: 16, text: descriptionLabel.text!).height
            let titleLabelTopAnchorSpace: CGFloat = -15
            let availableHeight: CGFloat = rect.height - taskLabelHeightConstant - timeLabelHeightConstant - titleLabelTopAnchorSpace
            descriptionLabelHeightConstant = descriptionTextHeight > availableHeight ? availableHeight : descriptionTextHeight
        }
                        
        addSubview(backgroundBubble)
        addSubview(shadowLabel)
        addSubview(taskLabel)
        addSubview(timeLabel)
        addSubview(descriptionLabel)

        backgroundBubble.addSubview(eventImageView)
        backgroundBubble.addSubview(gradientView)

        backgroundBubble.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        backgroundBubble.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        backgroundBubble.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6).isActive = true//-10
        backgroundBubble.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        taskLabel.topAnchor.constraint(equalTo: backgroundBubble.topAnchor, constant: taskLabelTopAnchorConstant).isActive = true
        taskLabel.leadingAnchor.constraint(equalTo: backgroundBubble.leadingAnchor, constant: 8).isActive = true
        taskLabel.heightAnchor.constraint(equalToConstant: taskLabelHeightConstant).isActive = true
        taskLabel.trailingAnchor.constraint(equalTo: backgroundBubble.trailingAnchor, constant: -8).isActive = true
        
        timeLabel.topAnchor.constraint(equalTo: taskLabel.bottomAnchor, constant: 0).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: backgroundBubble.leadingAnchor, constant: 8).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: backgroundBubble.trailingAnchor, constant: -8).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: timeLabelHeightConstant).isActive = true
        
        descriptionLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 0).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: taskLabel.leadingAnchor).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: descriptionLabelHeightConstant).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: taskLabel.trailingAnchor).isActive = true

        shadowLabel.topAnchor.constraint(equalTo: taskLabel.topAnchor, constant: 1).isActive = true
        shadowLabel.leadingAnchor.constraint(equalTo: taskLabel.leadingAnchor, constant: 1).isActive = true
        shadowLabel.heightAnchor.constraint(equalToConstant: taskLabelHeightConstant).isActive = true
        shadowLabel.trailingAnchor.constraint(equalTo: taskLabel.trailingAnchor, constant: 1).isActive = true
        
        gradientView.topAnchor.constraint(equalTo: taskLabel.topAnchor, constant: -30).isActive = true
        gradientView.leftAnchor.constraint(equalTo: backgroundBubble.leftAnchor, constant: 0).isActive = true
        gradientView.rightAnchor.constraint(equalTo: backgroundBubble.rightAnchor, constant: 0).isActive = true
        gradientView.heightAnchor.constraint(equalTo: taskLabel.heightAnchor, constant: 42).isActive = true
        
        
        eventImageView.topAnchor.constraint(equalTo: backgroundBubble.topAnchor, constant: 0).isActive = true
        eventImageView.leadingAnchor.constraint(equalTo: backgroundBubble.leadingAnchor, constant: 0).isActive = true
        eventImageView.trailingAnchor.constraint(equalTo: backgroundBubble.trailingAnchor, constant: 0).isActive = true
        eventImageView.bottomAnchor.constraint(equalTo: backgroundBubble.bottomAnchor).isActive = true
    }
}

//different event sizes need different display style
enum EventBubbleStyle {
    case halfWidth
    case fullSize
    case thin
    case short
    case small
}
