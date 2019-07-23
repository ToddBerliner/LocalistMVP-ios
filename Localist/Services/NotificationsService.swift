//
//  NotificationsService.swift
//  Localist
//
//  Created by Todd Berliner on 11/2/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import Foundation
import UserNotifications
import CoreLocation
import UIKit

class NotificationsService {
    
    enum Identifiers {
        static let viewAction = "VIEW_LIST"
        static let ignoreAction = "IGNORE_ALERT"
        static let listCategory = "LIST_CATEGORY" // local notification
        static let activityCategory = "ACTIVITY_CATEGORY"
        static let dataUpdateCategory = "DATA_UPDATE_CATEGORY"
    }
    
    static let instance = NotificationsService()
    
    private var scheduledNotificationIdentifiers = Set<String>()
    
    private var notificationTriggers = [String:UNLocationNotificationTrigger]()
    
    private let locationManager: LocationManager!
    
    init() {
        locationManager = LocationManager()
    }
    
    func ensureTriggers() {
        // populate triggers
        let lists = DataService.instance.getLists()
        for list in lists {
            for retailer in list.retailers {
                for location in retailer.locations {
                    if notificationTriggers[location.identifier] == nil {
                        // create the notification trigger
                        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                        let region = CLCircularRegion(center: center, radius: location.radius, identifier: location.identifier)
                        region.notifyOnEntry = true
                        region.notifyOnExit = false
                        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
                        self.notificationTriggers[location.identifier] = trigger
                    }
                }
            }
        }
    }
    
    func printScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {(requests) in
            for request in requests {
                let trigger = request.trigger as! UNLocationNotificationTrigger;
                print("List: \(request.content.title) - \(trigger.region.identifier)")
                print(trigger)
            }
        })
    }
    
    func getContentForList(list: List) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Get Your \(list.title) On!"
        let itemsStr = list.items.count == 1 ? "item" : "items"
        content.body = "You've got \(list.items.count) \(itemsStr) to buy."
        content.sound = UNNotificationSound.default
        // TODO: handle error here
        guard list.id != nil else {
            logError(message: "Couldn't get content for list", error: "")
            return content
        }
        content.userInfo = [
            "list_id": list.id!
        ]
        content.categoryIdentifier = Identifiers.listCategory
        return content
    }
    
    func scheduleNotificationRequestsForList(list: List) {
        
        // TODO: handle this
        guard list.items.count != 0 else { return }
        guard list.id != nil else { return }
        
        let content = getContentForList(list: list)
        for retailer in list.retailers {
            for location in retailer.locations {
                guard let trigger = notificationTriggers[location.identifier] else {
                    print("!>> Missing trigger!")
                    continue
                }
                let request = UNNotificationRequest(identifier: location.identifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
                    if let theError = error {
                        logError(message: "Error scheduling notification for list", error: theError.localizedDescription)
                        print("error scheduling: \(theError)")
                    }
                })
            }
        }
    }
    
    func ensureNotifications() {
        
        ensureTriggers()
        
        let lists = DataService.instance.getLists()
        
        // Delete all and recalculate (handles deleting of list)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // loop lists
        for list in lists {
            if list.items.count > 0 {
                // schedule notifications for this list
                self.scheduleNotificationRequestsForList(list: list)
            }
        }
        
        // printScheduledNotifications()
        
        updateAppBadge()
    }
    
    func updateAppBadge() {
        var badgeCount = 0
        let lists = DataService.instance.getLists()
        for list in lists {
           badgeCount += list.items.count
        }
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = badgeCount
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                guard let self = self else { return }
                guard granted else { return }
                
                // Set up categories here
                let viewAction = UNNotificationAction(
                    identifier: Identifiers.viewAction, title: "View List",
                    options: .foreground)
                let ignoreAction = UNNotificationAction(identifier: Identifiers.ignoreAction, title: "Ignore", options: [])
                let listCategory = UNNotificationCategory(
                    identifier: Identifiers.listCategory, actions: [viewAction, ignoreAction],
                    intentIdentifiers: [], options: [])
                
                // 3
                UNUserNotificationCenter.current()
                    .setNotificationCategories([listCategory])
                
                self.getNotificationSettings() // add categories in here
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func scheduleTestNotification() {
        // create content
        let content = UNMutableNotificationContent()
        content.title = "Testing location"
        content.body = "Does this trigger work?"
        content.categoryIdentifier = Identifiers.listCategory
        content.badge = 123
        // create trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "testing-location-trigger", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
            if let theError = error {
                print(theError)
            }
        })
    }
    
    func scheduleTestRemoteNotification() {
        
    }
    
}
