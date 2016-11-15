//
//  GooglePlusUtil.swift
//  dodo
//
//  Created by Volkov Alexander on 28.03.16.
//  Copyright © 2016 seriyvolk83dodo. All rights reserved.
//

import UIKit

typealias GooglePlusCallback = (accessToken: String, refreshToken: String, firstName: String, lastName: String, email: String)->()

/// the errors
let ERROR_CANNOT_SIGN_IN_SILENTLY = "Cannot login silently"

/**
 * Google Plus SDK wrapper
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
class GooglePlusUtil: NSObject, GIDSignInDelegate, GIDSignInUIDelegate {

    /// the callback
    private var lastCallback: GooglePlusCallback?
    
    /// the last GIDGoogleUser instance
    private var lastUser: GIDGoogleUser?
    
    /// the failure callback
    private var lastFailureCallback: FailureCallback?
    
    /// the last current view controller
    private var lastViewController: UIViewController?
    
    /// true - will catch the errors and treat them differently, false - else
    private var lastSilentlyFlag = false
    
    /// the singleton
    class var sharedInstance : GooglePlusUtil {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : GooglePlusUtil? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = GooglePlusUtil()
        }
        return Static.instance!
    }
    
    private override init() {
        super.init()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    /**
     Sign In using Google Plus account
     
     - parameter silently:       true - will not open sign-in if user is not signed in already, false - will ask to enter username/password and/or confirm permissions
     - parameter viewController: current view controller
     - parameter callback:       the callback to return data
     - parameter failure:        the failure callback
     */
    func signIn(silently silently: Bool, viewController: UIViewController, callback: GooglePlusCallback, failure: FailureCallback) {
        lastCallback = callback
        lastFailureCallback = failure
        lastViewController = viewController
        lastSilentlyFlag = silently
        if !GIDSignIn.sharedInstance().hasAuthInKeychain() {
            var currentScopes = GIDSignIn.sharedInstance().scopes
            currentScopes.append("https://www.googleapis.com/auth/plus.login")
            GIDSignIn.sharedInstance().scopes = currentScopes
        }
        if silently {
            GIDSignIn.sharedInstance().signInSilently()
        }
        else {
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    /**
     Login using facebook after a registration
     
     - parameter userInfo:       current userInfo
     - parameter viewController: current view controller
     - parameter callback:       the callback to invoke when succcess
     - parameter failure:     the callback to return an error
     */
    func loginGoogle(userInfo: UserInfo, viewController: UIViewController, needToSaveTokens: Bool = true, silently: Bool = false, callback: (username: String, userInfo: UserInfo)->(), failure: FailureCallback) {
        self.signIn(silently: silently, viewController: viewController, callback: { (accessToken, refreshToken, firstName, lastName, email) -> () in
            
            // Save Google Plus creds to tmp UserInfo
            let tryUserInfo = userInfo.clone()
            tryUserInfo.googleAccessToken = accessToken
            tryUserInfo.googleRefreshToken = refreshToken
            tryUserInfo.googleAccountName = email
            tryUserInfo.accountTypes.append(.Google)
            
            if needToSaveTokens {
                self.saveTokens(tryUserInfo, callback: { () -> () in
                    callback(username: email, userInfo: tryUserInfo)
                }, failure: failure)
            }
            else {
                callback(username: email, userInfo: tryUserInfo)
            }
        }, failure: failure)
    }
    
    /**
     Save tokens
     
     - parameter tryUserInfo: UserInfo with tokens
     - parameter callback:    the callback to invoke when succcess
     - parameter failure:     the callback to return an error
     */
    func saveTokens(tryUserInfo: UserInfo, callback: ()->(), failure: FailureCallback) {
        // Update identities
        LambdaServiceApi.sharedInstance.manageIdentities(tryUserInfo, callback: { () -> () in
            AuthenticationUtil.sharedInstance.storeUserInfo(tryUserInfo)
            callback()
        }, failure: failure)
    }
    
    // MARK: - GIDSignInDelegate
    
    /**
    User signed in
    
    - parameter signIn: GIDSignIn
    - parameter user:   GIDGoogleUser
    - parameter error:  a related error
    */
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
        withError error: NSError!) {
            if (error == nil) {
                // Perform any operations on signed in user here.
//                let userId = user.userID                  // For client-side use only!
                let givenName = user.profile.givenName
                let familyName = user.profile.familyName
                let email = user.profile.email

                self.lastUser = user
                self.lastCallback?(accessToken: user.authentication.accessToken,
                    refreshToken: user.authentication.refreshToken,
                    firstName: givenName,
                    lastName: familyName,
                    email: email)
            } else {
                if lastSilentlyFlag {
                    lastFailureCallback?(ERROR_CANNOT_SIGN_IN_SILENTLY)
                }
                else {
                    lastFailureCallback?(error.localizedDescription)
                }
            }
    }
    
    /**
     User disconnected
     
     - parameter signIn: GIDSignIn
     - parameter user:   GIDGoogleUser
     - parameter error:  a related error
     */
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        print("didDisconnectWithUser: user=\(user)")
    }
    
    // MARK: - GIDSignInUIDelegate
    
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        // nothing to do
    }
    
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!,
        presentViewController viewController: UIViewController!) {
            lastViewController?.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
        dismissViewController viewController: UIViewController!) {
            lastViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Additional data
    
    
    /**
     Get Google friends
     
     - parameter silently: true - will not ask to login if tokens has expired, false - else
     - parameter callback: the callback to return the contacts
     - parameter failure:  the failure callback
     */
    func getFriends(silently silently: Bool, callback: ([Contact])->(), failure: FailureCallback) {
        let plusService = GTLServicePlus()
        plusService.retryEnabled = true
        
        self.signIn(silently: silently, viewController: UIViewController.getCurrentViewController()!, callback: { _ in
            
            let user = self.lastUser!
            let authorizer = GTMOAuth2Authentication()
            authorizer.userEmail = user.profile.email
            authorizer.userID = user.userID
            authorizer.accessToken = user.authentication.accessToken
            authorizer.refreshToken = user.authentication.refreshToken
            authorizer.expirationDate = user.authentication.accessTokenExpirationDate
            
            plusService.authorizer = authorizer
            let query = GTLQueryPlus.queryForPeopleListWithUserId("me", collection: kGTLPlusCollectionVisible) as! GTLQueryPlus
            plusService.executeQuery(query) { (ticket: GTLServiceTicket!, response: AnyObject!, error: NSError!) -> Void in
                
                if let error = error {
                    failure(error.localizedDescription)
                }
                else if let peopleFeed = response as? GTLPlusPeopleFeed {
                    
                    var contacts = [Contact]()
                    for item in peopleFeed.items() {
                        if let person = item as? GTLPlusPerson {
                            let contact = Contact.fromGooglePlusPerson(person)
                            contacts.append(contact)
                        }
                    }
                    callback(contacts)
                }
            }
            
        }, failure: { error in
            // If cannot login silently, then return empty list
            if error == ERROR_CANNOT_SIGN_IN_SILENTLY {
                callback([])
            }
            else {
                failure(error)
            }
        })
        
    }
}
