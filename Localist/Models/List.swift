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
    var markedItems: [Item]
    var retailers: [Retailer]
    var members: [Person]
    var updated: Double
    
    init(id: Int? = nil, title: String, items: [Item], markedItems: [Item], retailers: [Retailer], members: [Person]) {
        self.id = id
        self.title = title
        self.items = items
        self.markedItems = markedItems
        self.retailers = retailers
        self.members = members
        self.updated = Date().timeIntervalSince1970
    }
    
    mutating func editItem(itemIndex: Int, itemText: String) {
        self.items[itemIndex].updateTitle(title: itemText)
    }
    
    mutating func addItem(item: Item) {
        self.items.insert(item, at: self.getIndexOfMarked())
        self.setUpdated()
    }
    
    mutating func restoreItem(itemIndex: Int) {
        var item = self.markedItems.remove(at: itemIndex)
        item.setMarked(marked: false)
        // move unmarked item to top of marked list
        self.items.append(item)
        self.setUpdated()
    }
    
    mutating func removeItem(itemIndex: Int) {
        var item = items.remove(at: itemIndex)
        item.setMarked(marked: true)
        self.markedItems.insert(item, at: 0)
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
    
    func getIndexOfMarked() -> Int {
        if let markedIndex = self.items.firstIndex(where: {$0.marked != nil}) {
            return markedIndex
        } else {
            return self.items.count
        }
    }
}
