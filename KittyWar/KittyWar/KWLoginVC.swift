//
//  KWLoginVC.swift
//  KittyWar
//
//  Created by Hejia Su on 10/17/16.
//  Copyright © 2016 DeiSu. All rights reserved.
//

import UIKit
import SocketIO

class KWLoginVC: UIViewController {

    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBAction func login(_ sender: UIButton) {
        // create login string
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let loginString = String(format: RequestFormatString.login,
                                username, password)
        
        // connect to server via socket
        let socket = SocketIOClient(socketURL: URL(string: RequestURLString.login)!)
        socket.on(loginString) { (data, ask) in
            // save username and password if success
            if (true) {
                let defaults = UserDefaults.standard
                defaults.set(username, forKey: "username")
                defaults.set(password, forKey: "password")
                defaults.set(true, forKey: "login")
            }
        }
        socket.connect()
    }
    
}
