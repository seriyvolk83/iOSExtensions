//
//  DataService.swift
//  dodo
//
//  Created by TCASSEMBLER on 31.01.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import Foundation
import CoreData

/// Represents the model name.
private let ModelName = "dodo"

/// queue for fetching data
private let cacheQueue : dispatch_queue_t = dispatch_queue_create("cacheQueue", DISPATCH_QUEUE_SERIAL)

/// Represents the data service error domain.
public let DataServiceErrorDomain = "DataServiceErrorDomain"

/**
* Represents the core data entity protocol
*
* @author TCASSEMBLER
* @version 1.0
*/
protocol CoreDataEntity : class {
    
    /// Represents the static entity name property.
    static var entityName: String { get }
}

/**
* Represents the core data entity bridge protocol.
*
* @author TCASSEMBLER
* @version 1.0
*/
public protocol CoreDataEntityBridge {
    
    // The ObjectID of the CoreData object we saved to or loaded from
    var managedObjectID: NSManagedObjectID? { get set }
    
    /// the date of data retrieval
    var retrievalDate: NSDate { get set }
}

/// Represents the data service failure closure type.
public typealias GeneralFailureBlock = (NSError) -> Void

/**
Represents the search compound operator enumeration.

- And: The and parameter.
- Or:  The or parameter.

@author TCASSEMBLER
@version 1.0
*/
public enum SearchCompoundOperator {
    case And
    case Or
    
    /**
    Compound predicate type.
    
    - returns: The compound predicate type.
    */
    func compoundPredicateType() -> NSCompoundPredicateType {
        switch self {
        case .And:
            return NSCompoundPredicateType.AndPredicateType
        case .Or:
            return NSCompoundPredicateType.OrPredicateType
        }
    }
}

/**
Represents the sort direction enumeration.

- Ascending:  The ascending parameter.
- Descending: The descending parameter.

@author TCASSEMBLER
@version 1.0
*/
public enum SortDirection {
    
    case Ascending
    case Descending
    
    /// Whether or the instance represents an ascending or descending direction.
    var isAscending: Bool {
        return self == .Ascending
    }
}

/**
* Represents the data service class. This is the base class for all core data related classes.
*
* @author TCASSEMBLER
* @version 1.0
*/
public class DataService {
    
    /// pepresents the stack property
    let persistence = Persistence()
    
    /**
    Initialize new instance.
    
    - returns: The new created instance.
    */
    public init() {
        // does nothing
    }
    
    // MARK:- Fetch
    
    /**
    Executes a fetch request with transform, success and failure parameters.
    
    - parameter fetchRequest: The fetch request parameter.
    - parameter transform:    The transform parameter.
    - parameter success:      The success parameter.
    - parameter failure:      The failure parameter.
    */
    func executeFetch<M : NSManagedObject, E>(fetchRequest: NSFetchRequest,
        transform: M ->  E, success: [E] -> (), failure: GeneralFailureBlock) {
        
        dispatch_sync(cacheQueue) {
            var error: NSError?
            // get the data
            do {
                let items = try self.persistence.context.executeFetchRequest(fetchRequest)
                
                assert(items is [M], "Returned items should be an array of '\(M.self)' type.")
                // cast them
                let castedItems = items as! [M]
                
                // map them
                let mappedItems = castedItems.map(transform)
                
                self.executeOnMain {
                    // inform the user
                    success(mappedItems)
                }
                
            } catch let error1 as NSError {
                error = error1
                // failure in fetch
                let customError = NSError(error: error, dataServiceCode: 0,
                    message: "An error occurred while fetching '\(fetchRequest.entityName)'.")
                self.executeOnMain {
                    failure(customError)
                }
            } catch {
                fatalError()
            }
        }
    }
    
    /**
    Executes a fetch request with transform, success and failure parameters.
    
    - parameter fetchRequest: The fetch request parameter.
    - parameter transform:    The transform parameter.
    - parameter success:      The success parameter.
    - parameter failure:      The failure parameter.
    */
    func executeFetchOptional<M : NSManagedObject, E>(fetchRequest: NSFetchRequest,
        transform: M ->  E?, success: [E] -> (), failure: GeneralFailureBlock) {
        
        dispatch_sync(cacheQueue){
            var error: NSError?
            // get the data
            do {
                let items = try self.persistence.context.executeFetchRequest(fetchRequest)
                
                assert(items is [M], "Returned items should be an array of '\(M.self)' type.")
                // cast them
                let castedItems = items as! [M]
                
                // map them
                let mappedItemsOptional = castedItems.map(transform)
                
                let mappedItems = mappedItemsOptional.filter({$0 != nil}).map({$0!})
                
                self.executeOnMain {
                    // inform the user
                    success(mappedItems)
                }
                
            } catch let error1 as NSError {
                error = error1
                // failure in fetch
                let customError = NSError(error: error, dataServiceCode: 0,
                    message: "An error occurred while fetching '\(fetchRequest.entityName)'.")
                self.executeOnMain {
                    failure(customError)
                }
            } catch {
                fatalError()
            }
        }
    }
    
