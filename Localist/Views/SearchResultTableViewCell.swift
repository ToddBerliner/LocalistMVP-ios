//
//  SearchResultTableViewCell.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 1/24/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    
    
    func updateViews(location: Location!) {
        name.text = location.name
        address.text = location.address
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected
            ? UITableViewCell.AccessoryType.checkmark
            : UITableViewCell.AccessoryType.none
    }

}
