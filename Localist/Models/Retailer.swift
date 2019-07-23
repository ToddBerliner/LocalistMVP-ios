//
//  Location.swift
//  Localist
//
//  Created by Todd Berliner on 11/2/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import Foundation

struct Retailer: Codable {
    var name: String
    var logoImageName: String
    var locations: [Location]
    
    init(name: String, imageName: String, selectedLocations: [Location]) {
        self.name = name
        self.logoImageName = imageName
        self.locations = selectedLocations
    }
    
    mutating func addLocation(location: Location) {
        self.locations.append(location)
    }
    
    mutating func clearLocations() {
        self.locations = []
    }
    
}
