//
//  UserInfoService.swift
//  dodo
//
//  Created by TCASSEMBLER on 31.01.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import Foundation
import CoreData

/**
 * Service for storing UserInfo in Core Data
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
public class UserInfoService: DataService {
    
    /**
     Get all objects
     
     - parameter success: the success callback
     - parameter failure: the failure callback to invoke when an error occurred
     */
    public func getUserInfo(success: ([UserInfo]) -> (), failure: GeneralFailureBlock) {
        
        // create the request
        let fetchRequest = NSFetchRequest(entityName: UserInfoManagedObject.entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        // execute the fetch
        executeFetch(fetchRequest, transform: { (managed: UserInfoManagedObject) -> UserInfo in
            return UserInfo(managed: managed)
        }, success: success, failure: failure)
        
    }
    
    /**
     Insert a new object
     
     - parameter userInfo: the user info
     - parameter success:  the success callback
     - parameter failure:  the failure callback to invoke when an error occurred
     */
    public func insertUserInfo(userInfo: UserInfo, success: ([UserInfo]) -> (), failure: GeneralFailureBlock) {
        
        // transform
        let transform = { (item: UserInfo, managed: UserInfoManagedObject) -> () in
            
            managed.fillDataFrom(item)
        }
        // insertion
        self.insertObjects([userInfo], transform: transform, success: success, failure: failure)
    }
}
