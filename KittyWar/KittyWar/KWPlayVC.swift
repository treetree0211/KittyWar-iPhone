//
//  KWPlayVC.swift
//  KittyWar
//
//  Created by Hejia Su on 10/17/16.
//  Copyright © 2016 DeiSu. All rights reserved.
//

import UIKit

class KWPlayVC: UIViewController {

    @IBOutlet weak var findGameIndicator: UIActivityIndicatorView!
    
    @IBAction func findGame(_ sender: UIButton) {
        // register to notification center
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(KWPlayVC.handleFindGameResult(notification:)),
                       name: findGameResultNotification,
                       object: nil)
        
        // find game
        KWNetwork.shared.findGame(token: KWUserDefaults.getToken())
    }
    
    func handleFindGameResult(notification: Notification) {
        
    }
    
}
