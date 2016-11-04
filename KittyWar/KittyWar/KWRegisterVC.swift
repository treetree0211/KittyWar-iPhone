//
//  KWRegisterVC.swift
//  KittyWar
//
//  Created by Hejia Su on 10/17/16.
//  Copyright © 2016 DeiSu. All rights reserved.
//

import UIKit

class KWRegisterVC: UIViewController {
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var reenterEmailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private lazy var alertController = { () -> UIAlertController in
        let alertController = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        return alertController
    }()
    
    private func showAlert(title: String, message: String) {
        alertController.title = title
        alertController.message = message
        present(alertController, animated: true, completion: nil)
    }
    
    // check whether the two passwords are the same
    private func twoEmailsAreSame() -> Bool {
        return emailTextField.text == reenterEmailTextField.text
    }
    
    @IBAction func register(_ sender: UIButton) {
        if !twoEmailsAreSame() {
            showAlert(title: "Email Error", message: "Two emails don't match")
            return
        }
        
        // register to notification center
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(KWRegisterVC.handleRegisterResult(notification:)),
                       name: registerResultNotification,
                       object: nil)
        
        // let network singleton register
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let email = emailTextField.text ?? ""
        KWNetwork.shared.register(username: username, email: email, password: password)
    }
    
    func handleRegisterResult(notification: Notification) {
        if let result = notification.userInfo?[InfoKey.result] as? RegisterResult {
            switch result {
            case .usernameIsTaken:
                self.showAlert(title: "Register Error",
                               message: "Username is taken")
            case .success:
                self.showAlert(title: "Register Success",
                               message: "Register Success")
            case .fail:
                self.showAlert(title: "Register Error",
                               message: "Registore Error")
            }
        }
    }
    
}
