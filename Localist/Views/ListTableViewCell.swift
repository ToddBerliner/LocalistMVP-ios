//
//  ListTableViewCell.swift
//  Localist
//
//  Created by Todd Berliner on 10/25/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var itemCount: UILabel!
    @IBOutlet weak var retailerList: UILabel!
    @IBOutlet weak var sharedFlag: UILabel!
    
    func updateViews(list: List) {
        title.text = list.title
        itemCount.text = String(list.items.count)
        retailerList.text = buildRetailerString(list: list)
        if list.members.count == 1 {
            sharedFlag.isHidden = true
        } else {
            sharedFlag.isHidden = false
        }
    }
    
    func buildRetailerString(list: List) -> String {
        var retailersString = ""
        var retailerStrings = Set<String>()
        for retailer in list.retailers {
            if (retailer.locations.count > 0) {
                retailerStrings.insert(retailer.name)
            }
        }
        switch retailerStrings.count {
        case 0:
            retailersString = "No retailers selected"
        case 1:
            retailersString = retailerStrings.popFirst()!
        case 2:
            retailersString = "\(retailerStrings.popFirst()!) and \(retailerStrings.popFirst()!)"
        default:
            let andMoreRetailersCount = retailerStrings.count - 2
            retailersString = "\(retailerStrings.popFirst()!), \(retailerStrings.popFirst()!), and \(andMoreRetailersCount) more"
        }
        return retailersString
    }

}
