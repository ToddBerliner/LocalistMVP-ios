//
//  ArchiveService.swift
//  Localist
//
//  Created by Todd Berliner on 11/9/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import Foundation
import SystemConfiguration
import MapKit

class ArchiveService {
    
    static let instance = ArchiveService()
    
    let reachability = SCNetworkReachabilityCreateWithName(nil, "toddberliner.us")
    
    var pendingSync: DispatchWorkItem?
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func storeLastLocation(location: CLLocation) {
        let dataFilePath = getDocumentsDirectory().appendingPathComponent(LOCATION_FILE_NAME)
        do {
            let archiveData = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: false)
            try archiveData.write(to: dataFilePath)
        } catch let error {
            logError(message: "Error storing last location", error: error.localizedDescription)
            print("*** Error storing last location: \(error)")
        }
    }
    
    func getLastStoredLocation() -> CLLocation? {
        let dataFilePath = getDocumentsDirectory().appendingPathComponent(LOCATION_FILE_NAME)
        do {
            // get the data
            let dataFromFile = try Data(contentsOf: dataFilePath)
            // unarchive the data
            let lastStoredLocation = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(dataFromFile)
            // decode the data
            return lastStoredLocation as? CLLocation
        } catch {
            // no file found or error retrieving it; return default data
            return nil
        }
    }
    
    // Func to save data, requires DataRoot
    func archiveData() {
        let dataFilePath = getDocumentsDirectory().appendingPathComponent(DATA_FILE_NAME)
        if let data = DataService.instance.getData() {
            do {
                // encode the data
                let encodedData = try JSONEncoder().encode(data)
                // create data archive
                let archivedData = try NSKeyedArchiver.archivedData(withRootObject: encodedData, requiringSecureCoding: false)
                // save it
                try archivedData.write(to: dataFilePath)
                // ensure notifications are set
                NotificationsService.instance.ensureNotifications()
            } catch let error {
                print(error)
            }
        }
    }
    
    // Func to retrieve saved data, returns DataRoot
    func unarchiveData() -> DataRoot {
        let dataFilePath = getDocumentsDirectory().appendingPathComponent(DATA_FILE_NAME)
        var data: DataRoot? = nil
        do {
            // get the data
            let dataFromFile = try Data(contentsOf: dataFilePath)
            // unarchive the data
            let unarchivedLataData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(dataFromFile)
            // decode the data
            data = try JSONDecoder().decode(DataRoot.self, from: unarchivedLataData as! Data)
        } catch {
            // no file found or error retrieving it; return default data
            return getDefaultData()
        }
        return data!
    }
    
    func delayedSync(delay: Int = 5) {
        // cancel a pending sync if exists
        pendingSync?.cancel()
        
        let requestWorkItem = DispatchWorkItem {
            ArchiveService.instance.syncDataWithServer()
        }
        
        pendingSync = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay),
                                      execute: requestWorkItem)
    }
    
    func getRequest() -> URLRequest? {
        let url = URL(string: SYNC_DATA_URL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func syncDataWithServer(_ completion: @escaping (Bool) -> Void = {_ in }) {
        
        // NotificationsService.instance.ensureNotifications()
        self.archiveData()
        
        print(">>> START SYNC - foreground")
        
        // get current data
        let encodedData = DataService.instance.getEncodedData()!
        
        // get request
        let request = getRequest()!
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.waitsForConnectivity = true
        let session = URLSession(configuration: sessionConfiguration)
        
        session.uploadTask(with: request, from: encodedData, completionHandler: {(data, _, _) in
            guard let data = data else {
                print("no data in uploadTask!")
                return
            }
            do {
                //Decode retrived data with JSONDecoder and assing type of Article object
                let serverResponse = try JSONDecoder().decode(DataRootFromServer.self, from: data)
                let serverData = serverResponse.data
                // save data TODO: conditionally do this?
                DataService.instance.setData(data: serverData)
                // ensure notifications are set
                NotificationsService.instance.ensureNotifications()
                completion(true)
                self.pendingSync = nil
                print("<<< DONE SYNC")
            } catch let error {
                print("Error parsing server response: \(error)")
                completion(false)
            }
        }).resume()
    }
    
    func syncDataWithServerInBackground(completion: @escaping (Bool) -> Void) {
        
        do {
            
            // get current data
            let data = DataService.instance.getData()!
            
            // send to server
            let encodedData = try JSONEncoder().encode(data)
            let url = URL(string: SYNC_DATA_URL)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            print(">>> START SYNC - in background")
            
            URLSession.shared.uploadTask(with: request, from: encodedData, completionHandler: {(data, response, error) in
                
                print("<<< DONE SYNC")
                
                if let error = error {
                    print("error: \(error)")
                    return
                }
                guard let data = data else {
                    return
                }
                do {
                    //Decode retrived data with JSONDecoder and assing type of Article object
                    let serverResponse = try JSONDecoder().decode(DataRootFromServer.self, from: data)
                    let serverData = serverResponse.data
                    // save data TODO: conditionally do this?
                    DataService.instance.setData(data: serverData)
                    // ensure notifications are set
                    NotificationsService.instance.ensureNotifications()
                } catch let jsonError {
                    logError(message: "Error in syncData jsonError", error: jsonError.localizedDescription)
                    print(jsonError)
                }
                
                completion(true)
                
            }).resume()
            
        } catch let error {
            logError(message: "Error in URLSession uploadTask", error: error.localizedDescription)
            print(error)
        }
    }
    
    func deleteListFromServer(listId: Int) {
        // NotificationsService.instance.ensureNotifications()
        self.archiveData()
        
        guard let user = DataService.instance.getUser(), let userId = user.id else {
            return
        }
        
        // send to server
        let url = URL(string: "\(DELETE_LIST_URL)?user_id=\(userId)&id=\(listId)")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print(">>> START DELETE")
        URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
            print("<<< DONE DELETE")
            if let error = error {
                logError(message: "Error deleing list", error: error.localizedDescription)
                print("error: \(error)")
                return
            }
            guard let data = data else {
                return
            }
            do {
                let serverResponse = try JSONDecoder().decode(DataRootFromServer.self, from: data)
                let serverData = serverResponse.data
                // save data TODO: conditionally do this?
                DataService.instance.setData(data: serverData)
                // ensure notifications are set
                NotificationsService.instance.ensureNotifications()
            } catch let jsonError {
                logError(message: "Error in URLSession deleteTask jsonError", error: jsonError.localizedDescription)
                print(jsonError)
            }
        }).resume()
    }
    
    // Func to return hardcoded default DataRoot
    func getDefaultData() -> DataRoot {
        return DataRoot(people: [], lists: [])
    }
}
