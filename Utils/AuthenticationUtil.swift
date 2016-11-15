//
//  AuthenticationUtil.swift
//  dodo
//
//  Created by Alexander Volkov on 05.10.15.
//  Copyright © 2015 seriyvolk83dodo. All rights reserved.
//

import Foundation

/// the constants used to store profile data
let kProfileUsername = "kProfileUsername"

/**
* Utility for storing and getting current user profile data.
*
* @author TCASSEMBLER
* @version 1.0
*/
class AuthenticationUtil {
    
    /// username
    var username: String? {
        get {
            return getValueByKey(kProfileUsername)
        }
        set {
            saveValueForKey(newValue, key: kProfileUsername)
        }
    }
    
    /// the user info
    var userInfo: UserInfo? {
        didSet {
            if let userInfo = userInfo {
                userInfo.toJson().saveFile(kAuthenticatedUserInfo)
            }
            else {
                FileUtil.removeFile(kAuthenticatedUserInfo)
            }
        }
    }
    
    /// the singleton
    class var sharedInstance: AuthenticationUtil {
        struct Singleton { static let instance = AuthenticationUtil() }
        return Singleton.instance
    }
    
    /**
     dodo is this method required?
    Store profile data
    
    - parameter profile: the data
    */
    func storeProfile(profile: JSON) {
        username = profile["name"].stringValue
    }
    
    /**
    Clean up any stored user information
    */
    func cleanUp() {
        username = nil
    }
        
    /**
    Get value by key
    
    - parameter key: the key
    
    - returns: the value
    */
    private func getValueByKey(key: String) -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(key)
    }
    
    /**
    Save value to local preferences
    
    - parameter value: the value to save
    - parameter key:   the key
    */
    private func saveValueForKey(value: String?, key: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(value, forKey: key)
        defaults.synchronize()
    }
}
