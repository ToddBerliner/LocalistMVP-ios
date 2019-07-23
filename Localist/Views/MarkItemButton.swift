//
//  MarkItemButton.swift
//  Localist
//
//  Created by Todd Berliner on 11/1/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import UIKit

@IBDesignable

class MarkItemButton: UIButton {
    
    var itemIndex: Int = 0

    override func prepareForInterfaceBuilder() {
        customizeView()
    }
    
    override func awakeFromNib() {
        customizeView()
    }
    
    func customizeView() {
        super.awakeFromNib()
        layer.cornerRadius = 12.5
        layer.frame.size.width = 25
        layer.frame.size.height = 25
        layer.borderWidth = 2
        layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }

}
