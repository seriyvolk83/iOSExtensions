//
//  UserInfo.swift
//  dodo
//
//  Created by Volkov Alexander on 17.02.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import Foundation

/**
 * Class for storing info from "Sign Up" form
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
class UserInfo {
    
    /// the ID of the user account
    var id: String
    
    /// the user's first name
    let firstName: String
    
    /// the user's last name
    let lastName: String
    
    /// the account username
    let username: String
    
    /// the password
    var password: String
    
    /**
     Initializer
     
     - parameter id:        the ID
     - parameter firstName: the first name
     - parameter lastName:  the last name
     - parameter username:  the username
     - parameter password:  the password
     
     - returns: new instance
     */
    init(id: String, firstName: String, lastName: String, username: String, password: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.password = password
    }
    
    /**
     Parse JSON into UserInfo
     
     - parameter json: JSON object
     
     - returns: UserInfo
     */
    class func fromJson(json: JSON) -> UserInfo {
        let info = UserInfo(
            id: json["id"].stringValue,
            firstName: json["firstName"].stringValue,
            lastName: json["lastName"].stringValue,
            username: json["username"].stringValue,
            password: json["password"].stringValue)
        return info
    }
    
    /**
     Convert UserInfo to JSON object
     
     - returns: JSON object
     */
    func toJson() -> JSON {
        let dic: NSDictionary = [
            "id": self.id,
            "firstName": self.firstName,
            "lastName": self.lastName,
            "username": self.username,
            "password": self.password
        ]
        return JSON(dic)
    }
}
