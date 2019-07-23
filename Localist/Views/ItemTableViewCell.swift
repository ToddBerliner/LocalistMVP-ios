//
//  ItemTableViewCell.swift
//  Localist
//
//  Created by Todd Berliner on 10/25/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var markButton: MarkItemButton!
    
    func updateViews(item: Item, itemIndex: Int) {
        title.text = item.title
        markButton.itemIndex = itemIndex
    }

}
