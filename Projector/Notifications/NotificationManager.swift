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

//notifications based on the trigger type.
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
    
    //defaults category holds badges notification count
    let defaults = UserDefaults(suiteName: "notificationsDefaultsBadgeCount")

    func requestAuthorization(completion: @escaping  (Bool) -> Void) {
    //handles all notification-related behavior in the app.
      UNUserNotificationCenter.current()
        //request authorization to show notifications.
        .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _  in
            //fetch the notification settings
            self.fetchNotificationSettings()
          completion(granted)
        }
    }

    func fetchNotificationSettings() {
      //requests the notification settings authorized by the app.(async)
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        
        DispatchQueue.main.async {
            //update settings
          self.settings = settings
        }
      }
    }
    
    func removeScheduledNotification(taskId: String) {
      UNUserNotificationCenter.current()
        //removeAllPendingNotificationRequests() - removes all pending tasks
        .removePendingNotificationRequests(withIdentifiers: [taskId])
    }

    
    // takes in a parameter of type ProjectStep
    func scheduleNotification(task: Task) {
      
      //creating notification populating the notification content.
      let content = UNMutableNotificationContent()
      content.title = task.name
        content.sound = .default
        
        //check if key/value exist
        if defaults?.value(forKey: "count") == nil{
            defaults?.set(1, forKey: "count")
        }
        
        var count: Int = defaults?.value(forKey: "count") as! Int
        //set badge number
        content.badge = count as NSNumber
        
      
        //anticipate number to future badges
        count = count + 1
        //update defaults count
        defaults?.set(count, forKey: "count")
        content.body = "\(count)"//<--------------- Notification title is for debug purposes

        //content.body = "Gentle reminder for your task!"
      //let the system know that it should assign your notifications to this category.
      content.categoryIdentifier = "OrganizerPlusCategory"
      let taskData = try? JSONEncoder().encode(task)
      if let taskData = taskData {
          //encode the task data and assign it to the notification content’s userInfo
        content.userInfo = ["Task": taskData]//The app will be able to access this content when a user acts on the notification
      }


      // triggers the delivery of a notification
      var trigger: UNNotificationTrigger?
        
        switch task.reminder.reminderType {
        case .time:
            if let timeInterval = task.reminder.timeInterval{
                trigger = UNTimeIntervalNotificationTrigger(
                  timeInterval: TimeInterval(timeInterval),
                  repeats: task.reminder.repeats)
            }
            //threadIdentifier helps group related notifications.
            content.threadIdentifier =
                NotificationManagerConstants.timeBasedNotificationThreadId
        case .calendar:
            //calendar trigger delivers a notification based on a particular date and time
            if let date = task.reminder.date{
                trigger = UNCalendarNotificationTrigger(
                  dateMatching: Calendar.current.dateComponents(
                    [.day, .month, .year, .hour, .minute],
                    from: date),
                  repeats: task.reminder.repeats)
            }
            
            //threadIdentifier helps group related notifications.
            content.threadIdentifier =
                NotificationManagerConstants.calendarBasedNotificationThreadId
        case .location:
          // check if the user has granted at least When In Use location authorization.
            if #available(iOS 14.0, *) {
                guard CLLocationManager().authorizationStatus == .authorizedWhenInUse else {
                    return
                }
                
                if let location = task.reminder.location{
                  // create location-based triggers using UNLocationNotificationTrigger.
                  let center = CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude)
                  let region = CLCircularRegion(//notifyOnEntry and notifyOnExit on CLCircularRegion.
                    center: center,
                    radius: location.radius,
                    identifier: task.id)
                  trigger = UNLocationNotificationTrigger(
                    region: region,
                    repeats: task.reminder.repeats)
                }
            //threadIdentifier helps group related notifications.
            content.threadIdentifier =
                NotificationManagerConstants.locationBasedNotificationThreadId
            }
        }
        
      // create a notification request
      if let trigger = trigger {
        let request = UNNotificationRequest(
          identifier: task.id,
          content: content,
          trigger: trigger)
        // schedule the notification by adding the request
        UNUserNotificationCenter.current().add(request) { error in
          if let error = error {
            print(error)
          }
        }
      }
    }
}
