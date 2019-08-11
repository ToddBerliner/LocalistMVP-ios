//
//  AppDelegate.swift
//  Localist
//
//  Created by Todd Berliner on 10/11/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import os

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    let backgroundSessionController = BackgroundSessionController()
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Set UserNotifications delegate
        UNUserNotificationCenter.current().delegate = self
        
        // SyncData on launch (spot 1 of 2 in AppDelegate)
        if DataService.instance.getUser() != nil {
            print(">>> willFinishLaunchingWithOptions >>> Syncing")
            ArchiveService.instance.delayedSync(delay: 0)
        }
        
        // Request location permission
        LocationManager.instance.requestLocation()
        
        return true
        
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Register for remote notifications
        if DataService.instance.getUser() != nil {
            NotificationsService.instance.registerForPushNotifications()
        }
        
        return true
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
        
        // SyncData on foregrounding (spot 2 of 2 in AppDelegate)
        if DataService.instance.getUser() != nil {
            print(">>> willEnterForeground >>> Syncing")
            // likely don't need this one - if the app was backgrounded push notifications would
            // have updated it
            ArchiveService.instance.delayedSync(delay: 0)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - User Notifications stack
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        
        // Record the notification presentation
        let category = notification.request.content.categoryIdentifier
        if (category == NotificationsService.Identifiers.listCategory) {
            if let listId = notification.request.content.userInfo["list_id"] as? Int {
                recordLocalistLocationAlert(localistId: listId)
            }
        }
        
        // Go ahead and display the notification
        completionHandler([.alert, .badge, .sound])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Handle notifications based on category
        let category = response.notification.request.content.categoryIdentifier
        switch category {
        case NotificationsService.Identifiers.listCategory:
            
            // Handle notifications of the LIST_CATEGORY to open the app and
            // navigate to the appropriate list
            guard let listId = response.notification.request.content.userInfo["list_id"] as? Int else {
                completionHandler()
                return
            }
            
            // Handle view or ignore actions
            if response.actionIdentifier == NotificationsService.Identifiers.viewAction ||
                response.actionIdentifier == UNNotificationDefaultActionIdentifier {
                recordLocalistLocationAlert(localistId: listId, action: "viewed")
                // Pop to root of navigation
                if let navigationController = self.window?.rootViewController as? UINavigationController {
                    navigationController.popToRootViewController(animated: false)
                    if let listsViewController = navigationController.topViewController as? ListsViewController {
                        // set destinationListId to handle app launching from notification
                        listsViewController.destinationListId = listId
                        // handle app already running
                        listsViewController.navigateToList(listId: listId)
                    }
                    
                }
            }
            completionHandler()
        case NotificationsService.Identifiers.dataUpdateCategory:
            completionHandler() // dataUpdate has no alert
        case NotificationsService.Identifiers.activityCategory:
            completionHandler() // just present the notification
        default:
            completionHandler() // just present the notification
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Recieved data update notification, sync
        ArchiveService.instance.syncDataWithServer { success in
            if (success) {
                completionHandler(.newData)
            } else {
                completionHandler(.failed)
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // get device token and add to User and then syncData
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        DataService.instance.setApnsToken(token: token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Set alert to user and ask to try again
        print(">>> Error registering for APNS token")
        print(error)
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Localist")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

