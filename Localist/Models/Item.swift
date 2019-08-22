//
//  Item.swift
//  Localist
//
//  Created by Todd Berliner on 10/25/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import Foundation

struct Item: Codable {
    var title: String
    init(title: String) {
        self.title = title
    }
    mutating func updateTitle(title: String) {
        self.title = title
    }
}
