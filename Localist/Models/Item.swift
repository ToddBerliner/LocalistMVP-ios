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
    var marked: Double?
    init(title: String) {
        self.title = title
        self.marked = nil
    }
    mutating func updateTitle(title: String) {
        self.title = title
    }
    mutating func setMarked(marked: Bool) {
        if (marked) {
            self.marked = Date().timeIntervalSince1970
        } else {
            self.marked = nil
        }
    }
}
