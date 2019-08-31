//
//  ListTableViewHeaderView.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 8/30/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit

class ListTableViewHeaderView: UITableViewHeaderFooterView {

    static let reuseIdentifier: String = String(describing: self)
    
    var showHideButton: UIButton
    
    override init(reuseIdentifier: String?) {
        self.showHideButton = UIButton()
        super.init(reuseIdentifier: reuseIdentifier)
        
        showHideButton = UIButton()
        contentView.addSubview(showHideButton)
        showHideButton.translatesAutoresizingMaskIntoConstraints = false
        showHideButton.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        showHideButton.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        showHideButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        showHideButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.showHideButton = UIButton()
        super.init(coder: aDecoder)
    }

}
