//
//  Persistence.swift
//  dodo
//
//  Created by TCASSEMBLER on 31.01.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import UIKit
import CoreData

/**
* Class helps to remove a direct reference to AppDelegate context
*
* @author TCASSEMBLER
* @version 1.0
*/
public class Persistence {
    
    /**
     Public initializer
     
     - returns: new instance
     */
    public init() {
    }
    
    /// Represents the context property.
    public let context: NSManagedObjectContext = AppDelegate.sharedInstance.managedObjectContext
    
}

/**
 * Utility class to store NSManagedObjectContext reference
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
public class PersistenceStack { 
    
    /// Represents the model name property.
    public let modelName: String
    
    /// Represents the context property.
    public let context: NSManagedObjectContext
    
    /**
     Initialize new instance with model name and concurrency type.
     
     - parameter modelName: the model name parameter.
     
     - returns: The new created instance.
     */
    public init(modelName: String) {
        self.modelName = modelName;
        self.context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        
        let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent(modelName + ".sqlite")
        let modelURL = NSBundle.mainBundle().URLForResource(modelName, withExtension: "momd")!
        
        let model = NSManagedObjectModel(contentsOfURL: modelURL)!
        self.context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        var error: NSError?
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            try self.context.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil
                , URL: storeURL, options: options)
        } catch let error1 as NSError {
            error = error1
        }
        if let error = error {
            NSLog("Fatal error occurred while creating persistence stack: \(error)")
        }
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.appirio.mobile.Interlochen_Media" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
}
