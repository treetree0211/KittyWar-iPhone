//
//  KWPlayVC.swift
//  KittyWar
//
//  Created by Hejia Su on 10/17/16.
//  Copyright © 2016 DeiSu. All rights reserved.
//

import UIKit

class KWPlayVC: UIViewController {

    @IBOutlet weak var findMatchIndicator: UIActivityIndicatorView!
    
    @IBAction func findMatch(_ sender: UIButton) {
        // register to notification center
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(KWPlayVC.handleFindMatchResult(notification:)),
                       name: findGameResultNotification,
                       object: nil)
        
        // find match indicator start animation
        findMatchIndicator.startAnimating()
        
        // find game
        KWNetwork.shared.findMatch(token: KWUserDefaults.getToken())
    }
    
    func handleFindMatchResult(notification: Notification) {
        
    }
    
}
