//
//  Constants.swift
//  Localist
//
//  Created by Todd Berliner on 11/8/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import Foundation
import os

// Seques
let TO_LIST = "ItemViewController"
let TO_ADD_EDIT_LIST = "AddEditListViewController"
let TO_ADD_EDIT_PEOPLE = "AddEditPeopleViewController"
let TO_ADD_EDIT_RETAILERS = "AddEditRetailersViewController"
let SHOW_SELECT_LOCATIONS = "SelectLocationsViewController"
let TO_LOGIN = "LoginViewContoller"

// Archive File Name
let DATA_FILE_NAME = "localistdata"
let LOCATION_FILE_NAME = "localistlastlocation"

// Notification Names
let dataModelDidUpdateNotification = "dataModelDidUpdateNotification"
let locationUpdateNotification = "locationUpdateNotification"

// Strings

//let SYNC_DATA_URL = "http://172.19.130.53:8808/api/syncdata.json"
//let DELETE_LIST_URL = "http://172.19.130.53:8808/api/deletelist.json"
//let GET_SERVER_PEOPLE_URL = "http://172.19.130.53:8808/api/getserverpeople.json"
//let DEVICE_LOG_URL = "http://172.19.130.53:8808/api/logfromdevice.json"
//let LOCATION_ALERT_URL = "http://172.19.130.53:8808/api/recordlocalistalert.json"


// LOCAL
//let SYNC_DATA_URL = "http://localhost:8808/api/syncdata.json"
//let DELETE_LIST_URL = "http://localhost:8808/api/deletelist.json"
//let GET_SERVER_PEOPLE_URL = "http://localhost:8808/api/getserverpeople.json"
//let DEVICE_LOG_URL = "http://localhost:8808/api/logfromdevice.json"
//let LOCATION_ALERT_URL = "http://localhost:8808/api/recordlocalistalert.json"


// HOME
let SYNC_DATA_URL = "http://10.0.0.79:8808/api/syncdata.json"
let DELETE_LIST_URL = "http://10.0.0.79:8808/api/deletelist.json"
let GET_SERVER_PEOPLE_URL = "http://10.0.0.79:8808/api/getserverpeople.json"
let DEVICE_LOG_URL = "http://10.0.0.79:8808/api/logfromdevice.json"
let LOCATION_ALERT_URL = "http://10.0.0.79:8808/api/recordlocalistalert.json"

// OFFICE
//let SYNC_DATA_URL = "http://10.1.10.79:8808/api/syncdata.json"
//let DELETE_LIST_URL = "http://10.1.10.79:8808/api/deletelist.json"
//let GET_SERVER_PEOPLE_URL = "http://10.1.10.79:8808/api/getserverpeople.json"
//let DEVICE_LOG_URL = "http://10.1.10.79:8808/api/logfromdevice.json"
//let LOCATION_ALERT_URL = "http://10.1.10.79:8808/api/recordlocalistalert.json"

// PROD
//let SYNC_DATA_URL = "https://toddberliner.us/api/api/syncdata.json"
//let DELETE_LIST_URL = "https://toddberliner.us/api/api/deletelist.json"
//let GET_SERVER_PEOPLE_URL = "https://toddberliner.us/api/api/getserverpeople.json"
//let DEVICE_LOG_URL = "https://toddberliner.us/api/api/logfromdevice.json"
//let LOCATION_ALERT_URL = "https://toddberliner.us/api/api/recordlocalistalert.json"


// Logs
let localistLog = OSLog(subsystem: "toddberliner.LocalistMVP", category: "localist-log")
