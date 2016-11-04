//
//  KWAlertVC.swift
//  KittyWar
//
//  Created by Hejia Su on 11/3/16.
//  Copyright © 2016 DeiSu. All rights reserved.
//

import UIKit

class KWAlertVC: UIViewController {
    
    lazy var alertController = { () -> UIAlertController in
        let alertController = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        return alertController
    }()
    
    func showAlert(title: String, message: String) {
        alertController.title = title
        alertController.message = message
        present(alertController, animated: true, completion: nil)
    }

}
