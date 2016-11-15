//
//  ValidationUtilsTest.swift
//  dodo
//
//  Created by TCASSEMBLER on 25.12.15.
//  Copyright © 2015dodo seriyvolk83dodo. All rights reserved.
//

import XCTest
import ABHE
/**
 * Test validation methods
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
class ValidationUtilsTest: ABCommonTestCase {
   
    // Test validateId method
    func testValidateIdStringNotEmpty() {
        XCTAssertTrue(ValidationUtils.validateId("string", nil), "should validate")
        
        let expectation = self.expectationWithDescription("failure invocation")
        XCTAssertFalse(ValidationUtils.validateId("", { (errorMessage: String, res: AnyObject?) -> () in
            expectation.fulfill()
        }), "should not validate")
        self.waitForExpectations(WAITTIME.QUICK.rawValue)
    }
    
    // Test validateStringNotEmpty method
    func testValidateStringNotEmpty() {
        XCTAssertTrue(ValidationUtils.validateStringNotEmpty("string", nil), "should validate")
        
        let expectation = self.expectationWithDescription("failure invocation")
        XCTAssertFalse(ValidationUtils.validateStringNotEmpty("", { (errorMessage: String, res: AnyObject?) -> () in
            expectation.fulfill()
        }), "should not validate")
        self.waitForExpectations(WAITTIME.QUICK.rawValue)
    }
    
    // Test validatePositiveNumber method
    func testValidatePositiveNumber() {
        XCTAssertTrue(ValidationUtils.validatePositiveNumber("100", nil), "should validate")
        XCTAssertFalse(ValidationUtils.validatePositiveNumber("", nil), "should not validate")
        XCTAssertFalse(ValidationUtils.validatePositiveNumber("0", nil), "should not validate")
        XCTAssertFalse(ValidationUtils.validatePositiveNumber("A00000", nil), "should not validate")
        
        let expectation = self.expectationWithDescription("failure invocation")
        XCTAssertFalse(ValidationUtils.validatePositiveNumber("-1", { (errorMessage: String, res: AnyObject?) -> () in
            expectation.fulfill()
        }), "should not validate")
        self.waitForExpectations(WAITTIME.QUICK.rawValue)
    }
    
    // Test validateStartAndEndTime method
    func testValidateStartAndEndTime() {
        let startTime = NSDate()
        let endTime = NSDate().dateByAddingTimeInterval(1)
        XCTAssertTrue(ValidationUtils.validateStartAndEndDates(startTime, endDate: endTime, nil),
            "should validate successive dates")
        XCTAssertTrue(ValidationUtils.validateStartAndEndDates(startTime, endDate: startTime, nil),
            "should validate equal dates")
        XCTAssertFalse(ValidationUtils.validateStartAndEndDates(endTime, endDate: startTime, nil),
            "should not validate")
        
        let expectation = self.expectationWithDescription("failure invocation")
        ValidationUtils.validateStartAndEndDates(endTime, endDate: startTime, {
            (errorMessage: String, res: AnyObject?) -> () in
            expectation.fulfill()
        })
        self.waitForExpectations()
    }
    
}
