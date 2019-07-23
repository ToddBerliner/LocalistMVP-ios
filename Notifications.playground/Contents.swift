import UIKit
import UserNotifications
import CoreLocation

// Structs
struct Item: Codable {
    var title: String
    init(title: String) {
        self.title = title
    }
}

struct List: Codable {
    var id: Int
    var title: String
    var items: [Item]
    var locations: [Location]
    
    init(id: Int, title: String, items: [Item], locations: [Location]) {
        self.id = id
        self.title = title
        self.items = items
        self.locations = locations
    }
    
    mutating func addItem(item: Item) {
        items.append(item)
    }
    
    mutating func removeItem(itemIndex: Int) {
        items.remove(at: itemIndex)
    }
}

struct Location: Codable {
    var name: String
    var imageName: String
    var latitude: Double
    var longitude: Double
    var identifier: String
    
    init(name: String, imageName: String, latitude: Double, longitude: Double, identifier: String) {
        self.name = name
        self.imageName = imageName
        self.latitude = latitude
        self.longitude = longitude
        self.identifier = identifier
    }
}

struct Lata: Codable {
    var modified: Int64
    var lists: [List]
    
    init(modified: Int64, lists: [List]) {
        self.modified = modified
        self.lists = lists
    }
}

let locations: [String:Location] = [
    "costco-fostercity": Location(name: "Costco", imageName: "", latitude: 123.445, longitude: -123.3234, identifier: "costco-fostercity"),
    "safeway-sanmateo": Location(name: "Safeway", imageName: "", latitude: 123.455, longitude: -123.3333, identifier: "safeway-sanmateo"),
    "traderjoes-sanmateo": Location(name: "Trader Joe's", imageName: "", latitude: 123.455, longitude: -123.3243, identifier: "traderjoes-sanmateo"),
    "traderjoes-millbrae": Location(name: "Trader Joe's", imageName: "", latitude: 123.455, longitude: -123.2314, identifier: "traderjoes-millbrae")
]

var data = Lata(modified: 123456789, lists: [
    List(id: 1, title: "Costco", items: [Item(title: "Swifty")], locations: [
        locations["costco-fostercity"]!
        ]),
    List(id: 2, title: "Groceries", items: [], locations: [
        locations["safeway-sanmateo"]!,
        locations["traderjoes-sanmateo"]!,
        locations["traderjoes-millbrae"]!
        ]),
    ])
// TODO: finish lists

// create all the location triggers
var triggers = [String:UNLocationNotificationTrigger]()
for (identifier, location) in locations {
    // create the notification trigger
    let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    let region = CLCircularRegion(center: center, radius: 2000.0, identifier: "Headquarters")
    region.notifyOnEntry = true
    region.notifyOnExit = false
    let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
    triggers[identifier] = trigger
}

func getContentForList(list: List) -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = "Get Your \(list.title) On!"
    let itemsStr = list.items.count == 1 ? "item" : "itmes"
    content.body = "You've got \(list.items.count) \(itemsStr) to buy."
    return content
}

func scheduleNotificationRequestsForList(list: List) {
    if list.items.count == 0 {
        return
    }
    let content = getContentForList(list: list)
    for location in list.locations {
        let trigger = triggers[location.identifier]
        let request = UNNotificationRequest(identifier: location.identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
            if let theError = error {
                print(theError)
            } else {
                print("Scheduled request with identifier: \(location.identifier)")
            }
        })
    }
}

// Ensure Notificaitons
func ensureNotifications() {
    UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {(requests) in
        // get array of identifiers
        var scheduledIdentifiers = Set<String>()
        var identifiersToRemove = [String]()
        for request in requests {
            scheduledIdentifiers.insert(request.identifier)
        }
        print("Initially scheduled identifiers: \(scheduledIdentifiers)")
        // loop lists
        for list in data.lists {
            if list.items.count == 0 {
                // if list is empty, collect any scheduled identifiers to cancel
                for location in list.locations {
                    if scheduledIdentifiers.contains(location.identifier) {
                        identifiersToRemove.insert(location.identifier, at: 0)
                    }
                }
            } else {
                // schedule notifications for this list
                print("Scheduling notifications for list: \(list.title)")
                scheduleNotificationRequestsForList(list: list)
            }
        }
        // cancel scheduled notifications if necessary
        print("Removing notifications with identifiers: \(identifiersToRemove)")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        
    })
}

scheduleNotificationRequestsForList(list: data.lists[0])

UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {(requests) in
    print(requests)
})

// PROOF - notifications are updated when a new one with the same identifier is scheduled!
//data.lists[0].addItem(item: Item(title: "Foop"))
//scheduleNotificationRequestsForList(list: data.lists[0])
//UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {(requests) in
//    print(requests)
//})

// WORK ARCHIVE
// let list = data.lists[0]
// let loc = list.locations[0]
// // create the notification content
// let notificationContent = UNMutableNotificationContent()
// notificationContent.title = "You've Got \(list.title) Items"
// notificationContent.body = "Swipe to see what you need to buy!"
// // create the notification trigger
// let center = CLLocationCoordinate2D(latitude: 37.335400, longitude: -122.009201)
// let region = CLCircularRegion(center: center, radius: 2000.0, identifier: "Headquarters")
// region.notifyOnEntry = true
// region.notifyOnExit = false
// let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
// // request the notification
// let request = UNNotificationRequest(identifier: loc.identifier, content: notificationContent, trigger: trigger)
// // schedule the request
// let notificationCenter = UNUserNotificationCenter.current()
// notificationCenter.add(request, withCompletionHandler: {(error) in
// if let theError = error {
// print("Error: \(theError)")
// } else {
// print("No error the 1st time!")
// }
// })
// notificationCenter.add(request, withCompletionHandler: {(error) in
// if let theError = error {
// print("Error: \(theError)")
// } else {
// print("No error the 2nd time!")
// }
// })
// notificationCenter.getPendingNotificationRequests(completionHandler: {(requests) in
// print(requests)
// })

var locs = Set<String>()
locs.insert("Costco")
