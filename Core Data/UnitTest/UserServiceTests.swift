//
//  UserServiceTests.swift
//  dodo
//
//  Created by Volkov Alexander on 16.04.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import Foundation
import XCTest
import CoreData
import RESTServices

/**
 * Tests for UserService
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
class UserServiceTests: BaseDataServiceTestCase {
    
    /// Represents the entities to clean up property.
    override class var entitiesToCleanUp: [String] {
        return [UserManagedObject.entityName]
    }
    
    /// Represents the service under test.
    var service: UserService!

    /**
     Sets up the environment
     */
    override func setUp() {
        super.setUp()
        service = UserService()
    }
    
    /**
     Tests insertion and retrieval
     */
    func testInsertionAndRetrieval() {
        
        let insertionExpectation = self.expectationWithDescription("insertion expectation")
        let retrievalExpectation = self.expectationWithDescription("retrieval expectation")
        
        // insert and validate
        let object = createSampleUser()
        insertObject(object, expectation: insertionExpectation, success: { (insertedObjects) -> () in
            self.validateUsers(insertedObjects, expectation: retrievalExpectation)
        })
        
        waitForCoreDataOperation()
    }
    
    /**
     Tests removing all
     */
    func testRemovingAll() {
        
        let insertionExpectation = self.expectationWithDescription("insertion expectation")
        let deletionExpectation = self.expectationWithDescription("Deletion Expectation")
        let retrievalExpectation = self.expectationWithDescription("retrieval expectation")
        
        // insert objects
        let object = createSampleUser()
        insertObject(object, expectation: insertionExpectation, success: { (insertedObjects: [User]) -> () in
            
            self.service.removeAllInstances(UserManagedObject.entityName, success: {
                self.assertMainThread()
                
                // assert that we don't have any objects
                self.validateUsers([], expectation: retrievalExpectation)
                
                deletionExpectation.fulfill()
            }, failure: self.failureBlock(deletionExpectation))
        })
        waitForCoreDataOperation()
    }
    
    /**
     Test update opportunities.
     */
    func testUpdate() {
        
        let insertionExpectation = self.expectationWithDescription("insertion expectation")
        let updateExpectation = self.expectationWithDescription("update Expectation")
        let retrievalExpectation = self.expectationWithDescription("retrieval expectation")
        
        // insert objects
        let object = createSampleUser()
        insertObject(object, expectation: insertionExpectation, success: { (insertedObjects: [User]) -> () in
            
            var updatedObjects = [User]()
            for objectToUpdate in insertedObjects {
                
                objectToUpdate.username += "updated"
                objectToUpdate.password += "updated"
                objectToUpdate.firstname += "updated"
                objectToUpdate.lastname += "updated"
                objectToUpdate.emailAddress += "updated"
                objectToUpdate.height += 1
                objectToUpdate.consentToShareData = !objectToUpdate.consentToShareData
                updatedObjects.append(objectToUpdate)
            }
            
            self.service.updateUsers(updatedObjects, success: { () -> () in
                self.assertMainThread()
                
                // assert the updated objects
                self.validateUsers(updatedObjects, expectation: retrievalExpectation)
                
                updateExpectation.fulfill()
                
                }, failure: self.failureBlock(updateExpectation))
            })
        
        waitForCoreDataOperation()
    }
}

/**
 * Helpful classes used in tests
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension UserServiceTests {

    /**
     Create sample object
     
     - returns: the object to use in tests
     */
    func createSampleUser() -> User {
        let user = User()
        user.id = ""
        let rand = Int.random(1000000)
        user.username = "unit\(rand)"
        user.password = "password\(rand)"
        user.firstname = "firstname\(rand)"
        user.lastname = "lastname\(rand)"
        user.emailAddress = "emailAddress\(rand)"
        user.height = Double(rand)
//        user.dateOfBirth: NSDate = NSDate()
        user.consentToShareData = true
//        user.profileImage: UIImage? // dodo
        return user
    }
    
    /**
     Insert objects expectation and success
     
     - parameter object:      the object to insert
     - parameter expectation: the expectation
     - parameter success:     the success callback
     */
    private func insertObject(object: User, expectation: XCTestExpectation, success: ([User]) -> ()) {
        service.insertUserInfo(object, success: { (insertedObjects: [User]) -> () in
            self.assertMainThread()
            
            self.assertCoreDataBridge(insertedObjects)
            
            success(insertedObjects)
            
            expectation.fulfill()
            
            }, failure: self.failureBlock(expectation))
    }

    /**
     Assert users

     - parameter users:       the users
     - parameter expectation: the expectation
     */
    private func validateUsers(users: [User], expectation: XCTestExpectation) {
        
        service.getUserInfo({ [weak self] (dbUsers) in
            
            self?.assertMainThread()
            self?.assertUnsortedLists(expected: users, actual: dbUsers, assertions: { (expected, actual) -> () in
                UserServiceTests.validateUser(expected, actual)
            })
            expectation.fulfill()
            
        }, failure: self.failureBlock(expectation))
    }
    
    /**
     Validate objects are equal
     
     - parameter object1: the first object
     - parameter object2: the second object
     */
    class func validateUser(object1: User, _ object2: User) {
        XCTAssertEqual(object1.id, object2.id, "should be equal")
        XCTAssertEqual(object1.username, object2.username, "should be equal")
        XCTAssertEqual(object1.password, object2.password, "should be equal")
        XCTAssertEqual(object1.firstname, object2.firstname, "should be equal")
        XCTAssertEqual(object1.lastname, object2.lastname, "should be equal")
        XCTAssertEqual(object1.emailAddress, object2.emailAddress, "should be equal")
        XCTAssertEqual(object1.height, object2.height, "should be equal")
        XCTAssertTrue(object1.dateOfBirth.isSameDay(object2.dateOfBirth), "should be equal")
        XCTAssertEqual(object1.consentToShareData, object2.consentToShareData, "should be equal")
        XCTAssertEqual(object1.profileImage, object2.profileImage, "should be equal")
    }
}
