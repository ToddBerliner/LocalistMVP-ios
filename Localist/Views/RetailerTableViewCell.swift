//
//  RetailerTableViewCell.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 1/21/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit

class RetailLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var locationCount: UILabel!
    
    func updateViews(location: Location?, isLast: Bool) {
        
        if isLast {
            name.text = "Add Retail Locations"
            name.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            logo.image = UIImage (named: "Add")
            locationCount.text = ""
        } else {
            name.text = location?.name
            name.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            logo.image = nil
            locationCount.text = location?.address
        }
        
    }

}
