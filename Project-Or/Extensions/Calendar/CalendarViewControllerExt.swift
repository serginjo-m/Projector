//
//  CalendarViewControllerExt.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 29/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit
//MARK: OK
extension CalendarViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let day = days[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CalendarCell
        cell.day = day
        return cell
    }
}

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = days[indexPath.row]
        selectedDateChanged(day.date)
        eventsArrayFromDateKey(date: day.date)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = Int(collectionView.frame.width / 7)
        
        return CGSize(width: width, height: 70)
    }
}

extension CalendarViewController {
    
    func monthMetadata(for baseDate: Date) throws -> MonthMetadata{
        guard
            let numberOfDaysInMonth = calendar.range(
                of: .day,
                in: .month,
                for: baseDate)?.count,
            let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate))
            
            else{
                throw CalendarDataError.metadataGeneration
        }
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        return MonthMetadata(
            numberOfDays: numberOfDaysInMonth,
            firstDay: firstDayOfMonth,
            firstDayWeekday: firstDayWeekday)
        
    }
    
    func generateDaysInMonth (for baseDate: Date) -> [Day] {
        
        guard let metadata = try? monthMetadata(for: baseDate) else {
            fatalError("An error occurred when generating the metadata for \(baseDate)")
        }
        
        let numberOfDaysInMonth = metadata.numberOfDays
        let offsetInInitialRow = metadata.firstDayWeekday
        let firstDayOfMonth = metadata.firstDay
        
        
        var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
            .map { day in
                let isWithinDisplayedMonth = day >= offsetInInitialRow
                let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)
                return generateDay(offsetBy: dayOffset, for: firstDayOfMonth, isWithinDisplayedMonth: isWithinDisplayedMonth)
        }
        
        days += generateStartOfNextMonth(using: firstDayOfMonth)
        
        return days
    }
    

    func generateDay( offsetBy dayOffset: Int, for baseDate: Date, isWithinDisplayedMonth: Bool) -> Day {
        
        let date = calendar.date( byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        var dateWithEvent = false
        var dateWithHoliday = false
        let calendar = Calendar(identifier: .gregorian)
        let ymd = calendar.dateComponents([.year, .month, .day], from: date)
        
        if let year = ymd.year, let month = ymd.month, let day = ymd.day{
            if year != downloadedHolidaysYear{
                let yearDifference =  downloadedHolidaysYear - year
                let dateComponents = DateComponents(year: year + yearDifference , month: month, day: day)
                let holidayDate = calendar.date(from: dateComponents)
                if let unwrappedHolidayDate = holidayDate{
                    groupedEventDictionary[unwrappedHolidayDate]?.forEach{
                        if $0.category == "holiday"{
                            dateWithHoliday = true
                        }
                    }
                }
            }
        }
        
        groupedEventDictionary[date]?.forEach{
            
            if $0.category == "holiday"{
                dateWithHoliday = true
            }else if $0.category != "holiday"{
                dateWithEvent = true
            }
        }
        return Day( date: date, number: self.dateFormatter.string(from: date), isSelected: calendar.isDate(date, inSameDayAs: selectedDate), isWithinDisplayedMonth: isWithinDisplayedMonth,  containEvent: dateWithEvent, containHoliday: dateWithHoliday)
    }
    
    func generateStartOfNextMonth(using firstDayOfDisplayedMonth: Date) -> [Day] {
        guard
            let lastDayInMonth = calendar.date(
                byAdding: DateComponents(month: 1, day: -1),
                to: firstDayOfDisplayedMonth)
            else {
                return []
        }
        
        let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
        guard additionalDays > 0 else {
            return []
        }
        let days: [Day] = (1...additionalDays).map { generateDay(offsetBy: $0, for: lastDayInMonth, isWithinDisplayedMonth: false)}
        
        return days
    }
    
    enum CalendarDataError: Error {
        case metadataGeneration
    }
    
    func performZoomForStartingEventView(event: Event, startingEventView: UIView){
        self.startingEventView = startingEventView
        self.startingEventView?.isHidden = true
        guard let unwEventBubbleView = startingEventView as? EventBubbleView,
              let unwStartingFrame = startingEventView.superview?.convert(startingEventView.frame, to: nil) else {return}
        let bubblePadding: CGFloat = 6
        let bubbleFrame = CGRect(x: unwStartingFrame.origin.x, y: unwStartingFrame.origin.y, width: unwStartingFrame.width - bubblePadding, height: unwStartingFrame.height)
        startingFrame = bubbleFrame
        let zoomingView = ZoomingView(event: event, frame: bubbleFrame)
        zoomingView.dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))
        zoomingView.removeButton.addTarget(self, action: #selector(removeEvent), for: .touchUpInside)
        zoomingView.editButton.addTarget( self, action: #selector(editEvent), for: .touchUpInside)
        zoomingView.eventLink.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(transitionToProjectStep)))
        zoomingView.descriptionLabel.font = unwEventBubbleView.descriptionLabel.font
        if let keyWindow = UIApplication.shared.keyWindow {
            self.zoomBackgroundView = UIView(frame: keyWindow.frame)
            zoomBackgroundView?.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
            zoomBackgroundView?.alpha = 0
            keyWindow.addSubview(zoomBackgroundView!)
            keyWindow.addSubview(zoomingView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
                zoomingView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width * 0.75, height: keyWindow.frame.height * 0.57)
                self.zoomBackgroundView?.alpha = 0.5
                zoomingView.titleLeadingAnchor.constant = 22
                zoomingView.dismissView.alpha = 1
                zoomingView.removeButton.alpha = 1
                zoomingView.editButton.alpha = 1
                zoomingView.clockImageView.alpha = 1
                zoomingView.thinUnderline.alpha = 1
                zoomingView.eventLink.alpha = 1
                zoomingView.linkUnderline.alpha = 1
                zoomingView.layoutIfNeeded()
                zoomingView.center = keyWindow.center
            } completion: { (completed: Bool) in
            }
        }
    }
    
    @objc func transitionToProjectStep(tapGesture: UITapGestureRecognizer){
        guard let linkLabel = tapGesture.view, let zoomingView = linkLabel.superview as? ZoomingView else {return}
        if  let date = zoomingView.event.date, let stepId = zoomingView.event.stepId, let projectId = zoomingView.event.projectId{
            //no animation
            zoomingView.removeFromSuperview()
            self.zoomBackgroundView?.alpha = 0
            NotificationsRepository.shared.configureVCStack(category: "step", eventDate: date, stepId: stepId, projectId: projectId)
        }
    }
    
    @objc func removeEvent(sender: UIButton){
        
        guard let zoomingView = sender.superview as? ZoomingView else {return}
        let alertVC = UIAlertController(title: "Delete Event?", message: "Are You sure want delete this event?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(UIAlertAction) -> Void in
            let deletedDate = self.eventElements.currentDate
            
            UserActivitySingleton.shared.createUserActivity(description: "Deleted \(zoomingView.event.title) event")
            if #available(iOS 13.0, *) {
                if let notification = zoomingView.event.reminder {
            
                    NotificationManager.shared.removeScheduledNotification(taskId: notification.id)
                    ProjectListRepository.instance.deleteNotificationNote(note: notification)
                }
            }
            
            ProjectListRepository.instance.deleteEvent(event: zoomingView.event)
            
            zoomingView.removeFromSuperview()
            self.zoomBackgroundView?.alpha = 0
            self.assembleGroupedEvents()
            guard let currentDate = self.eventElements.currentDate else {return}
            self.updateCalendarContent(date: currentDate)
        })
        alertVC.addAction(cancelAction)
        alertVC.addAction(deleteAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    
    @objc func editEvent(sender: UIButton){

        guard let zoomingView = sender.superview as? ZoomingView else {return}
        let newEventViewController = NewEventViewController()
        newEventViewController.modalPresentationStyle = .fullScreen
        
        newEventViewController.eventId = zoomingView.event.id
        
        newEventViewController.nameTextField.text = zoomingView.event.title
        
        if let pictureUrl = zoomingView.event.picture{
            newEventViewController.imageHolderView.retreaveImageUsingURLString(myUrl: pictureUrl)
        }
        newEventViewController.descriptionTextView.text = zoomingView.event.descr
        newEventViewController.pictureUrl = zoomingView.event.picture
        if let startTime = zoomingView.event.startTime, let endTime = zoomingView.event.endTime {
            newEventViewController.datePicker.date = startTime
            newEventViewController.startTimePicker.date = startTime
            newEventViewController.endTimePicker.date = endTime

            newEventViewController.eventDate = startTime
            newEventViewController.eventStart = startTime
            newEventViewController.eventEnd = endTime
        }
        
        zoomingView.removeFromSuperview()
        self.zoomBackgroundView?.alpha = 0
        
        navigationController?.present(newEventViewController, animated: true, completion: nil)
    }
    
    @objc func zoomOut(tapGesture: UITapGestureRecognizer){
        
        if let zoomOutView = tapGesture.view?.superview{

            zoomOutView.layer.cornerRadius = 11
            zoomOutView.clipsToBounds = true
        
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
                
                zoomOutView.frame = self.startingFrame!
                
                self.zoomBackgroundView?.alpha = 0
                
                if let zoom = zoomOutView as? ZoomingView{
                    
                    zoom.titleTopAnchor.constant = 12
                    zoom.titleLeadingAnchor.constant = 8
                    zoom.titleTrailingAnchor.constant = -8
                    zoom.eventTimeLeadingAnchor.constant = 8
                    zoom.eventTimeTopAnchor.constant = 0
                    zoom.descriptionLabelTopAnchor.constant = 0
                    zoom.darkViewHeightAnchor.constant = 42
                    
                    if let startingView = self.startingEventView as? EventBubbleView {
                        
                        zoom.title.font = startingView.taskLabel.font
                        zoom.descriptionLabel.font = startingView.descriptionLabel.font
                        zoom.titleHeightAnchor.constant = startingView.taskLabelHeightConstant
                        zoom.eventTimeHeightAnchor.constant = startingView.timeLabelHeightConstant
                        zoom.descriptionLabelHeightAnchor.constant = startingView.descriptionLabelHeightConstant
                        
                        if startingView.descriptionLabel.isHidden == true{
                            zoom.descriptionLabel.alpha = 0
                        }
                        if startingView.timeLabel.isHidden == true{
                            zoom.eventTimeLabel.alpha = 0
                        }
                        
                        zoom.layoutIfNeeded()
                    }
                    
                    zoom.dismissView.alpha = 0
                    zoom.removeButton.alpha = 0
                    zoom.editButton.alpha = 0
                    zoom.clockImageView.alpha = 0
                    zoom.thinUnderline.alpha = 0
                    zoom.eventLink.alpha = 0
                    zoom.linkUnderline.alpha = 0
                }
                zoomOutView.layoutIfNeeded()
            } completion: { (completed: Bool) in
                
                zoomOutView.removeFromSuperview()
                
                self.startingEventView?.isHidden = false
            }
        }
    }
}
