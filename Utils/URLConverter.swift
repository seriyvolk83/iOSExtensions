//
//  URLConverter.swift
//  dodo
//
//  Created by Alexander Volkov on 15.11.14.
//  Copyright (c) 2014 seriyvolk83dodo, Inc. All rights reserved.
//

import Foundation

let GOOGLE_DRIVE = "googledrive://"

// Makes some url convertions
class URLConverter {

    
    /**
    Checks if url string contains "force.com" and converts to frontdoor url,
    else checks if need to replace "{instanceURL}" and returns fixed url.
    
    :param: url the url to correct
    
    :returns: corrected URL
    */
    class func getCorrectUrlString(url: String) -> String {
        var urlString = url.stringByReplacingOccurrencesOfString("{instanceURL}", withString: URLConverter.getInstanceURL(), options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        if urlString.contains("force.com") {
            return URLConverter.urlForFrontdoor(urlString)
        }
        return urlString
    }
    
    // Create url to open via frontdoor.jsp with corresponding credentials
    class func urlForFrontdoor(urlToOpen: String) -> String {
        let instanceURL = URLConverter.getInstanceURL()
        let token = SFUserAccountManager.sharedInstance().currentUser.credentials.accessToken
        
        println("URLConverter: instanceURL=\(instanceURL) token=\(token)")

        let finalUrlToOpen = prepareUrlToOpen(urlToOpen, withInstanceURL: instanceURL)
        let urlToOpenEncoded = URLConverter.getURLEncodedString(finalUrlToOpen)
        
        println("URLConverter: frontdoor retURL: \(finalUrlToOpen)")
        
        let url = "\(instanceURL)/secur/frontdoor.jsp?sid=\(token)&retURL=\(urlToOpenEncoded)"
        println("URLConverter: frontdoor full url: \(url)")
        return url
    }
    
    private class func prepareUrl(url: String) -> String {
        let instanceURL = URLConverter.getInstanceURL()
        let token = SFUserAccountManager.sharedInstance().currentUser.credentials.accessToken
        return prepareUrlToOpen(url, withInstanceURL: instanceURL)
    }
    
    class func getInstanceURL() -> String {
        var instanceURL = "https://ap1.salesforce.com"
        if let currentInstanceURL = SFUserAccountManager.sharedInstance().currentUser.credentials.instanceUrl {
            if currentInstanceURL.relativeString != "" {
                instanceURL = currentInstanceURL.relativeString!
            }
        }
        return instanceURL
    }

    class func getURLEncodedString(string: String) -> String {
        let set = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as NSMutableCharacterSet;
        set.removeCharactersInString(":?&=@+/'");
        return string.stringByAddingPercentEncodingWithAllowedCharacters(set as NSCharacterSet)!
    }

    class func prepareUrlToOpen(url: String, withInstanceURL: String) ->String {
        var pod = "na1"
        if let salesforceLocation = withInstanceURL.rangeOfString(".salesforce", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil){
            pod = withInstanceURL.substringWithRange(Range<String.Index>(start: advance(withInstanceURL.startIndex, 8), end: salesforceLocation.startIndex))
        }
        return url.stringByReplacingOccurrencesOfString("{pod}", withString: pod)
    }

    /**
    Check if the given url is Google Drive document.
    
    :param: url the url to check
    
    :returns: true if it's a Google Drive document url
    */
    class func isGoogleDoc(url: String) -> Bool {
        if url.contains(GOOGLE_DRIVE) {
            return true
        }
        if url.contains("drive.google.com") {
            return true
        }
        if url.contains("docs.google.com") {
            return true
        }
        return false
    }
    
    /**
    Open Google Doc
    
    :param: url the url to open
    */
    class func openGoogleDoc(googleDriveUrl: String) {
        var url2open = googleDriveUrl
        var clearUrl = googleDriveUrl
        if url2open.hasPrefix(GOOGLE_DRIVE) {
            clearUrl = clearUrl.replace(GOOGLE_DRIVE, withString: "")
        }
        else {
            url2open = GOOGLE_DRIVE + url2open
        }
        if let googleAppUrl = NSURL(string: "googledrive://\(url2open)") {
            println("Opening document: \(googleAppUrl.absoluteString)")
            if UIApplication.sharedApplication().openURL(googleAppUrl) {
                return
            }
            
            // Try open the document in browser
            if let browserUrl = NSURL(string: clearUrl)  {
                if UIApplication.sharedApplication().openURL(browserUrl) {
                    return
                }
            }
            else {
                println("ERROR: Wrong URL for the document: \(url2open)")
            }
        }
        showAlert("Error", "Cannot open URL: \(url2open)")
    }
    
    /**
    Add extra parameters to given url
    
    :param: params the params set
    :param: url    initial url
    */
    class func addExtraParams(params: [String: String], toUrl url: String) -> String {
        var paramsString = ""
        for (k,v) in params {
            paramsString += (paramsString == "" ? "" : "&")
            paramsString += "\(k)=\(v)"
        }
        if url.contains("?") {
            return "\(url)&\(paramsString)"
        }
        else {
            return "\(url)?\(paramsString)"
        }
    }
    
    class func urlDecode(encoded: String) -> String {
        return encoded.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    }
}
