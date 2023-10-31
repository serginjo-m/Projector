//
//  EventTableViewCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    //margin calculation element
    var prevCellDate: Date?
    //CalendarViewConroller -> EventElementsView -> EventTableViewCell -> performZoomForStartingEventView()
    var calendarVC: CalendarViewController?
    
    var events: [Event] = [] {
        didSet{
            //clear cell (dequeue)
            subviews.forEach { $0.removeFromSuperview() }
            
            if events.count > 0{
                //creates views based on events number
                for number in 1...events.count{
                    //configure event view and give it a sequent number
                    configureBubbleViews(number: number)
                }
            }
        }
    }
    
    //MARK: Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func configureBubbleViews(number: Int){
        
        var bubbleStyle: EventBubbleStyle = EventBubbleStyle.fullSize
        
        var currentEventInterval = TimeInterval()
        var totalCellTimeInterval = TimeInterval()
        var topEndTimeInterval = TimeInterval()
        if let lastEvent = events.last,
            let lastEndTime = lastEvent.endTime,
            let prevDate = prevCellDate,
            let intervalForCurrentEvent = events[number - 1].eventTimeInterval,
            let currentEventStartDate = events[number - 1].date
        {
            totalCellTimeInterval = lastEndTime.timeIntervalSince(prevDate)
            currentEventInterval = intervalForCurrentEvent
            topEndTimeInterval = currentEventStartDate.timeIntervalSince(prevDate)
        }
        
        let heightPercentage = currentEventInterval / totalCellTimeInterval
        let viewHeight: CGFloat = frame.height * heightPercentage
        let topEndPaddingPercentage = topEndTimeInterval / totalCellTimeInterval
        let viewTopPadding = frame.height * topEndPaddingPercentage
        let constant = (frame.width / CGFloat(events.count)) * CGFloat(number - 1)
        let viewWidth = frame.width / CGFloat(events.count)
        
        if viewHeight <= 30{
            bubbleStyle = .small
        }
        // .short
        if  viewHeight <= 180 && viewHeight >= 30 {
            bubbleStyle = .short
        }
        // .thin
        if events.count > 2 && viewHeight >= 180{
            bubbleStyle = .thin
        }
        // .halfWidth
        if events.count == 2 && viewHeight >= 180{
            bubbleStyle = .halfWidth
        }
                
        let eventBubbleView = EventBubbleView(style: bubbleStyle ,event: events[number - 1], viewHeight: viewHeight, viewWidth: viewWidth, frame: CGRect.zero)
        
        eventBubbleView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoomIn))
        eventBubbleView.addGestureRecognizer(tap)
        eventBubbleView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(eventBubbleView)
        
        eventBubbleView.widthAnchor.constraint(equalToConstant: viewWidth).isActive = true
        eventBubbleView.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
        eventBubbleView.topAnchor.constraint(equalTo: topAnchor, constant: viewTopPadding).isActive = true
        eventBubbleView.leftAnchor.constraint(equalTo: leftAnchor, constant:  constant).isActive = true
    }
    @objc func zoomIn(tapGesture: UITapGestureRecognizer){
        let bubbleView = tapGesture.view as? EventBubbleView
        guard let bubble = bubbleView, let calendarViewController = calendarVC else {return}
        calendarViewController.performZoomForStartingEventView(event: bubble.event ,startingEventView: bubble)
    }
}
