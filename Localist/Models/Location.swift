//
//  Location.swift
//  Localist
//
//  Created by Todd Berliner on 11/2/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import Foundation

struct Location: Codable {
    var name: String
    var address: String
    var imageName: String
    var latitude: Double
    var longitude: Double
    var radius: Double
    var identifier: String
    
    init(name: String, address: String, imageName: String, latitude: Double, longitude: Double, radius: Double, identifier: String) {
        self.name = name
        self.address = address
        self.imageName = imageName
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.identifier = identifier
    }
}
