//
//  ContactUtils.swift
//  dodo
//
//  Created by Alexander Volkov on 07.04.15.
//  Copyright (c) 2015 seriyvolk83dodo. All rights reserved.
//

import UIKit
import Contacts

if #available(iOS 9.0, *) {
    let store = CNContactStore()
    store.requestAccessForEntityType(CNEntityType.Contacts) { (fin: Bool, error: NSError?) -> Void in
        if let error = error {
            showAlert("Error", message: error.localizedDescription)
        }
        else {
            // Request contacts and obtain emails
            self.getAllContact() { (contacts) -> () in
                self.updateWithColleages(contacts)
            }
        }
    }
}


/**
Get all contacts

- parameter callback: the callback to return the contacts
*/
@available(iOS 9.0, *)
func getAllContact(callback: ([Colleage])->()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
        do {
            let store = CNContactStore()
            
            var contacts = [CNContact]()
            // Request Full Name and Emails
            try store.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: [
                CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
                CNContactEmailAddressesKey,
                CNContactJobTitleKey,
                CNContactPostalAddressesKey
                ]),
                usingBlock: { (contact: CNContact, p: UnsafeMutablePointer<ObjCBool>) -> Void in
                    contacts.append(contact)
            })
            
            //                let predicate = CNContact.predicateForContactsMatchingName("*")
            //                let contacts = try store.unifiedContactsMatchingPredicate(predicate,
            //                    keysToFetch: [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
            //                        CNContactEmailAddressesKey]) dodo
            var colleages = [Colleage]()
            for contact in contacts {
                let fullName = CNContactFormatter.stringFromContact(contact, style: .FullName) ?? "NoName"
                let c = Colleage(fullName)
                if contact.isKeyAvailable(CNContactEmailAddressesKey) {
                    print("Emails for \(fullName):")
                    for email in contact.emailAddresses {
                        let email = email.value as! String
                        if email.contains("@") {
                            print("email=\(email)")
                            c.emails.append(email)
                        }
                    }
                }
                if contact.isKeyAvailable(CNContactJobTitleKey) {
                    c.job = contact.jobTitle
                }
                if contact.isKeyAvailable(CNContactPostalAddressesKey) {
                    for postalAddress in contact.postalAddresses {
                        if let address = postalAddress.value as? CNPostalAddress {
                            let addressString = (address.city + " " + address.street).trimmedString()
                            c.address = addressString
                            break
                        }
                    }
                }
                if !OPTION_INCLUDE_ONLY_WITH_EMAILS || !c.emails.isEmpty {
                    colleages.append(c)
                }
            }
            // Cut the array to have maximum LIMIT_EMAILS values
            dispatch_async(dispatch_get_main_queue(), {
                callback(colleages)
            })
        } catch {
            showAlert("Error", message: "Error accessing your contacts")
        }
        
    })
}


////////////////////////////////////////

class ContactsUtil {
    
