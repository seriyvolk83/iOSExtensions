//
//  CalendarHelper.swift
//  dodo
//
//  Created by Alexander Volkov on 16.12.14.
//  Copyright (c) 2014 seriyvolk83dodo. All rights reserved.
//

import UIKit
import EventKit

// Protocol for calendar implementation
protocol CalendarProtocol {
    
    func hasEventInCalendar(object: Activity)->Bool
    
    // Adds object event into user's calendar
    func addToCalendar(object: Activity, callback: (Bool)->())
    
    // Removes previously added event
    func removeFromCalendar(object: Activity, callback: (Bool)->())
}

// Helps add/remove objects from calendar
class CalendarHelper: NSObject, CalendarProtocol {
    
    class var sharedInstance: CalendarHelper {
        struct Singleton {
            static let instance = CalendarHelper()
        }
        
        return Singleton.instance
    }
    
    var lastCalendarCallback: ((Bool)->())?
    
    // Add new event to user's calendar with confirmation
    func addToCalendar(object: Activity, callback: (Bool)->()) {
        lastCalendarCallback = callback
        tryRequestAccess() { store in
            self.addEvent(object, store: store)
        }
    }
    
    // Confirms object removal from the Calendar. See alertView: for details how object is removed
    func removeFromCalendar(event: Activity, callback: (Bool)->()) {
        lastCalendarCallback = callback
        tryRequestAccess() { store in
            let savedEventId = LocalStorage.getEventId(event)
            if let eventId = savedEventId {
                let event = store.eventWithIdentifier(eventId);
                if let eventToRemove = event {
                    do {
                        try store.removeEvent(eventToRemove, span: EKSpan.ThisEvent, commit: true)
                    }
                    catch let error {
                        print("ERROR: \(error)")
                    }
                }
            }
            NSLog("Event was deleted from calendar with id=\(savedEventId)")
            // Remove from local storage
            LocalStorage.removeEvent(event)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.lastCalendarCallback?(true)
                return
            })
        }
    }
    
    private func tryRequestAccess(callback: (EKEventStore)->()) {
        // Request access to the calendar
        let store = EKEventStore()
        store.requestAccessToEntityType(EKEntityType.Event, completion: { (granted: Bool, error: NSError?) -> Void in
            // Check if access was granted
            guard granted else { return }
            callback(store)
        })
    }
    
    func addEvent(e: Activity, store: EKEventStore) {
        // Create new EKEvent object
        let event = EKEvent(eventStore: store)
        event.title = e.title
        event.location = e.location
        event.notes = e.note
         event.startDate = e.date ?? NSDate()
        event.endDate = event.startDate.addHours(1)
        event.calendar = store.defaultCalendarForNewEvents
        
        // Save into the Calendar
        do {
            try store.saveEvent(event, span: EKSpan.ThisEvent, commit: true)
        }
        catch let error2 {
            print("ERROR: \(error2)")
            return
        }
        let savedEventId = event.eventIdentifier
        
        // Save event id to identify in the future
        self.saveEvent(savedEventId, event:e)
        
        NSLog("Event was saved in calendar with id=\(savedEventId)")
        
        dispatch_async(dispatch_get_main_queue(), {
            self.lastCalendarCallback?(true)
            return
        })
    }
    
    // Stores pair (eventId:object) in local storage
    func saveEvent(eventId: String, event: Activity) {
        LocalStorage.saveEvent(eventId, object: event)
    }
    
    // Delegates this call to LocalStorage
    func hasEventInCalendar(event: Activity) -> Bool {
        return LocalStorage.hasEventInCalendar(event)
    }
    
}

// Stores simple data in local storage on a device.
class LocalStorage {
    
    // Checks if user already added events for given object
    class func hasEventInCalendar(object: Activity) -> Bool {
        
        let eventId = LocalStorage.getEventId(object)
        return eventId != nil
    }
    
    // Saves eventId for object
    class func saveEvent(eventId: String?, object: Activity) {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setObject(eventId, forKey: object.id)
        
    }
    
    // Removes object from NSUserDefaults that means that there is no event for the object
    class func removeEvent(object: Activity) {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.removeObjectForKey(object.id)
        
    }
    
    class func getEventId(object: Activity) -> String? {
        let prefs = NSUserDefaults.standardUserDefaults()
        
        return prefs.objectForKey(object.id) as? String
    }
}
