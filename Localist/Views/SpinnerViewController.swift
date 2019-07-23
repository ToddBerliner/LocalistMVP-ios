//
//  SpinnerViewController.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 7/6/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit

class SpinnerViewController: UIViewController {

    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

}