    // MARK:- Insertion
    
    /**
    Insert objects with transform, success and failure parameters.
    
    - parameter objects:   The objects parameter.
    - parameter transform: The transform parameter.
    - parameter success:   The success parameter.
    - parameter failure:   The failure parameter.
    */
    func insertObjects<M, E : CoreDataEntityBridge where M : CoreDataEntity, M : NSManagedObject>(objects: [E],
        transform: (E, M) ->  (), success: ([E]) -> (), failure: GeneralFailureBlock) {
        
        let creator = { (entity: E, context: NSManagedObjectContext) -> M in
            
            let managedItem: AnyObject = NSEntityDescription.insertNewObjectForEntityForName(M.entityName,
                inManagedObjectContext: context)
            assert(managedItem is M, "Created item should be of type '\(M.self)'")
            let castedManagedItem = managedItem as! M
            
            return castedManagedItem
        }
        
        insertObjects(objects, managedCreator: creator, transform: transform, success: success, failure: failure)
    }
    
    /**
    Core data entity bridge managed creator, transform, success and failure.
    
    - parameter objects:        The objects parameter.
    - parameter managedCreator: The managed creator parameter.
    - parameter transform:      The transform parameter.
    - parameter success:        The success parameter.
    - parameter failure:        The failure parameter.
    */
    func insertObjects<M : NSManagedObject, E : CoreDataEntityBridge >(
        objects: [E],
        managedCreator: (E, NSManagedObjectContext) -> M, transform: (E, M) ->  (),
        success: ([E]) -> (),
        failure: GeneralFailureBlock) {
            
            dispatch_sync(cacheQueue){
                    var insertedManaged = [M]()
                    // loop over the items and insert them to the context
                    for object in objects {
                        
                        // create new entity
                        let managedItem = managedCreator(object, self.persistence.context)
                        
                        // transform
                        transform(object, managedItem)
                        
                        insertedManaged.append(managedItem)
                    }
                    
                    // save
                    self.saveContext({ () -> () in
                        var insertedObjects = [E]()
                        for i in 0..<insertedManaged.count {
                            let managedItem = insertedManaged[i]
                            var item = objects[i]
                            
                            item.managedObjectID = managedItem.objectID
                            insertedObjects.append(item)
                        }
                        
                        success(insertedObjects)
                    }, failure: failure)
            }
    }
    
    // MARK:- Update
    
    /**
    Update objects with transform, success and failure parameters.
    
    - parameter objects:   The objects parameter.
    - parameter transform: The transform parameter.
    - parameter success:   The success parameter.
    - parameter failure:   The failure parameter.
    */
    func updateObjects<M : NSManagedObject, E : CoreDataEntityBridge>(objects: [E],
        transform: (E, M) ->  (), success: () -> (), failure: GeneralFailureBlock) {
        
        dispatch_sync(cacheQueue){
            // loop over the items and update them in the context
            for object in objects {
                if let objectID = object.managedObjectID {
                    // create new entity
                    let item = self.persistence.context.objectWithID(objectID);
                    assert(item is M, "Retrieved item should be of type '\(M.self)'")
                    let castedItem = item as! M
                    
                    // transform
                    transform(object, castedItem)
                    
                } else {
                    self.executeOnMain {
                        failure(NSError(error: nil, dataServiceCode: 0,
                            message: "Cannot save object with no ID. \(object)"))
                    }
                    return
                }
            }
            
            // save
            self.saveContext(success, failure: failure)
        }
    }
    
    // MARK:- Deletion
    
    /**
    Remove all instances with success and failure parameters.
    
    - parameter entityName: The entity name parameter.
    - parameter success:    The success parameter.
    - parameter failure:    The failure parameter.
    */
    public func removeAllInstances(entityName: String, success: () -> (), failure: GeneralFailureBlock) {
        removeInstancesOfRequest(NSFetchRequest(entityName: entityName), success: success, failure: failure)
    }
    
