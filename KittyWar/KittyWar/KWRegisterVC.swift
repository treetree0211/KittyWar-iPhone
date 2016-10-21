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
        
        // create body string
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let bodyString = String(format: RequestFormatString.register,
                                username, password, email)
        
        // create url request
        var request = URLRequest(url: URL(string: RequestURLString.register)!)
        request.httpMethod = "POST"
        request.httpBody = bodyString.data(using: .utf8)
        
        // start the session
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // check error first
            if error != nil {
                self.showAlert(title: "Request Error",
                               message: error!.localizedDescription)
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    
                    if let status = parsedData[ResponseKey.status] as? Int {
                        switch status  {
                        case StatusCode.usernameIsTaken:
                            self.showAlert(title: "Register Error",
                                           message: "Username is taken")
                        case StatusCode.registerSuccess:
                            self.showAlert(title: "Register Success",
                                           message: "Register Success")
                        default:
                            self.showAlert(title: "Register error",
                                           message: "")
                        }
                    }
                } catch let error as NSError {
                    self.showAlert(title: "Parsing Error",
                                   message: error.localizedDescription)
                }
            }
        }.resume()
    }
}
