//
//  EventTableViewCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 22/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    //margin calculation should start from here
    var prevCellDate: Date?
    //CalendarViewConroller -> EventElementsView -> EventTableViewCell -> performZoomForStartingEventView()
    var calendarVC: CalendarViewController?
    
    var events: [Event] = [] {
        didSet{
            //clear cell for case deque cell reuse something
            subviews.forEach { $0.removeFromSuperview() }

            //prevent error
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
        //------------- new approach here: first declare var and then unwrap it for value. Something?
        
        //current event interval, that should be unwraped, because it optional, but it calculates inside Event
        var currentEventInterval = TimeInterval()
        //total TimeInterval for each cell is the same. So every event must calculate padding and size from it...
        var totalCellTimeInterval = TimeInterval()
        //TimeInterval from prev cell to current event
        var topEndTimeInterval = TimeInterval()
        //unwrap optionals
        if let lastEvent = events.last,
            let lastEndTime = lastEvent.endTime,
            let prevDate = prevCellDate,
            let intervalForCurrentEvent = events[number - 1].eventTimeInterval,
            let currentEventStartDate = events[number - 1].date
        {
            //TimeInterval for entire cell
            totalCellTimeInterval = lastEndTime.timeIntervalSince(prevDate)
            //unwrap optional Event TimeInterval for future calculations
            currentEventInterval = intervalForCurrentEvent
            //TimeInterval from last cell (Event) to current event
            topEndTimeInterval = currentEventStartDate.timeIntervalSince(prevDate)
        }
        
        //calculate eventBubbleView height percentage of entire cell height
        let heightPercentage = currentEventInterval / totalCellTimeInterval
        //calculate height value based on percentage
        let viewHeight: CGFloat = frame.height * heightPercentage
        //calculate distance percentage from last event to current event inside cell
        let topEndPaddingPercentage = topEndTimeInterval / totalCellTimeInterval
        //value  calculation based on percentage of entire cell height
        let viewTopPadding = frame.height * topEndPaddingPercentage
        //left padding calculation
        let constant = (frame.width / CGFloat(events.count)) * CGFloat(number - 1)
        //view width
        let viewWidth = frame.width / CGFloat(events.count)
        
        // .small
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
                
        //creates event view
        let eventBubbleView = EventBubbleView(style: bubbleStyle ,event: events[number - 1], viewHeight: viewHeight, viewWidth: viewWidth, frame: CGRect.zero)
        
        //add zoom in function to bubble view
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
    //-----------------------------from cell to view controller-------------------------------------------
    @objc func zoomIn(tapGesture: UITapGestureRecognizer){
        //Really good trick
        //Extract view object from tap gesture
        let bubbleView = tapGesture.view as? EventBubbleView
        guard let bubble = bubbleView, let calendarViewController = calendarVC else {return}
        calendarViewController.performZoomForStartingEventView(event: bubble.event ,startingEventView: bubble)
    }
}
