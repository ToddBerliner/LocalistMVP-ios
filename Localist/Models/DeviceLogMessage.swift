//
//  DeviceLogMessage.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 7/19/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import Foundation

struct DeviceLogMessage: Codable {
    var userId: Int
    var message: String
    var error: String
    init(userId: Int = 0, message: String, error: String = "") {
        self.userId = userId
        self.message = message
        self.error = error
    }
}
