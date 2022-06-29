//
//  AppDelegate.swift
//  Projector
//
//  Created by Serginjo Melnik on 07.11.2019.
//  Copyright © 2019 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //to call it from viewDidLoad - (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .all
    //disable landscape orientation use
    //var restrictRotation: UIInterfaceOrientationMask = .portrait

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 36,
            migrationBlock: { migration , oldSchemaVersion in
                if oldSchemaVersion < 36 {
                    
                }
            }
        )
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = CustomTabBarController()
        
        UNUserNotificationCenter.current().delegate = self

        //turn off dark mode
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
            //ask for notification based on user location
            let locationManager = LocationManager()
            locationManager.requestAuthorization()

            //request permission for sending notifications
            NotificationManager.shared.requestAuthorization { granted in
              
              if granted {
                //print("Notification permission was granted!")
                //showNotificationSettingsUI = true
              }
            }
        } else {
            // Fallback on earlier versions
        }
        //set  notification delegate as soon as the app launches
        configureUserNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        //return self.restrictRotation
        return .portrait
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        

        //TODO: the tabBarItem updates its badge before notification appears
//       updateTabBarItemBudge()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    //run in foreground
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void
  ) {
      if #available(iOS 14.0, *) {
          NotificationsRepository.shared.updateTabBarItemBudge()
          completionHandler(.banner)
      } else {
          // Fallback on earlier versions
      }
  }
    
    //can config fast actions on notifications
    private func configureUserNotifications() {
        
        // declare two actions
        let dismissAction = UNNotificationAction(//dismiss action
          identifier: "dismiss",//uniquely identifies the action
          title: "Dismiss",
          options: [])//denotes the behavior associated with the action
        let markAsDone = UNNotificationAction(//mark as done
          identifier: "markAsDone",//uniquely identifies the action
          title: "Mark As Done",
          options: [])//denotes the behavior associated with the action
        // define a notification category
        let category = UNNotificationCategory(
          identifier: "OrganizerPlusCategory",
          actions: [dismissAction, markAsDone],
          intentIdentifiers: [],
          options: [])
        // register the new actionable notification
        UNUserNotificationCenter.current().setNotificationCategories([category])

    }
    
    //calls when the user acts on the notification.
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      didReceive response: UNNotificationResponse,
      withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        
        var projectId: String?
        var stepId: String?
        var task: Task?
        
      // Check if the response’s actionIdentifier is set to markAsDone. Then, you decode the task from userInfo
      //if response.actionIdentifier == "markAsDone" {
        
            let userInfo = response.notification.request.content.userInfo
              //decode the task from userInfo.
            if let taskData = userInfo["Task"] as? Data {
                do {
                    task = try JSONDecoder().decode(Task.self, from: taskData)
                    if let task = task {
                        projectId = task.projectId
                        stepId = task.stepId
                    }
                } catch {
                    print("failed to decode task: ", error)
            }
              
        //}
      }
        //check if defaults category exist
        if let defaults = UserDefaults(suiteName: "notificationsDefaultsBadgeCount"){
            //get value from count key
            let count: Int = defaults.value(forKey: "count") as! Int
            //reset budges after
            defaults.set(count - 1, forKey: "count")
        }
        
        if let task = task {
            //configure viewControllers stack view inside navigation controller
            NotificationsRepository.shared.configureVCStack(category: task.category, eventDate: task.eventDate, stepId: stepId, projectId: projectId)
        }
        
        //it will set to nil tab bar item
        NotificationsRepository.shared.updateTabBarItemBudge()
        completionHandler()
    }
}
