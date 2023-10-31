//
//  NotificationManager.swift
//  Projector
//
//  Created by Serginjo Melnik on 15/05/22.
//  Copyright © 2022 Serginjo Melnik. All rights reserved.
//

import Foundation
import UserNotifications
import CoreLocation
import UIKit


enum NotificationManagerConstants {
    static let timeBasedNotificationThreadId =
    "TimeBasedNotificationThreadId"
    static let calendarBasedNotificationThreadId =
    "CalendarBasedNotificationThreadId"
    static let locationBasedNotificationThreadId =
    "LocationBasedNotificationThreadId"
}

@available(iOS 13.0, *)
class NotificationManager: ObservableObject{
    static let shared = NotificationManager()
    @Published var settings: UNNotificationSettings?
    func requestAuthorization(completion: @escaping  (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _  in
                self.fetchNotificationSettings()
                completion(granted)
            }
    }
    
    func fetchNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            DispatchQueue.main.async {
               self.settings = settings
            }
        }
    }
    
    func removeScheduledNotification(taskId: String) {
        UNUserNotificationCenter.current()
        
            .removePendingNotificationRequests(withIdentifiers: [taskId])
    }
    
    func scheduleNotification(task: Task) {
    
        let content = UNMutableNotificationContent()
        content.title = task.name
        
        content.sound = .default
        content.badge = 1
        content.body = "Gentle reminder for your task!"
        
        
        content.categoryIdentifier = "OrganizerPlusCategory"
        let taskData = try? JSONEncoder().encode(task)
        if let taskData = taskData {
            
            content.userInfo = ["Task": taskData]
        }
        var trigger: UNNotificationTrigger?
        
        switch task.reminder.reminderType {
        case .time:
            if let timeInterval = task.reminder.timeInterval{
                trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: TimeInterval(timeInterval),
                    repeats: task.reminder.repeats)
            }

            content.threadIdentifier =
            NotificationManagerConstants.timeBasedNotificationThreadId
        case .calendar:
        
            if let date = task.reminder.date{
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents(
                        [.day, .month, .year, .hour, .minute],
                        from: date),
                    repeats: task.reminder.repeats)
            }
            
            content.threadIdentifier =
            NotificationManagerConstants.calendarBasedNotificationThreadId
        case .location:
            
            if #available(iOS 14.0, *) {
                guard CLLocationManager().authorizationStatus == .authorizedWhenInUse else {
                    return
                }
                
                if let location = task.reminder.location{
                    
                    let center = CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude)
                    let region = CLCircularRegion(
                        
                        center: center,
                        radius: location.radius,
                        identifier: task.id)
                    trigger = UNLocationNotificationTrigger(
                        region: region,
                        repeats: task.reminder.repeats)
                }
                
                content.threadIdentifier =
                NotificationManagerConstants.locationBasedNotificationThreadId
            }
        }
        
        if let trigger = trigger {
            let request = UNNotificationRequest(
                identifier: task.id,
                content: content,
                trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print(error)
                }
            }
        }
    }
}
