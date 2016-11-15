//
//  UserInfo.swift
//  dodo
//
//  Created by TCASSEMBLER on 31.01.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

/**
 * Model object for user info
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
public class UserInfo: CoreDataEntityBridge {
    
    /// json data
    public let json: JSON
    
    // The ObjectID of the CoreData object we saved to or loaded from
    public var managedObjectID: NSManagedObjectID?
    
    /// the date of data retrieval
    public var retrievalDate: NSDate = NSDate()
    
    /// the name
    public var name = ""
    
    /// the related link
    public let link: NSURL?
    
    /// the location of the user
    public var location = ""
    
    /// biography
    public var bio = ""
    
    /// list of pictures
    public let pictures: Pictures
    
    /// list of websites
    public var websites = [Website]()
    
    /// metadata
    public let metadata: JSON!
    
    /**
     Instantiate UserInfo from JSON
     
     - parameter json: the JSON object
     
     - returns: new instance
     */
    public init(json: JSON) {
        self.json = json
        
        name = json["name"].stringValue
        link = NSURL(string: json["link"].stringValue)
        location = json["location"].stringValue
        bio = json["bio"].stringValue
        pictures = Pictures.fromJson(json["pictures"])
        for websiteJson in json["websites"].arrayValue {
            if let website = Website.fromJson(websiteJson) {
                websites.append(website)
            }
        }
        metadata = json["metadata"]
    }
    
    /**
     Initialize new instance with managed object
     
     - parameter managed: the managed object
     
     - returns: the new created instance
     */
    convenience init(managed: UserInfoManagedObject) {
        self.init(json: JSON(data: managed.jsonData))
        self.retrievalDate = managed.retrievalDate
        self.managedObjectID = managed.objectID
    }
    
}

/**
 * Core Data model object for UserInfo
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
public class UserInfoManagedObject: NSManagedObject, CoreDataEntity {
    
    /// json data
    @NSManaged var jsonData: NSData
    
    /// the date of data retrieval
    @NSManaged var retrievalDate: NSDate

    // MARK: CoreDataEntity
    
    /// Represents the entity name static property.
    public class var entityName : String {
        return "UserInfoManagedObject"
    }
    
    /**
     Fill data from model object.
     
     - parameter object: the value object
     */
    public func fillDataFrom(object: UserInfo) {
        do {
            let data: NSData = try object.json.rawData()
            self.jsonData = data
        }
        catch {
            print("ERROR: Cannot obtain JSON data")
        }
        self.retrievalDate = object.retrievalDate
    }
}
