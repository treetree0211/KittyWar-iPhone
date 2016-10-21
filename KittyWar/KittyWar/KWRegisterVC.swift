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
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    
    // check whether the two passwords are the same
    private func passwordAndConfirmedPasswordAreSame() -> Bool {
        return passwordTextField.text == confirmPasswordTextField.text
    }
    
    @IBAction func register(_ sender: UIButton) {
        if !passwordAndConfirmedPasswordAreSame() {
            print("Two passwords are not the same!")
            return
        }
        
        // create body string
        let bodyString = String(format: RequestFormatString.register,
                                usernameTextField.text!,
                                passwordTextField.text!,
                                emailTextField.text!)
        
        // create url request
        var request = URLRequest(url: URL(string: RequestURLString.register)!)
        request.httpMethod = "POST"
        request.httpBody = bodyString.data(using: .utf8)
        
        // start the session
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // check error first
            if error != nil {
                print("Request error: \(error)")
            } else {
                // check status code
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case StatusCode.usernameIsTaken:
                        print("Username is taken")
                    case StatusCode.registerSuccess:
                        print("Register success")
                        // save username and password locally
                        
                        // connect to the server through a socket
                    default:
                        print("Register error")
                    }
                }
            }
        }.resume()
    }
    
}
