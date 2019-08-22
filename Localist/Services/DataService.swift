//
//  DataService.swift
//  Localist
//
//  Created by Todd Berliner on 10/25/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import Foundation

class DataService {
    
    static let instance = DataService()
    
    /*
     AppDelegate - launch
        - ensure archive data is up to date so DataService.init gets
            up to date information
    */
    
    private init() {
        // at this point, ApplicationDidLaunch will have updated the archive
        let existingData = ArchiveService.instance.unarchiveData()
        self.data = existingData
    }
    
    private var data: DataRoot?
    
    // initial, hardcoded lists
    private var people: [Person] = []
    
    private var retailers: [Retailer] = []
    
    func getData() -> DataRoot? {
        return self.data
    }
    
    func getEncodedData() -> Data? {
        guard let data = self.getData() else { return nil }
        do {
            return try JSONEncoder().encode(data)
        } catch let error {
            logError(message: "Error getting encoded data", error: error.localizedDescription)
            print("!!! Error getting encoded data")
            print(error.localizedDescription)
            return nil
        }
    }
    
    func setData(data: DataRoot) {
        
        // set user (no side effects - keep them in sync)
        self.data!.User = data.User
        
        // set people (no side effects - keep them in sync)
        self.data!.People = data.People
        
        var syncedLists: [List] = []
        var storedIds: [Int] = []
        
        // Add, update or remove existing lists so only the newest version of a list is kept
        for existingList in self.data!.Lists {
            // existing list w/o id - ignore it, it was added else it must be retried by user
            if existingList.id == nil {
                continue
            }
            // list id matches - compare List.updated & keep newer
            for serverList in data.Lists {
                if serverList.id != nil, existingList.id == serverList.id {
                    storedIds.append(existingList.id!)
                    // store newer
                    if (existingList.updated == serverList.updated) {
                        syncedLists.append(existingList)
                    } else if (existingList.updated > serverList.updated) {
                        syncedLists.append(existingList)
                    } else {
                        syncedLists.append(serverList)
                    }
                    continue
                }
            }
            // existing list id not found - ignore it, it was deleted
        }
        
        // Add new lists from server
        // id not found in stored lists, add it
        for serverList in data.Lists {
            if serverList.id != nil, !storedIds.contains(serverList.id!) {
                syncedLists.append(serverList)
            }
        }
        
        // Update and save the data locally
        self.data!.Lists = syncedLists
        ArchiveService.instance.archiveData()
        
        // Notify the UI
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: dataModelDidUpdateNotification), object: nil)
    }
    
    func getUser() -> Person? {
        guard let user = self.data!.User else {
            return nil
        }
        return user
    }
    
    func setUser(person: Person) {
        
        data!.User = person
        ArchiveService.instance.archiveData()
        NotificationsService.instance.registerForPushNotifications()
        // includes handler to set apns on User and send to server
    }
    
    func setApnsToken(token: String) {
        guard self.data!.User != nil else { return }
        guard self.data!.User!.apns != token else { return }
        self.data!.User!.setApns(token: token)
        
        // update UI
        updateUI()
        
        // send to server
        ArchiveService.instance.delayedSync(delay: 0) // got APNS token, send to server
    }
    
    func addList(list: List) {
        data!.Lists.append(list)
        
        // update UI
        updateUI()
        
        // send to server
        ArchiveService.instance.delayedSync(delay: 0) // new list, send to server
    }
    
    func removeList(listRowIndex: Int) {
        let list = data!.Lists[listRowIndex]
        data!.removeList(itemIndex: listRowIndex)
        if let listId = list.id {
            
            // update UI
            updateUI()
            
            // send to server
            ArchiveService.instance.deleteListFromServer(listId: listId) // includes new data from server
        }
    }
    
    func getLists() -> [List] {
        if let dataForTable = data?.Lists {
            return dataForTable
        } else {
            return []
        }
    }
    
    func getListIndexByListId(listId: Int) -> Int? {
        
        for (index, list) in self.data!.Lists.enumerated() {
            guard let id = list.id else { continue }
            if id == listId {
                return index
            }
        }
        return nil
        
    }
    
    func setPeople(people: [Person]) {
        self.data!.People = people
        
        // update UI
        updateUI()
        
        // send to server
        ArchiveService.instance.delayedSync(delay: 0) // new contacts, send to server
    }
    
    func getPeople() -> [Person] {
        // get the existing people in the DataRoot
        // get the contacts
        // get the intersection and update the existing people in DataRoot and return
        let people = self.data!.People
        return people
    }
    
    func editItemInList(itemText: String, itemIndex: Int, listRowIndex: Int) {
        // edit item
        data!.Lists[listRowIndex].editItem(itemIndex: itemIndex, itemText: itemText)
        // save locally
        ArchiveService.instance.archiveData()
        
        // update UI
        updateUI()
        
        // sync changes with server
        ArchiveService.instance.delayedSync() // new item, send to server
    }
    
    func addItemToList(item: Item, listRowIndex: Int) {
        // add the item
        data!.Lists[listRowIndex].addItem(item: item)
        // save locally
        ArchiveService.instance.archiveData()
        
        // update UI
        updateUI()
        
        // sync changes with server
        ArchiveService.instance.delayedSync() // new item, send to server
    }
    
    func removeItemFromList(itemIndex: Int, listRowIndex: Int) {
        // remove (mark) the item
        data!.Lists[listRowIndex].removeItem(itemIndex: itemIndex)
        // save locally
        ArchiveService.instance.archiveData()
        
        // update UI
        updateUI()
        
        // sync changes with server
        ArchiveService.instance.delayedSync() // marked item, send to server
    }
    
    func updateList(listRowIndex: Int, title: String, members: [Person], retailers: [Retailer]) {
        
        // Update the members
        data!.Lists[listRowIndex].setMembers(members: members)
        // Update the retailers
        data!.Lists[listRowIndex].setRetailers(retailers: retailers)
        // Update the name
        data!.Lists[listRowIndex].setTitle(title: title)
        // set the modified time
        data!.Lists[listRowIndex].setUpdated()
        
        // update UI
        updateUI()
        
        // sync changes with server
        ArchiveService.instance.delayedSync(delay: 0) // list update, send to server
    }
    
    func updateUI() {
        // save locally
        ArchiveService.instance.archiveData()
        // Notify the UI
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: dataModelDidUpdateNotification), object: nil)
    }
    
    func resetData() {
        let defaultData = ArchiveService.instance.getDefaultData()
        self.data!.People = []
        self.setData(data: defaultData)
    }
    
}
