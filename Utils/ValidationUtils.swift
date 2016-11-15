//
//  ValidationUtils.swift
//  dodo
//
//  Created by Alexander Volkov on 07.04.15.
//  Copyright (c) 2015 seriyvolk83dodo. All rights reserved.
//

import Foundation

/**
 * Validation utilities. Helps to check parameters in service methods before sending HTTP request.
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
class ValidationUtils {
    
    /**
     Check 'value' if it's not nil and callback failure if it is.
     
     - parameter value:   the value to check
     - parameter failure: the closure to invoke if validation fails
     
     - returns: true if string is not empty
     */
    class func validateNil(value: AnyObject?, _ failure: ((String) -> ())?) -> Bool {
        if value == nil {
            failure?(NSLocalizedString("Nil Value", comment:"Nil Value"))
            return false
        }
        return true
    }
    
    /**
     Check URL for correctness and callback failure if it's not.
     
     - parameter url:     the URL to check
     - parameter failure: the closure to invoke if validation fails
     
     - returns: true if URL is correct
     */
    class func validateUrl(url: String?, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        if url == nil || url == "" {
            failure?(RestError.errorWithMessage("Empty URL"), nil)
            return false
        }
        if !url!.hasPrefix("http") {
            failure?(RestError.errorWithMessage("URL should start with \"http\""), nil)
            return false
        }
        return true
    }
    
    /**
     Check 'string' if it's correct ID.
     Delegates validation to two other methods.
     
     - parameter id:      the id string to check
     - parameter failure: the closure to invoke if validation fails
     
     - returns: true if string is not empty
     */
    class func validateId(id: String, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        if !ValidationUtils.validateStringNotEmpty(id, failure) { return false }
        if id.isNumber() && !ValidationUtils.validatePositiveNumber(id, failure) { return false }
        return true
    }
    
    /**
     Check 'string' if it's empty and callback failure if it is.
     
     - parameter string:  the string to check
     - parameter failure: the closure to invoke if validation fails
     
     - returns: true if string is not empty
     */
    class func validateStringNotEmpty(string: String, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        if string.isEmpty {
            failure?(RestError.errorWithMessage("Empty string"), nil)
            return false
        }
        return true
    }
    
    /**
     Check if the string is positive number and if not, then callback failure and return false.
     
     - parameter numberString: the string to check
     - parameter failure:      the closure to invoke if validation fails
     
     - returns: true if given string is positive number
     */
    class func validatePositiveNumber(numberString: String, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        if !numberString.isPositiveNumber() {
            failure?(RestError.errorWithMessage("Incorrect number: \(numberString)"), nil)
            return false
        }
        return true
    }
    
    /**
     Check if the string represents email
     
     - parameter email:   the text to validate
     - parameter failure: the closure to invoke if validation fails
     
     - returns: true if the given string is a valid email
     */
    class func validateEmail(email: String, _ failure:((RestError, RestResponse?) -> ())?) -> Bool {
        let emailPattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        if email.trim() ≈ emailPattern {
            return true
        }
        var message = "Incorrect email format: \(email)"
        var message = "EMAIL_FORMAT".localized().replace("%email%", withString: email)
        if email.trim() == "" {
            message.replace(":", withString: "")
        }
        
        failure?(RestError.errorWithMessage(), nil)
        return false
    }
    
    /**
     Check the order of the dates. End date must be after to equal to Start date.
     
     - parameter startDate: the start date
     - parameter endDate:   the end date
     - parameter failure:   the closure to invoke if validation fails
     
     - returns: true - if the dates have correct order, false - else
     */
    public class func validateStartAndEndDates(startDate: NSDate, endDate: NSDate,
        _ failure: FailureCallback?) -> Bool {
            if startDate.compare(endDate) == NSComparisonResult.OrderedDescending {
                failure?(errorMessage: ERROR_VALIDATION_INCORRECT_DATES_ORDER, response: nil)
                return false
            }
            return true
    }
}


/**
 *  Helper class for regular expressions
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        self.internalExpression = try! NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: [],
            range:NSMakeRange(0, input.characters.count))
        return matches.count > 0
    }
}

// Define operator for simplisity of Regex class
infix operator ≈ { associativity left precedence 140 }
public func ≈(input: String, pattern: String) -> Bool {
    return Regex(pattern).test(input)
}

/**
 * Validation utilities.
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
public class ValidationUtils {
    
    /**
     Check URL for correctness and callback failure if it's not.
     
     - parameter url:     the URL to check
     - parameter failure: the closure to invoke if validation fails
     
     - returns: true if URL is correct
     */
    public class func validateUrl(url: String?, _ failure: ((String) -> ())?) -> Bool {
        if url == nil || url == "" {
            failure?("Empty URL")
            return false
        }
        if !url!.hasPrefix("http") {
            failure?("URL should start with \"http\"")
            return false
        }
        return true
    }
    
    /**
     Check 'string' if it's correct ID.
     Delegates validation to two other methods.
     
     - parameter id:      the id string to check
     - parameter failure: the closure to invoke if validation fails
     
     - returns: true if string is not empty
     */
    public class func validateId(id: String, _ failure: ((String) -> ())?) -> Bool {
        if !ValidationUtils.validateStringNotEmpty(id, failure) { return false }
        if id.isNumber() && !ValidationUtils.validatePositiveNumber(id, failure) { return false }
        return true
    }
    
    /**
     Check 'string' if it's empty and callback failure if it is.
     
     - parameter string:  the string to check
     - parameter failure: the closure to invoke if validation fails
     
     - returns: true if string is not empty
     */
    public class func validateStringNotEmpty(string: String, _ failure: ((String) -> ())?) -> Bool {
        if string.isEmpty {
            failure?("Empty string")
            return false
        }
        return true
    }
    
    /**
     Check if the string is positive number and if not, then callback failure and return false.
     
     - parameter numberString: the string to check
     - parameter failure:      the closure to invoke if validation fails
     
     - returns: true if given string is positive number
     */
    public class func validatePositiveNumber(numberString: String, _ failure: ((String) -> ())?) -> Bool {
        if !numberString.isPositiveNumber() {
            failure?("Incorrect number: \(numberString)")
            return false
        }
        return true
    }
    
    /**
     Check if the string represents email
     
     - parameter email:   the text to validate
     - parameter failure: the closure to invoke if validation fails
     
     - returns: true if the given string is a valid email
     */
    public class func validateEmail(email: String, _ failure: FailureCallback?) -> Bool {
        let emailPattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        if email.trim() ≈ emailPattern {
            return true
        }
        let errorMessage = NSLocalizedString("Incorrect email format", comment: "Incorrect email format")
        failure?("\(errorMessage): \(email).")
        return false
    }
    
    /**
     Check the order of the dates. End date must be after to equal to Start date.
     
     - parameter startDate: the start date
     - parameter endDate:   the end date
     - parameter failure:   the closure to invoke if validation fails
     
     - returns: true - if the dates have correct order, false - else
     */
    public class func validateStartAndEndDates(startDate: NSDate, endDate: NSDate,
        _ failure: FailureCallback?) -> Bool {
            if startDate.compare(endDate) == NSComparisonResult.OrderedDescending {
                failure?(errorMessage: ERROR_VALIDATION_INCORRECT_DATES_ORDER, response: nil)
                return false
            }
            return true
    }
}
