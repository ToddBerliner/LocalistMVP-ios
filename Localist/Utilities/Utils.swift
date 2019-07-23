//
//  Utils.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 6/5/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import Foundation
import MapKit
import os

func extractRetailLocationFromLocation(location: MKMapItem) -> Location {
    
    let region = location.placemark.region as! CLCircularRegion
    
    // name
    let name = location.name ?? ""
    // address
    let address = "\(location.placemark.postalAddress?.street ?? ""), \(location.placemark.postalAddress?.city ?? "")"
    // latitude
    let latitude = location.placemark.coordinate.latitude
    // longitude
    let longitude = location.placemark.coordinate.longitude
    // radius
    let radius = region.radius > 150 ? 300 : region.radius
    // identifier
    let identifier = "\(name)-\(address)"
    let retailLocation = Location(name: name, address: address, imageName: "", latitude: latitude, longitude: longitude, radius: Double(radius), identifier: identifier)
    return retailLocation
}

func showActivity() -> SpinnerViewController? {
    
    let spinner = SpinnerViewController()
    
    let appDelegate = UIApplication.shared.delegate
    guard let window = appDelegate?.window else {
        return nil
    }
    if let navigationController = window?.rootViewController as? UINavigationController {
        
        if let activeViewController = navigationController.topViewController as? ListsViewController {
            activeViewController.addChild(spinner)
            spinner.view.frame = activeViewController.view.frame
            activeViewController.view.addSubview(spinner.view)
            spinner.didMove(toParent: activeViewController)
        }
        if let activeViewController = navigationController.topViewController as? ListViewController {
            activeViewController.addChild(spinner)
            spinner.view.frame = activeViewController.view.frame
            activeViewController.view.addSubview(spinner.view)
            spinner.didMove(toParent: activeViewController)
        }
    }
    return spinner
}

func hideActivity(spinnerView: SpinnerViewController) {
    spinnerView.willMove(toParent: nil)
    spinnerView.view.removeFromSuperview()
    spinnerView.removeFromParent()
}

func logError(message: String = "", error: String = "") {
    
    // create request
    let url = URL(string: DEVICE_LOG_URL)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // create data
    let user = DataService.instance.getUser()
    let userId = (user == nil) ? 0 : user!.id
    let deviceLogMessage = DeviceLogMessage(userId: userId!, message: message, error: error)
    do {
        let encodedData = try JSONEncoder().encode(deviceLogMessage)
        URLSession.shared.uploadTask(with: request, from: encodedData).resume()
    } catch let error {
        print("!!! Error encoding deviceLogMessage: \(error)")
    }
}
