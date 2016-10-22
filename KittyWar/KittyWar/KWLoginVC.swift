//
//  KWLoginVC.swift
//  KittyWar
//
//  Created by Hejia Su on 10/17/16.
//  Copyright © 2016 DeiSu. All rights reserved.
//

import UIKit
import Starscream

class KWLoginVC: UIViewController {

    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBAction func login(_ sender: UIButton) {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        // register to notification center
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(KWLoginVC.handleLoginResult(notification:)),
                       name: loginResultNotification,
                       object: nil)
        
        // login
        KWNetwork.shared.login(username: username, password: password)
    }
    
    func handleLoginResult(notification: Notification) {
        if let result = notification.userInfo?[InfoKey.result] as? LoginResult {
            switch result {
            case .success:
                break
            case .error:
                break
            }
        }
    }
    
}
