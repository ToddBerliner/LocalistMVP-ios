import UIKit

var str = "Hello, playground"

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
    var notificationIdentifiers: [String]
    
    init(id: Int, title: String, items: [Item], locations: [Location], notificationIdentifiers: [String]) {
        self.id = id
        self.title = title
        self.items = items
        self.locations = locations
        self.notificationIdentifiers = notificationIdentifiers
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
    
    init(name: String, imageName: String, latitude: Double, longitude: Double) {
        self.name = name
        self.imageName = imageName
        self.latitude = latitude
        self.longitude = longitude
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

let data = Lata(modified: 123456789, lists: [
    List(id: 1, title: "Costco", items: [], locations: [
        Location(name: "Costco", imageName: "", latitude: 123.445, longitude: -123.3234)
        ], notificationIdentifiers: [
            "costco-fostercity"]),
    List(id: 2, title: "Groceries", items: [], locations: [
        Location(name: "Safeway", imageName: "", latitude: 123.455, longitude: -123.3333),
        Location(name: "Trader Joe's", imageName: "", latitude: 123.455, longitude: -123.3243),
        Location(name: "Trader Joe's", imageName: "", latitude: 123.455, longitude: -123.2314)
        ], notificationIdentifiers: [
            "safeway-sanmateo",
            "traderjoes-sanmateo",
            "traderjoes-millbrae"]),
    List(id: 3, title: "Chinese Groceries", items: [], locations: [
        Location(name: "99 Ranch Market", imageName: "", latitude: 123.555, longitude: -123.455),
        Location(name: "Marina Foods", imageName: "", latitude: 123.455, longitude: -123.455)
        ], notificationIdentifiers: [
            "99ranchmarket-fostercity",
            "marinafoods-sanmateo"]),
    List(id: 4, title: "Japanese Groceries", items: [], locations: [
        Location(name: "Suruki Market", imageName: "", latitude: 123.444, longitude: -123.445)], notificationIdentifiers: [
            "surukimarket-sanmateo"]),
    List(id: 5, title: "Household", items: [], locations: [
        Location(name: "Target", imageName: "", latitude: 123.444, longitude: -123.444)],
         notificationIdentifiers: [
            "target-fostercity"])
    ])

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
//
let dataFilePath = getDocumentsDirectory().appendingPathComponent("localistdata")

// data is JSONEncoded
let encodedData = try? JSONEncoder().encode(data)
// data is converted to a string
//if let encodedDataAsString = String(data: encodedData!, encoding: .utf8) {
//    if let jsonData = encodedDataAsString.data(using: .utf8) {
//        if var data = try? JSONDecoder().decode(Lata.self, from: jsonData) {
//            data.lists[0].addItem(item: Item(title: "Whoop!"))
//            data.lists[0].addItem(item: Item(title: "Whoop!"))
//            data.lists[0].addItem(item: Item(title: "Whoop!"))
//        }
//    }
//}

// save the data
//let archivedData = try NSKeyedArchiver.archivedData(withRootObject: encodedData!, requiringSecureCoding: false)
//try archivedData.write(to: dataFilePath)
//
//if let dataFromFile = try? Data(contentsOf: dataFilePath) {
//
//    // print(type(of: dataFromFile))
//
//    let unarchivedData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(dataFromFile as Data)
//    // print(unarchivedData!)
//}

// DONT TOUCH THIS - IT WORKS!
//do {
//    let archivedData = try NSKeyedArchiver.archivedData(withRootObject: encodedData!, requiringSecureCoding: false)
//
//    try archivedData.write(to: dataFilePath)
//    let dataFromFile = try? Data(contentsOf: dataFilePath)
//
////    print(type(of: dataFromFile))
////    print(type(of: archivedData))
////    print(dataFromFile)
////    print(archivedData)
//    // print(archivedData)
//    let unarchivedWorks = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedData)
//    print(type(of: unarchivedWorks))
//    print(unarchivedWorks!)
//    let data = try? JSONDecoder().decode(Lata.self, from: unarchivedWorks as! Data)
//    print(type(of: data))
//    print(data!)
//
//    let unarchivedDataFromFile = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(dataFromFile!)
//    print(type(of: unarchivedDataFromFile))
//    print(unarchivedDataFromFile!)
//    let ddata = try? JSONDecoder().decode(Lata.self, from: unarchivedDataFromFile as! Data)
//    print(type(of: ddata))
//    print(ddata!)
//} catch let error {
//    print(error)
//}

func saveLataData(data: Lata) -> Bool {
    do {
        // encode the data
        let encodedData = try JSONEncoder().encode(data)
        // create data archive
        let archivedData = try NSKeyedArchiver.archivedData(withRootObject: encodedData, requiringSecureCoding: false)
        // save it
        try archivedData.write(to: dataFilePath)
    } catch let error {
        print(error)
        return false
    }
    return true
}

func retrieveLataData() -> Lata? {
    var lata: Lata? = nil
    do {
        // get the data
        let dataFromFile = try Data(contentsOf: dataFilePath)
        // unarchive the data
        let unarchivedLataData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(dataFromFile)
        // decode the data
        lata = try JSONDecoder().decode(Lata.self, from: unarchivedLataData as! Data)
    } catch let error {
        print(error)
        return nil
    }
    return lata
}

print(saveLataData(data: data))
// check it out
if var lata = retrieveLataData() {
    print(lata.lists[0].items)
    // make some changes
    lata.lists[0].addItem(item: Item(title: "Whoopie!"))
    // save changes
    print(saveLataData(data: lata))
    // check out changes
    if var lata = retrieveLataData() {
        print(lata.lists[0].items)
    }
}
