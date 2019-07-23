//
//  RoundBadge.swift
//  Localist
//
//  Created by Todd Berliner on 1/9/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit

@IBDesignable

class RoundBadge: UIView {

    override func prepareForInterfaceBuilder() {
        customizeView()
    }
    
    override func awakeFromNib() {
        customizeView()
    }
    
    func customizeView() {
        super.awakeFromNib()
        layer.cornerRadius = 15
        layer.frame.size.width = 40
        layer.frame.size.height = 40
        layer.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }

}