    /**
    Remove instances of request with success and failure parameters.
    
    - parameter request: The request parameter.
    - parameter success: The success parameter.
    - parameter failure: The failure parameter.
    */
    func removeInstancesOfRequest(request: NSFetchRequest, success: () -> (), failure: GeneralFailureBlock) {
        
        dispatch_sync(cacheQueue) {
            request.includesPropertyValues = false
            // get the data
            do {
                let items = try self.persistence.context.executeFetchRequest(request) as! [NSManagedObject]
                // delete the items
                for item in items {
                    self.persistence.context.deleteObject(item)
                }
                
                // save
                self.saveContext(success, failure: failure)
            } catch let error as NSError {
                // failure in fetch
                let customError = NSError(error: error, dataServiceCode: 0,
                    message: "An error occurred while fetching '\(request.entityName)'.")
                self.executeOnMain {
                    failure(customError)
                }
            }
        }
    }
    
    /**
    Remove instances with success and failure parameters.
    
    - parameter objects: The objects parameter.
    - parameter success: The success parameter.
    - parameter failure: The failure parameter.
    */
    func removeInstances<E : CoreDataEntityBridge>(objects: [E], success: () -> (), failure: GeneralFailureBlock) {
        
        dispatch_sync(cacheQueue) {
            // loop over the items and delete them in the context
            for object in objects {
                if let objectID = object.managedObjectID {
                    // create new entity
                    let managedItem = self.persistence.context.objectWithID(objectID);
                    self.persistence.context.deleteObject(managedItem)
                    
                } else {
                    self.executeOnMain {
                        failure(NSError(error: nil, dataServiceCode: 0,
                            message: "Cannot delete object with no ID. \(object)"))
                    }
                    return
                }
            }
            // save
            self.saveContext(success, failure: failure)
        }
    }
    
    // MARK:- Save Context
    
    /**
    Saves the managed object context with sucess and failure parameters.
    
    - parameter success: The success parameter.
    - parameter failure: The failure parameter.
    */
    func saveContext(success: () -> (), failure: GeneralFailureBlock) {
        // save
        do {
            try self.persistence.context.save()
            self.executeOnMain {
                // inform the user the operation succeeded
                success()
            }
        } catch let error as NSError {
            // failure in fetch
            let customError = NSError(error: error, dataServiceCode: 0,
                message: "An error occurred while saving the context.")
            self.executeOnMain {
                failure(customError)
            }
        }
    }
    
    /**
    Execute the block on the main thread.
    
    - parameter block: The block parameter.
    */
    func executeOnMain(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    /**
    Create string predicate with name and value.
    
    - parameter name:  The name parameter.
    - parameter value: The value parameter.
    
    - returns: The created predicate.
    */
    func createStringPredicate(name: String, value: String) -> NSPredicate {
        return NSPredicate(format: "%K contains[cd] %@", name, value)
    }
    
    /**
    Create integer predicate with name and value.
    
    - parameter name:  The name parameter.
    - parameter value: The value parameter.
    
    - returns: The created predicate.
    */
    func createIntPredicate(name: String, value: Int) -> NSPredicate {
        return NSPredicate(format: "%K == %d", name, value)
    }
    
    /**
    Create boolean predicate with name and value.
    
    - parameter name:  The name parameter.
    - parameter value: The value parameter.
    
    - returns: The created predicate.
    */
    func createBoolPredicate(name: String, value: Bool) -> NSPredicate {
        return NSPredicate(format: "%K == %d", name, value ? 1 : 0)
    }
    
    /**
    Create integer array predicate value.
    
    - parameter name:  The name parameter.
    - parameter value: The value parameter.
    
    - returns: The created predicate.
    */
    func createIntArrayPredicate(name: String, value: [Int]) -> NSPredicate {
        return NSPredicate(format: "%K IN %@", name, value)
    }
}

/**
* Helpful NSError extension
*
* @author TCASSEMBLER
* @version 1.0
*/
extension NSError {
    
    /**
    Initialize new instance with error, data service code and message.
    
    - parameter error:           The error parameter.
    - parameter dataServiceCode: The data service code parameter.
    - parameter message:         The message parameter.
    
    - returns: The new created instance.
    */
    private convenience init(error: NSError?, dataServiceCode: Int, message: String) {
        if let error = error {
            self.init(domain: DataServiceErrorDomain, code: dataServiceCode,
                userInfo: [NSUnderlyingErrorKey: error, NSLocalizedDescriptionKey : message])
        } else {
            self.init(domain: DataServiceErrorDomain, code: dataServiceCode,
                userInfo: [NSLocalizedDescriptionKey : message])
        }
    }
    
    /**
    Show the error as alert
    */
    func showError() {
        showAlert("Error", self.localizedDescription)
    }
}
