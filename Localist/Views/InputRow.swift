//
//  InputRow.swift
//  Localist
//
//  Created by Todd Berliner on 10/30/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import UIKit

@IBDesignable

class InputRow: UIView {

    override func draw(_ rect: CGRect) {
        let border = UIView()
        border.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        border.frame = CGRect(x: 0, y: rect.height, width: rect.width, height: 0.5)
        self.addSubview(border)
    }

}
