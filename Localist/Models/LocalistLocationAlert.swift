//
//  DeviceLogMessage.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 7/19/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import Foundation

struct LocalistLocationAlert: Codable {
    var userId: Int
    var localistId: Int
    var action: String
    init(userId: Int = 0, localistId: Int, action: String) {
        self.userId = userId
        self.localistId = localistId
        self.action = action
    }
}