    let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    
    func getColleageContacts(callback: [Colleage]->(), errorCallback: String->()) {
        if #available(iOS 9.0, *) {
            let store = CNContactStore()
            store.requestAccessForEntityType(CNEntityType.Contacts) { (fin: Bool, error: NSError?) -> Void in
                if let error = error {
                    errorCallback("Error: " + error.localizedDescription)
                }
                else {
                    // Request contacts and obtain emails
                    self.getAllContact(callback, errorCallback: errorCallback)
                }
            }
        }
        else {
            let authorizationStatus = ABAddressBookGetAuthorizationStatus()
            
            switch authorizationStatus {
            case .Denied, .Restricted:
                //1
                print("Denied")
                errorCallback(MESSAGE_CONTACTS_ACCESS_REQUIRED)
            case .Authorized:
                //2
                print("Authorized")
                requestContactsAndReload(callback, errorCallback: errorCallback)
            case .NotDetermined:
                //3
                print("Not Determined")
                promptForAddressBookRequestAccess(callback, errorCallback: errorCallback)
            }
        }
    }
    
    // MARK: iOS<9.0 AddressBook
    
    func requestContactsAndReload(callback: [Colleage]->(), errorCallback: String->()) {
        let allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as Array
        var colleages = [Colleage]()
        for record in allContacts {
            let currentContact: ABRecordRef = record
            let firstName = ABRecordCopyValue(currentContact, kABPersonFirstNameProperty)?.takeRetainedValue() as? String ?? ""
            let lastName = ABRecordCopyValue(currentContact, kABPersonLastNameProperty)?.takeRetainedValue() as? String ?? ""
            let name = (firstName + " " + lastName).trimmedString()
            let c = Colleage(name)
            for unmanagedAddress in getAddressBookData(kABPersonAddressProperty, contact: currentContact) {
                let addressPart = Unmanaged.fromOpaque(unmanagedAddress.toOpaque()).takeUnretainedValue() as NSDictionary
                
                var address = addressPart[kABPersonAddressCityKey as String] as? String ?? ""
                address += (address != "" ? " " : "") + (addressPart[kABPersonAddressStreetKey as String]  as? String ?? "")
                c.address = address
                break
            }
            
            if ABPersonHasImageData(currentContact) {
                if let imageData = ABPersonCopyImageData(currentContact)?.takeRetainedValue() as? NSData {
                    if let image = UIImage(data: imageData) {
                        c.image = image
                    }
                }
            }
            let job = ABRecordCopyValue(currentContact, kABPersonJobTitleProperty)?.takeRetainedValue() as? String ?? ""
            c.job = job
            
            for emailData in getAddressBookData(kABPersonEmailProperty, contact: currentContact) {
                let email = emailData.takeRetainedValue() as? String ?? ""
                c.emails.append(email)
            }
            if !OPTION_INCLUDE_ONLY_WITH_EMAILS || !c.emails.isEmpty {
                colleages.append(c)
            }
        }
        callback(colleages)
    }
    
    func getAddressBookData(key: ABPropertyID, contact: ABRecordRef) -> [Unmanaged<AnyObject>] {
        let unmanagedPhones = ABRecordCopyValue(contact, key)
        let values: ABMultiValueRef =
        Unmanaged.fromOpaque(unmanagedPhones.toOpaque()).takeUnretainedValue()
            as NSObject as ABMultiValueRef
        
        let count = ABMultiValueGetCount(values)
        
        var list = [Unmanaged<AnyObject>]()
        for index in 0..<count {
            let item = ABMultiValueCopyValueAtIndex(values, index)
            list.append(item)
        }
        return list
    }
    
    func promptForAddressBookRequestAccess(callback: [Colleage]->(), errorCallback: String->()) {
        
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {
                    print("Just denied")
                    errorCallback(MESSAGE_CONTACTS_ACCESS_REQUIRED)
                } else {
                    print("Just authorized")
                    self.requestContactsAndReload(callback, errorCallback: errorCallback)
                }
            }
        }
    }
    
    
    // MARK: iOS9.0+ Contacts
    
    /**
    Get all contacts
    
    - parameter callback: the callback to return the contacts
    */
    @available(iOS 9.0, *)
    func getAllContact(callback: ([Colleage])->(), errorCallback: String->()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            do {
                let store = CNContactStore()
                
                var contacts = [CNContact]()
                // Request Full Name and Emails
                try store.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: [
                    CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
                    CNContactEmailAddressesKey,
                    CNContactJobTitleKey,
                    CNContactPostalAddressesKey
                    ]),
                    usingBlock: { (contact: CNContact, p: UnsafeMutablePointer<ObjCBool>) -> Void in
                        contacts.append(contact)
                })
                var colleages = [Colleage]()
                for contact in contacts {
                    let fullName = CNContactFormatter.stringFromContact(contact, style: .FullName) ?? "NoName"
                    let c = Colleage(fullName)
                    if contact.isKeyAvailable(CNContactEmailAddressesKey) {
                        for email in contact.emailAddresses {
                            let email = email.value as! String
                            if email.contains("@") {
                                c.emails.append(email)
                            }
                        }
                    }
                    if contact.isKeyAvailable(CNContactJobTitleKey) {
                        c.job = contact.jobTitle
                    }
                    if contact.isKeyAvailable(CNContactPostalAddressesKey) {
                        for postalAddress in contact.postalAddresses {
                            if let address = postalAddress.value as? CNPostalAddress {
                                let addressString = (address.city + " " + address.street).trimmedString()
                                c.address = addressString
                                break
                            }
                        }
                    }
                    if !OPTION_INCLUDE_ONLY_WITH_EMAILS || !c.emails.isEmpty {
                        colleages.append(c)
                    }
                }
                // Cut the array to have maximum LIMIT_EMAILS values
                dispatch_async(dispatch_get_main_queue(), {
                    callback(colleages)
                })
            } catch {
                errorCallback("Error: Error accessing your contacts")
            }
            
        })
    }
}
