//
//  ListTitleInputRow.swift
//  Localist
//
//  Created by Todd Berliner on 1/14/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit

@IBDesignable

class ListTitleInputRow: UIView {

    override func draw(_ rect: CGRect) {
        
        // Add bottom border
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: self.frame.size.height-0.5, width: self.frame.width, height: 0.5)
        bottomBorder.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        self.layer.addSublayer(bottomBorder)
    }

}
