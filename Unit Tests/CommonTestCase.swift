//
//  CommonTestCase.swift
//  dodo
//
//  Created by TCASSEMBLER on 26.01.16.
//  Copyright © 2016 seriyvolk83dodo, Inc. All rights reserved.
//

import XCTest
import YOURLIB

/**
 Common wait intervals used for tests (in seconds)
 
 - ONE_REQUEST:       wait interval for one request to a server
 - AFEW_REQUESTS:     for a few requests (2-3)
 - MULTIPLE_REQUESTS: for number of requests >3
 */
enum WAITTIME: NSTimeInterval {
    case QUICK = 30.0
    case ONE_REQUEST = 45.0
    case AFEW_REQUESTS = 60.0
    case MULTIPLE_REQUESTS = 120.0
}

/**
 * Abstract class for subclasses with unit tests. Contains common methods.
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
class CommonTestCase: XCTestCase {
    
    REMOVE THIS METHOD AND USE THE FOLLOWING CODE in METHODS
    /**
     Test loadUserInfo
     */
    func testLoadUserInfo() {
        let expectation: XCTestExpectation! = expectationWithDescription(__FUNCTION__)
        api.loadUserInfo({ (userInfo) -> () in
            
            XCTAssertFalse(userInfo.name.isEmpty, "should be not empty")
            XCTAssertNotNil(userInfo.link, "should be not nil")
            XCTAssertFalse(userInfo.location.isEmpty, "should be not empty")
            XCTAssertFalse(userInfo.bio.isEmpty, "should be not empty")
            self.assertPictures(userInfo.pictures)
            for website in userInfo.websites {
                XCTAssertFalse(website.name.isEmpty, "should be not empty")
            }
            XCTAssertNotNil(userInfo.metadata, "should not be nil")
            expectation.fulfill()
            }, errorCallback: self.createFailingFailureCallback(expectation))
        
        waitForExpectations()
    }
    
    
    // MARK: Expectation methods

    /**
     Wait for expectation to be fulfilled. The waitSeconds should be as low as possible
     but not too low to allow HTTP client to hanlde request from server.
     Ten seconds is a good threshold.
     
     - parameter waitSeconds: the number of seconds to wait
     */
    internal func waitForExpectations(waitSeconds: NSTimeInterval) {
        self.waitForExpectationsWithTimeout(waitSeconds) { (error) in XCTAssertNil(error, "Error: \(error)") }
    }
    
    /**
     A shortcut method without a parameter
     */
    internal func waitForExpectations() {
        // An increased timeout is used because if network connection is had then tests fails by timeout
        let timeout = WAITTIME.ONE_REQUEST.rawValue
        self.waitForExpectations(timeout)
    }
    
    // MARK: Common callbacks
    
    /**
    Create failure callback that fails the test.
    Used for "green" tests that should NOT invoke FailureCallback
    
    - parameter expectation: the expectation used for the test
    
    - returns: FailureCallback
    */
    internal func createFailingFailureCallback(expectation: XCTestExpectation) -> FailureCallback {
        return { (errorMessage: RestError, response: RestResponse?) -> () in
            XCTAssert(false, "should not call errorCallback. error=\(errorMessage)")
            expectation.fulfill()
        }
    }
    
    /**
     Create callback that fails the test.
     Used for "red" tests that should not invoke errorCallbacks
     
     - parameter expectation: the expectation used for the test
     
     - returns: the callback without parameters
     */
    internal func createFailingCallback(expectation: XCTestExpectation) -> (() -> ()) {
        return { () -> () in
            XCTAssert(false, "should not call callback")
            expectation.fulfill()
        }
    }
    
    /**
     Create failure callback that checks if there is an error and there is no response object
     
     - parameter expectation: the expectation used for the test
     
     - returns: FailureCallback
     */
    internal func createIncorrectParameterErrorCallback(expectation: XCTestExpectation) -> FailureCallback {
        return { (errorMessage: RestError, response: RestResponse?) -> () in
            
            // Check failure
            XCTAssertFalse(errorMessage.getMessage().isEmpty, "should be not empty")
            XCTAssertNil(response, "should be nil")
            expectation.fulfill()
        }
    }
    
    /**
     Create error callback that checks if there are en error and a response object.
     This method is used to test API failures.
     
     - parameter expectation: the expectation used for the test
     
     - returns: FailureCallback
     */
    internal func createGreenErrorCallback(expectation: XCTestExpectation) -> FailureCallback {
        return { (errorMessage: RestError, response: RestResponse?) -> () in
            
            // Check failure
            XCTAssertFalse(errorMessage.getMessage().isEmpty, "should be not empty")
            expectation.fulfill()
        }
    }
    
    
}
