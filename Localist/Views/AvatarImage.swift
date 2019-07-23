//
//  AvatarImage.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 1/15/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit

@IBDesignable

class AvatarImage: UIImageView {

    override func prepareForInterfaceBuilder() {
        customizeView()
    }
    
    override func awakeFromNib() {
        customizeView()
    }
    
    func customizeView() {
        super.awakeFromNib()
        layer.cornerRadius = layer.frame.size.width/2
    }
    
    func setImage(imageName: String) {
        self.image = UIImage (named: imageName)
    }

}
