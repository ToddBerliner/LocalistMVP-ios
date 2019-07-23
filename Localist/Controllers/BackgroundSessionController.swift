//
//  BackgroundSessionController.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 7/14/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit

class BackgroundSessionController: NSObject {
    
    // Download session
    private lazy var bgSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "toddberliner.LocalistMVP")
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func syncDataWithServerInBackground() {
        print("   >>> BG Task Start")
        guard let encodedData = DataService.instance.getEncodedData() else { return }
        let request = ArchiveService.instance.getRequest()!
        let syncTask = bgSession.uploadTask(with: request, from: encodedData)
        syncTask.resume()
    }

}

extension BackgroundSessionController: URLSessionDataDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print(" --> complete! Calling completionHandler <---")
        // TODO: something on the main queue?
    }
}
