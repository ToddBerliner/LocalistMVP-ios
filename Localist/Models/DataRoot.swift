//
//  DataRoot.swift
//  Localist
//
//  Created by Todd Berliner on 11/9/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import Foundation

struct DataRoot: Codable {

    var User: Person?
    var People: [Person]
    var Lists: [List]
    
    init(user: Person? = nil, people: [Person], lists: [List]) {
        self.Lists = lists
        self.User = user
        self.People = people
    }
    
    mutating func removeList(itemIndex: Int) {
        Lists.remove(at: itemIndex)
    }
    
    mutating func addList(list: List) {
        Lists.append(list)
    }
}

struct DataRootFromServer: Codable {
    var data: DataRoot
    init(data: DataRoot) {
        self.data = data
    }
}
