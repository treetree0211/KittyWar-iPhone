//
//  KWRequest.swift
//  KittyWar
//
//  Created by Hejia Su on 10/20/16.
//  Copyright © 2016 DeiSu. All rights reserved.
//

struct RequestURLString {
    static let register = "http://www.brucedsu.com/kittywar/register/mobile/"
}

struct RequestFormatString {
    static let register = "username=%s&password=%s&email=%s"
}

struct StatusCode {
    static let usernameIsTaken = 409
    static let registerSuccess = 201
}

struct ResponseKey {
    static let status = "status"
}
