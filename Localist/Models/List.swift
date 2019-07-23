//
//  List.swift
//  Localist
//
//  Created by Todd Berliner on 10/25/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import Foundation

struct List: Codable {
    var id: Int?
    var title: String
    var items: [Item]
    var retailers: [Retailer]
    var members: [Person]
    var updated: Double
    
    init(id: Int? = nil, title: String, items: [Item], retailers: [Retailer], members: [Person]) {
        self.id = id
        self.title = title
        self.items = items
        self.retailers = retailers
        self.members = members
        self.updated = Date().timeIntervalSince1970
    }
    
    mutating func addItem(item: Item) {
        items.append(item)
        self.setUpdated()
    }
    
    mutating func removeItem(itemIndex: Int) {
        items.remove(at: itemIndex)
        self.setUpdated()
    }
    
    mutating func setMembers(members: [Person]) {
        self.members = members
        self.setUpdated()
    }
    
    mutating func setRetailers(retailers: [Retailer]) {
        self.retailers = retailers
        self.setUpdated()
    }
    
    mutating func setTitle(title: String) {
        self.title = title
        self.setUpdated()
    }
    
    mutating func setUpdated() {
        self.updated = Date().timeIntervalSince1970
    }
}
