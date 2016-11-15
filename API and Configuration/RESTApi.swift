//
//  RESTApi.swift
//  dodo
//
//  Created by TCCODER on 30.01.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import Foundation

/**
 * RESTError
 * ErrorType for RESTApi
 *
 * - author: TCCODER
 * - version: 1.0
 */
enum RESTError: ErrorType, CustomStringConvertible {
    
    // dodo comments
    case NoNetworkConnection
    case InvalidResponse
    case Failure(message: String)
    case WrongParameters(message: String)
    
    /// return NSError object
    func error() -> NSError {
        let nsError = self as NSError
        return NSError(domain: nsError.domain, code: nsError.code,
            userInfo: [NSLocalizedDescriptionKey: self.description])
    }

    /// error description
    var description: String {
        switch self {
        case .NoNetworkConnection: return NSLocalizedString("No network connection available",
            comment: "No network connection available")
        case .InvalidResponse: return NSLocalizedString("Invalid response from server",
            comment: "Invalid response from server")
        case .Failure(let message): return "Failure: \(message)"
        case .WrongParameters(let message): return message
        }
    }
}

/**
* HTTP methods for requests
*/
public enum RESTMethod: String {
    case OPTIONS = "OPTIONS"
    case GET = "GET"
    case HEAD = "HEAD"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
    case TRACE = "TRACE"
    case CONNECT = "CONNECT"
}

/**
 * RESTApi
 * A singleton to access the Rest API dodo
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RESTApi {
    
    /// the singleton
    class var sharedInstance : RESTApi {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : RESTApi? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = RESTApi(baseUrl: Configuration.sharedConfig.apiBaseUrl)
        }
        return Static.instance!
    }
    
    /// the base URL for API
    private let baseUrl: String
    
    /// the access token
    private var accessToken: String?
    
    // This prevents others from using the default '()' initializer for this class.
    private init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    // MARK: Coaches
    
    /**
    Register user
    
    - parameter username:  the username
    - parameter password:  the password
    - parameter firstName: the first name
    - parameter lastName:  the second name
    - parameter callback:  the callback to invoke when success
    - parameter failure:   the callback to invoke when an error occurred
    */
    func register(username: String, password: String, firstName: String, lastName: String,
        callback: ()->(), failure: FailureCallback) {
            let emptyParametersFailure = createFailureCallbackForEmptyParameters(failure)
            if !ValidationUtils.validateStringNotEmpty(username, emptyParametersFailure)
            || !ValidationUtils.validateStringNotEmpty(password, emptyParametersFailure)
            || !ValidationUtils.validateStringNotEmpty(firstName, emptyParametersFailure)
            || !ValidationUtils.validateStringNotEmpty(lastName, emptyParametersFailure) {
                return 
            }
            let parameters = [
                "username": username,
                "password": password,
                "firstName": firstName,
                "lastName": lastName
            ]
            let request = createJsonRequest(.POST, endpoint: "coaches", parameters: parameters, failure: failure)
            self.sendRequestAndHandleError(request, success: { (json) -> () in
                callback()
                // dodo check result RESTError.InvalidResponse.error()
            }, failure: failure)
    }
    
    // MARK: - Common methods
    
    /**
    Create request with JSON parameters
    
    - parameter method:     the method
    - parameter endpoint:   the endpoint
    - parameter parameters: the parameters
    - parameter failure:    the callback to invoke when an error occurred
    
    - returns: the request
    */
    func createJsonRequest(method: RESTMethod, endpoint: String, parameters: [String: String],
        failure: FailureCallback) -> NSURLRequest  {
            var url = endpoint.hasPrefix("http://") ? endpoint : "\(baseUrl)\(endpoint)"
            var body: NSData?
            if method == .GET {
                let params = parameters.toURLString()
                url = "\(url)?\(params)"
            }
            else {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(parameters,
                        options: NSJSONWritingOptions(rawValue: 0))
                    if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                        body = string.dataUsingEncoding(NSUTF8StringEncoding)
                    }
                }
                catch let error as NSError {
                    failure(error.localizedDescription)
                }
            }
            
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            request.HTTPMethod = method.rawValue
            if let accessToken = accessToken {
                request.addValue(accessToken, forHTTPHeaderField: "Authorization")
            }
            request.HTTPBody = body
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            return request
    }

    /**
    Send request and handle common errors
    
    - parameter request:  the request
    - parameter success:  the callback to return JSON response
    - parameter failure:  the callback to invoke when an error occurred
    
    - throws: exceptions from NSURLSession.dataTaskWithRequest
    */
    func sendRequestAndHandleError(request: NSURLRequest, success: (JSON)->(), failure: FailureCallback) {
        // Check for network first
        if !Reachability.isConnectedToNetwork() {
            failure(RESTError.NoNetworkConnection.error().localizedDescription)
            return
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                dispatch_async(dispatch_get_main_queue()) {
                    failure(RESTError.Failure(message: error.localizedDescription).error().localizedDescription)
                }
                return
            }
            // read json from data
            let json = JSON(data: data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
            
            // dodo can check common errors in response here
            // if the response is failure
//            if json["result"].string == "Failure" {
//                dispatch_async(dispatch_get_main_queue()) {
//                    failure(RESTError.Failure(message: json["resultDetails"].string!).error().localizedDescription)
//                }
//            }
//            else {
                dispatch_async(dispatch_get_main_queue()) {
                    success(json)
                }
//            } dodo
        }
        task.resume()
    }


    /**
     Create FailureCallback for validating empty parameters.
     Wraps initial failure callback to return correct error message
     
     - parameter failure: the initial FailureCallback
     
     - returns: FailureCallback wrapper
     */
    func createFailureCallbackForEmptyParameters(failure: FailureCallback) -> FailureCallback {
        return { (_)->() in
            failure(RESTError.WrongParameters(message: NSLocalizedString("Please fill all fields",
            comment: "Please fill all fields")).error().localizedDescription)
        }
    }    
    
}

/// the string used to separate video file content in HTTP request
let BOUNDARY = "---------------------------14737809831466499882746641449"

/**
 Upload video.
 
 - parameter dive:     the related dive
 - parameter session:  the session
 - parameter assetUrl: the URL of the video
 - parameter callback: the callback to invoke when success
 - parameter failure:  the callback to invoke when an error occurred
 */
func uploadFile(fileData: NSData, fileName: String, assetUrl: NSURL,
                callback: (JSON) -> (), failure: FailureCallback) {
    let fieldName = "file"
    // Request
    let request = createJsonRequest(.POST,
                                    endpoint: "dodo",
                                    parameters: [:], failure: failure)
    
    let boundary = self.BOUNDARY
    let contentType = "multipart/form-data; boundary=\(boundary)"
    (request as? NSMutableURLRequest)?.setValue(contentType, forHTTPHeaderField: "Content-Type")
    let postbody = NSMutableData()
    postbody.appendData("\r\n--\(boundary)\r\n".data())
    postbody.appendData(
        "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data())
    postbody.appendData("Content-Type: application/octet-stream\r\n\r\n".data())
    postbody.appendData(fileData)
    postbody.appendData("\r\n--\(boundary)--\r\n".data())
    (request as? NSMutableURLRequest)?.HTTPBody = postbody
    
    self.sendRequestAndParseJson(request, success: { (json) -> () in
        callback(json)
        }, failure: failure)
}
