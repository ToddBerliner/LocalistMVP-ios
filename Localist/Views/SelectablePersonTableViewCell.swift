//
//  SelectablePersonTableViewCell.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 1/18/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit

class SelectablePersonTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    
    func updateViews(nameText: String?, avatarName: String?) {
        name.text = nameText
        avatar.image = UIImage (named: avatarName ?? "Contact")
        self.accessoryType = UITableViewCell.AccessoryType.checkmark
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected
            ? UITableViewCell.AccessoryType.checkmark
            : UITableViewCell.AccessoryType.none
    }

}
