//
//  Item.swift
//  Localist
//
//  Created by Todd Berliner on 10/25/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import Foundation

struct Person: Codable, Equatable {
    
    var id: Int?
    var udid: String?
    var apns: String?
    var name: String
    var first_name: String
    var image_name: String
    var phone: String
    
    init(id: Int? = nil, udid: String? = nil, apns: String? = nil, name: String, first_name: String, imageName: String, phone: String) {
        self.id = id
        self.udid = udid
        self.apns = apns
        self.name = name
        self.first_name = first_name
        self.image_name = imageName
        self.phone = phone
    }
    
    mutating func setApns(token: String) {
        self.apns = token
    }
}

struct PeopleFromServer: Codable {
    var people: [Person]
    init(people: [Person]) {
        self.people = people
    }
}
