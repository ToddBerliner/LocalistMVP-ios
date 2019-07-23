//
//  SelectableAddressTableViewCell.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 2/20/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit
import MapKit

class SelectableAddressTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    
    
    func updateViews(mapItem: MKMapItem) {
        name.text = mapItem.name
        address.text = mapItem.placemark.shortAddress
        self.accessoryType = UITableViewCell.AccessoryType.checkmark
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.accessoryType = selected
            ? UITableViewCell.AccessoryType.checkmark
            : UITableViewCell.AccessoryType.none
    }

}
