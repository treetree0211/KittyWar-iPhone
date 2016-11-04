//
//  KWLoginVC.swift
//  KittyWar
//
//  Created by Hejia Su on 10/17/16.
//  Copyright © 2016 DeiSu. All rights reserved.
//

import UIKit
import Starscream

class KWLoginVC: KWAlertVC {

    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private struct StoryBoard {
        static let segueToGameTabBarController = "loginToGameTabBarController"
    }
    
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
                // alert success
                showAlert(title: "Login Success",
                          message: "Register Success")
                
                // save token locally
                UserDefaults.standard.set(notification.userInfo?[InfoKey.token] as! String,
                                          forKey: KWUserDefaultsKey.token)
                
                // segue to game play tab bar controller
                performSegue(withIdentifier: StoryBoard.segueToGameTabBarController, sender: self)
                break
            case .fail:
                // alert fail
                showAlert(title: "Login Fail",
                          message: "Username or password is wrong")
                break
            }
        }
    }
    
}
