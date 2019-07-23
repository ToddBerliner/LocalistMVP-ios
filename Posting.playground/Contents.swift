import UIKit

var str = "Hello, playground"

Date(timeIntervalSince1970: 1542078299.4047508)

let encoder = JSONEncoder()
let decoder = JSONDecoder()

struct ServerResponse: Codable {
    var Items: [Lata]
    init(Lata: [Lata]) {
        self.Items = Lata
    }
}

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
    var ModifiedTimestamp: Double
    var ListType: String
    var Lists: [List]
    
    init(ModifiedTimestamp: Double, Lists: [List]) {
        self.ListType = "Shared"
        self.ModifiedTimestamp = ModifiedTimestamp
        self.Lists = Lists
    }
}

let data = Lata(ModifiedTimestamp: 123456789, Lists: [
    List(id: 1, title: "Costco", items: [], locations: [
        Location(name: "Costco", imageName: "foo", latitude: 123.445, longitude: -123.3234)
        ], notificationIdentifiers: [
            "costco-fostercity"]),
    List(id: 2, title: "Groceries", items: [], locations: [
        Location(name: "Safeway", imageName: "foo", latitude: 123.455, longitude: -123.3333),
        Location(name: "Trader Joe's", imageName: "foo", latitude: 123.455, longitude: -123.3243),
        Location(name: "Trader Joe's", imageName: "foo", latitude: 123.455, longitude: -123.2314)
        ], notificationIdentifiers: [
            "safeway-sanmateo",
            "traderjoes-sanmateo",
            "traderjoes-millbrae"]),
    List(id: 3, title: "Chinese Groceries", items: [], locations: [
        Location(name: "99 Ranch Market", imageName: "foo", latitude: 123.555, longitude: -123.455),
        Location(name: "Marina Foods", imageName: "foo", latitude: 123.455, longitude: -123.455)
        ], notificationIdentifiers: [
            "99ranchmarket-fostercity",
            "marinafoods-sanmateo"]),
    List(id: 4, title: "Japanese Groceries", items: [], locations: [
        Location(name: "Suruki Market", imageName: "foo", latitude: 123.444, longitude: -123.445)], notificationIdentifiers: [
            "surukimarket-sanmateo"]),
    List(id: 5, title: "Household", items: [], locations: [
        Location(name: "Target", imageName: "foo", latitude: 123.444, longitude: -123.444)],
         notificationIdentifiers: [
            "target-fostercity"])
    ])

let localModified = data.ModifiedTimestamp
let uploadData = try encoder.encode(data)

let uploadDataString = String(data: uploadData, encoding: .utf8)
print(uploadDataString)

let url = URL(string: "https://2mujusmxz0.execute-api.us-east-1.amazonaws.com/dev/sync")!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")

let fullRes = """
{
"Items": [
{
"Lists": [
{
"locations": [
{
"name": "Costco",
"imageName": "foo",
"latitude": 123.445,
"longitude": -123.3234
}
],
"id": 1,
"title": "Costco",
"items": [],
"notificationIdentifiers": [
"costco-fostercity"
]
},
{
"locations": [
{
"name": "Safeway",
"imageName": "foo",
"latitude": 123.455,
"longitude": -123.3333
},
{
"name": "Trader Joe's",
"imageName": "foo",
"latitude": 123.455,
"longitude": -123.3243
},
{
"name": "Trader Joe's",
"imageName": "foo",
"latitude": 123.455,
"longitude": -123.2314
}
],
"id": 2,
"title": "Groceries",
"items": [],
"notificationIdentifiers": [
"safeway-sanmateo",
"traderjoes-sanmateo",
"traderjoes-millbrae"
]
},
{
"locations": [
{
"name": "99 Ranch Market",
"imageName": "foo",
"latitude": 123.555,
"longitude": -123.455
},
{
"name": "Marina Foods",
"imageName": "foo",
"latitude": 123.455,
"longitude": -123.455
}
],
"id": 3,
"title": "Chinese Groceries",
"items": [],
"notificationIdentifiers": [
"99ranchmarket-fostercity",
"marinafoods-sanmateo"
]
},
{
"locations": [
{
"name": "Suruki Market",
"imageName": "foo",
"latitude": 123.444,
"longitude": -123.445
}
],
"id": 4,
"title": "Japanese Groceries",
"items": [],
"notificationIdentifiers": [
"surukimarket-sanmateo"
]
},
{
"locations": [
{
"name": "Target",
"imageName": "foo",
"latitude": 123.444,
"longitude": -123.444
}
],
"id": 5,
"title": "Household",
"items": [],
"notificationIdentifiers": [
"target-fostercity"
]
}
],
"ListType": "Shared",
"ModifiedTimestamp": 1542047030.748214
}
],
"Count": 1,
"ScannedCount": 1,
"LastEvaluatedKey": {
"ListType": "Shared",
"ModifiedTimestamp": 1542047030.748214
}
}
"""

let sres = """
{
"Items": []
}
"""

//let sresp = fullRes.data(using: .utf8)
//do {
//    let dr = try decoder.decode(ServerResponse.self, from: sresp!)
//    print(dr)
//} catch let error {
//    print(error)
//}

let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
    if let error = error {
        print ("error: \(error)")
        return
    }
    guard let response = response as? HTTPURLResponse,
        (200...299).contains(response.statusCode) else {
            print ("server error")
            return
    }
    if let mimeType = response.mimeType,
        mimeType == "application/json",
        let data = data
    {
        print(data)
        let decoded = try? decoder.decode(ServerResponse.self, from: data)
        print(decoded!.Items[0])
    }
}
task.resume()
print(" -- here")
