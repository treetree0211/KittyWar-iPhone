//
//  KWRequest.swift
//  KittyWar
//
//  Created by Hejia Su on 10/19/16.
//  Copyright © 2016 DeiSu. All rights reserved.
//

import UIKit

enum RequestMethod {
    case post
}

class KWRequest: NSObject {
    
    // generic request method returns an optional dictionary which contains
    // the json response from the server
    private static func executeRequest(requestURL: NSURL,
                                       requestMethod: RequestMethod,
                                       requestBodu: String) -> [String:AnyObject]? {
        return nil
    }
    
    static func registerNewAccount(username: String,
                                   password: String,
                                   email: String) -> Void {
        
    }
    
}
