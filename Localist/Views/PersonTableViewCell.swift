//
//  PersonTableViewCell.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 1/15/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    func updateViews(nameText: String?, avatarName: String?, isLast: Bool) {
        
        if isLast {
            name.text = "Add People"
            name.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            avatar.image = UIImage (named: "Add")
        } else {
            name.text = nameText
            name.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            avatar.image = UIImage (named: avatarName ?? "Contact")
        }
        
    }

}
