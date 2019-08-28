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
    
    func updateViews(item: Item, indexPath: IndexPath) {
        title.text = item.title
        markButton.indexPath = indexPath
        
        if (item.marked != nil) {
            let attributedTitle: NSMutableAttributedString =  NSMutableAttributedString(string: item.title)
            attributedTitle.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributedTitle.length))
            title.attributedText = attributedTitle
            markButton.setImage(UIImage.init(named: "Task Checked"), for: .normal)
        } else {
            let attributedTitle: NSMutableAttributedString =  NSMutableAttributedString(string: item.title)
            attributedTitle.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, attributedTitle.length))
            title.attributedText = attributedTitle
            markButton.setImage(UIImage.init(named: "Task"), for: .normal)
        }
    }

}
