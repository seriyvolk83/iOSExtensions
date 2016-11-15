//
//  BaseDataServiceTestCase.swift
//  dodo
//
//  Created by Volkov Alexander on 14.04.16.
//  Copyright (c) 2016 seriyvolk83dodo. All rights reserved.
//

import Foundation
import XCTest
import RESTServices
import CoreData

/**
 * Base class for tests for Core Data based services
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
class BaseDataServiceTestCase: XCTestCase {

    /// Represents the entities to clean up property.
    class var entitiesToCleanUp: [String] {
        return []
    }

    /**
    Sets up the environment
    */
    override func setUp() {
        super.setUp()

        destoryEntities()
    }

    /**
    Tear down the environment
    */
    override func tearDown() {
        super.tearDown()

        destoryEntities()
    }

    /**
    Destory entities
    */
    private func destoryEntities() {
        let entityNames = self.dynamicType.entitiesToCleanUp
        if entityNames.count == 0 {
            return
        }

        let persistence = PersistenceStack(modelName: "TotalMama")
        persistence.context.performBlockAndWait { () -> Void in

            for entityName in entityNames {

                let fetchRequest = NSFetchRequest(entityName: entityName)
                if let objects = try? persistence.context.executeFetchRequest(fetchRequest) as! [NSManagedObject] {
                    for object in objects {
                        persistence.context.deleteObject(object)
                    }
                }
            }

            do {
                try persistence.context.save()
            }
            catch {
                // 
            }
        }
    }

    /**
     Failure block with expectation, file and line parameters
     
     - parameter expectation: the expectation
     - parameter file:        the file
     - parameter line:        the line
     
     - returns: GeneralFailureBlock
     */
    func failureBlock(expectation: XCTestExpectation, file: StaticString = #file, line: UInt = #line) -> GeneralFailureBlock {
        return { (error: NSError) in

            XCTFail("Core data service returned error: \(error)", file: file, line: line)
            expectation.fulfill()
        }
    }

    /**
    Wait for the expecation until the core data operation finishes
    */
    func waitForCoreDataOperation() {
        // 0 timeout, to check if the validation on the server or not
        waitForExpectationsWithTimeout(10) { (error) -> Void in
            XCTAssertNil(error, "Core data operation timed out with error: \(error)")
        }
    }

    /**
    Assert execution on main thread.

    :param: file The file parameter.
    :param: line The line parameter.
    */
    func assertMainThread(file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(NSThread.currentThread().isMainThread, "Execution should be on the main thread", file: file, line: line)
    }

    /**
    Core data entity bridge.

    :param: objects The objects parameter.
    */
    func assertCoreDataBridge<T : CoreDataEntityBridge>(objects: [T]) {
        for (index, object) in objects.enumerate() {
            XCTAssertNotNil(object.managedObjectID, "Retrieved object at index \(index) should have a valid non-nil managedObjectID")
        }
    }

    /**
    Assert sorted lists expected, actual and @noescape.

    :param: expected   The expected parameter.
    :param: actual     The actual parameter.
    :param: assertions The assertions parameter.
    */
    func assertSortedLists<T>(expected expected: [T], actual: [T], @noescape assertions: (expected: T, actual: T) -> ()) {
        XCTAssertEqual(expected.count, actual.count, "Incorrect number of objects")

        for i in 0..<expected.count {
            assertions(expected: expected[i], actual: actual[i])
        }
    }

    /**
    Core data entity bridge expected, actual and @noescape.

    :param: expected   The expected parameter.
    :param: actual     The actual parameter.
    :param: assertions The assertions parameter.
    */
    func assertUnsortedLists<T : CoreDataEntityBridge>(expected expected: [T], actual: [T], @noescape assertions: (expected: T, actual: T) -> ()) {

        XCTAssertEqual(expected.count, actual.count, "Incorrect number of objects")

        assertCoreDataBridge(actual)

        var dbDictionary = [NSManagedObjectID: T]()
        for dbObject in actual {
            dbDictionary[dbObject.managedObjectID!] = dbObject
        }

        for expectedObject in expected {
            if let dbObject = dbDictionary[expectedObject.managedObjectID!] {

                // assert properties
                assertions(expected: expectedObject, actual: dbObject)

            } else {
                XCTFail("Couldn't find object with id:'\(expectedObject.managedObjectID)', object=\(expectedObject)")
            }
        }
    }

}
