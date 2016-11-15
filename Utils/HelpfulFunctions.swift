//
//  HelpfulFunctions.swift
//  dodo
//
//  Created by Alexander Volkov on 16.04.15.
//  Copyright (c) 2015 seriyvolk83dodo. All rights reserved.
//

import UIKit

/**
A set of helpful functions and extensions
*/

private let group = dispatch_group_create()
dispatch_group_enter(group)
dispatch_group_leave(group)
dispatch_group_notify(group, dispatch_get_main_queue(), {
    // finish
})

let group = DispatchGroup()
group.enter()
group.leave()
group.notify(queue: DispatchQueue.main, execute: {
    // finish
})

/**
* Extends UIImage with a shortcut method.
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIImage {
    
    /**
    Capture image from given view
     
     - parameter view: the view
     
     - returns: UIImage
     */
    class func imageFromView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: false)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    /**
    Load image asynchronously
    
    :param: url      image URL
    :param: callback the callback to return the image
    */
    class func loadFromURLAsync(url: NSURL, callback: (UIImage?)->()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            let imageData = NSData(contentsOfURL: url)
            dispatch_async(dispatch_get_main_queue(), {
                if let data = imageData {
                    if let image = UIImage(data: data) {
                        // If image is correct, then return it
                        callback(image)
                        return
                    }
                    else {
                        println("ERROR: Error occurred while creating image from the data: \(data)")
                    }
                }
                // No image - return nil
                callback(nil)
            })
        })
    }
    
    /**
    Load image asynchronously.
    More simple method than loadFromURLAsync() that helps to cover common fail cases
    and allow to concentrate on success loading.
    
    :param: urlString the url string
    :param: callback  the callback to return the image
    */
    class func loadAsync(urlString: String?, callback: (UIImage)->()) {
        if let urlStr = urlString {
            if let url = NSURL(string: urlStr) {
                UIImage.loadFromURLAsync(url, callback: { (image: UIImage?) -> () in
                    if let img = image {
                        callback(img)
                    }
                })
            }
        }
    }
    
    /**
     Convert image to data string
     
     - returns: the string
     */
    func toDataString() -> String? {
        if var data = UIImagePNGRepresentation(self) {
            
            // Resize image if it's too large
            let maxSize = Configuration.sharedConfig.maxImageSize
            if data.length > maxSize { // size exceeds maximum allowed
                // resize image to approximately fit the limit
                let ratio = pow(CGFloat(maxSize) / CGFloat(data.length), 0.75)
                let newImage = self.compressImage(ratio: ratio)
                guard let resizedData = UIImagePNGRepresentation(newImage) else { return nil }
                data = resizedData
            }
            return data.base64EncodedStringWithOptions([])
        }
        return nil
    }
    
    /**
     Convert image to data
     
     - returns: the data
     */
    func toData() -> NSData? {
        if let data = UIImagePNGRepresentation(self) {
            return data
        }
        return nil
    }
    
    /**
     Convert data to image
     
     - parameter data: the data
     
     - returns: the image
     */
    class func fromData(data: NSData?) -> UIImage? {
        if let data = data {
            return UIImage(data: data)
        }
        return nil
    }
    
    /**
     Compresses image size to fit into set max file size limit
     
     - returns: compressed image
     */
    func compressImage(ratio ratio: CGFloat) -> UIImage {
        let image = self
        let size = CGSizeMake(image.size.width * ratio, image.size.height * ratio)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

/**
 * Extenstion adds helpful methods to String
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension String {
    
    /// the length of the string
    var length: Int {
        return self.characters.count
    }
    
    /**
    Get string without spaces at the end and at the start.
    
    - returns: trimmed string
    */
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    /**
    Checks if string contains given substring
    
    - parameter substring:     the search string
    - parameter caseSensitive: flag: true - search is case sensitive, false - else
    
    - returns: true - if the string contains given substring, false - else
    */
    func contains(substring: String, caseSensitive: Bool = true) -> Bool {
        if let _ = self.rangeOfString(substring,
            options: caseSensitive ? NSStringCompareOptions(rawValue: 0) : .CaseInsensitiveSearch) {
                return true
        }
        return false
    }
    
    /**
    Creates attributed string for address labels
    
    - returns: NSMutableAttributedString
    */
    func createAttributedAddressString() -> NSMutableAttributedString {
        let paragrahStyle = NSMutableParagraphStyle()
        paragrahStyle.lineSpacing = 4
        let attributedString = NSMutableAttributedString(string: self, attributes: [
            NSParagraphStyleAttributeName: paragrahStyle
            ])
        return attributedString
    }
    
    /**
    Shortcut method for stringByReplacingOccurrencesOfString
    
    - parameter target:     the string to replace
    - parameter withString: the string to add instead of target
    
    - returns: a result of the replacement
    */
    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString,
            options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    /**
    Replaces all characters that match the given regular string
    
    :param: regularString the regular string
    :param: str           the string to clean up
    
    :returns: a result of the replacement
    */
    public func replaceRegex(regularString: String, withString str: String) -> String {
        if let regex = NSRegularExpression(pattern: regularString, options: NSRegularExpressionOptions.allZeros, error: nil) {
            return regex.stringByReplacingMatchesInString(self, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, count(self)), withTemplate: "")
        }
        return str
    }
    
                    formatter.maximumFractionDigits = 0
    
    /**
    Checks if the string is number
    
    - returns: true if the string presents number
    */
    func isNumber() -> Bool {
        let formatter = NSNumberFormatter()
        if let _ = formatter.numberFromString(self) {
            return true
        }
        return false
    }
    
    /**
    Checks if the string is positive number
    
    - returns: true if the string presents positive number
    */
    func isPositiveNumber() -> Bool {
        let formatter = NSNumberFormatter()
        if let number = formatter.numberFromString(self) {
            if number.doubleValue > 0 {
                return true
            }
        }
        return false
    }
    
    /**
    Get URL encoded string.
    
    - returns: URL encoded string
    */
    public func urlEncodedString() -> String {
        let set = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet;
        set.removeCharactersInString(":?&=@+/'");
        return self.stringByAddingPercentEncodingWithAllowedCharacters(set as NSCharacterSet)!
    }
    
    /**
    Encode current string with Base64 algorithm
    
    - returns: the encoded string
    */
    public func encodeBase64() -> String {
        let utf8str = self.dataUsingEncoding(NSUTF8StringEncoding)
        
        if let base64Encoded = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) {
            return base64Encoded
        }
        return self
    }
    
//    import CommonCrypto
    func sha1() -> String {
        var selfAsSha1 = ""
        
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            var digest = [UInt8](count: Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
            CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
            
            for index in 0..<CC_SHA1_DIGEST_LENGTH {
                selfAsSha1 += String(format: "%02x", digest[Int(index)])
            }
        }
        
        return selfAsSha1
    }

    /**
    Remove html tags
    
    :returns: plain text string
    */
    func getClearText() -> String {
        return self.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
    }
    
    /**
    Truncate string with given length
    
    - parameter length:   the length
    - parameter trailing: the  trailing
    
    - returns: truntacted string
    */
    func truncate(length: Int, trailing: String? = "...") -> String {
        if self.characters.count > length {
            return self.substringToIndex(self.startIndex.advancedBy(length)) + (trailing ?? "")
        } else {
            return self
        }
    }
    
    /**
     Capitalize the string
     
     - returns: capitalized string
     */
    func capitalize() -> String {
        return self.lowercaseString.capitalizedString.replace("Of", withString: "of")
    }
    
    /**
     Get ID from the end of the string
     
     - returns: numeric id
     */
    func getIdAfterSlash() -> String {
        let splited = self.componentsSeparatedByString("/")
        if let last = splited.last {
            return last
        }
        return ""
    }
    
    /**
     Split string with given character
     
     - parameter separator: the separator
     
     - returns: the array of strings
     */
    func split(separator: Character) -> [String] {
         return self.characters.split(separator).map({String($0)})
    }
    
    /**
     Get attributed string with highlighed (bold font) substring
     
     - parameter substring: the substring
     
     - returns: the attributed string
     */
    func getAttributedStringWithBoldSubstring(substring: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self, attributes: [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont(name: Fonts.Regular, size: 16)!
            ])
        if let range = self.rangeOfString(substring,
            options: .CaseInsensitiveSearch) {
                let index: Int = self.startIndex.distanceTo(range.startIndex)
                attributedString.setAttributes(
                    [NSFontAttributeName: UIFont(name: Fonts.Medium, size: 16)!],
                    range: NSMakeRange(index as Int, range.count))
        }
        return attributedString
    }
    
    /**
     Encode string to data
     
     - returns: the data
     */
    func data() -> NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    /**
     Get JSON from resource file
     
     - parameter name:    resource name
     */
    static func resource(named name: String) -> String? {
        guard let resourceUrl = Bundle.main.url(forResource: name, withExtension: "string") else {
            fatalError("Could not find resource \(name)")
        }
        
        // create data from the resource content
        var data: Data
        do {
            data = try Data(contentsOf: resourceUrl, options: Data.ReadingOptions.dataReadingMapped) as Data
        } catch let error {
            print("ERROR: \(error)")
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

/**
 * Shortcut methods for NSDate
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension NSDate {
    
    /**
    Get NSDate that corresponds to the start of current day.
    
    - returns: the date
    */
    func beginningOfDay() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.Day],
            fromDate:self)
        
        return calendar.dateFromComponents(components)!
    }
    
    /**
    Get NSDate that corresponds to the end of current day.
    
    - returns: the date
    */
    func endOfDay() -> NSDate {
        var date = nextDayStart()
        date = date.dateByAddingTimeInterval(-1)
        return date
    }
    
    /**
    Get the next day start
    
    - returns: the date
    */
    func nextDayStart() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.day = 1
        
        let date = calendar.dateByAddingComponents(components, toDate: self.beginningOfDay(),
            options: NSCalendarOptions(rawValue: 0))!
        return date
    }
    
    /**
     Get NSDate that corresponds to the start of current month.
     
     - returns: the date
     */
    func beginningOfMonth() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year],
            fromDate:self)
        
        return calendar.dateFromComponents(components)!
    }
    
    /**
     Get next month date.
     
     - returns: the date
     */
    func nextMonth() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.month = 1
        
        let date = calendar.dateByAddingComponents(components, toDate: self.beginningOfMonth(),
            options: [])!
        return date
    }
    
    /**
    Get previous month date.
    
    :returns: the date
    */
    func previousMonth() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.day = -1
        
        var date = calendar.dateByAddingComponents(components, toDate: self.beginningOfMonth(),
            options: NSCalendarOptions.allZeros)!
        return date
    }
    
    /**
    Add days to the date
    
    - parameter daysToAdd: the number of days to add
    
    - returns: changed date
    */
    func addDays(daysToAdd: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.day = daysToAdd
        
        let date = calendar.dateByAddingComponents(components, toDate: self, options: NSCalendarOptions())!
        return date
    }
    
    /**
    Add minutes to the date
    
    - parameter minutesToAdd: the number of minutes to add
    
    - returns: changed date
    */
    func addMinutes(minutesToAdd: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.minute = minutesToAdd
        
        let date = calendar.dateByAddingComponents(components, toDate: self, options: NSCalendarOptions(rawValue: 0))!
        return date
    }
    
    /**
    Compares current date with the given one down to the seconds.
    If date==nil, then always return false
    
    :param: date date to compare or nil
    
    :returns: true if the dates has equal years, months, days, hours, minutes and seconds.
    */
    func sameDate(date: NSDate?) -> Bool {
        if let d = date {
            let calendar = NSCalendar.currentCalendar()
            if NSComparisonResult.OrderedSame == calendar.compareDate(self, toDate: d, toUnitGranularity: NSCalendarUnit.SecondCalendarUnit) {
                return true
            }
            
        }
        return false
    }
    
    /**
     Get today date with current date time.
     
     - returns: today date that has same hour, minutes and seconds.
     */
    func todayTime() -> NSDate {
        
        let calendar = NSCalendar.currentCalendar()
        
        let dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year],
            fromDate: NSDate())
        
        let timeComponents = calendar.components([NSCalendarUnit.Minute, NSCalendarUnit.Hour, NSCalendarUnit.Second],
            fromDate: self)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.second = timeComponents.second
        return calendar.dateFromComponents(dateComponents)!
    }
    
    /**
     Check if the given date is in the scope of the given today (!) start and end time.
     Scope is not inclusive.
     
     - parameter date:  the tested date
     - parameter start: the start time of the interval for today
     - parameter end:   the end time of the interval for today
     
     - returns: true - if the date is in the scope of the given today start and end time, false - else
     */
    func isInTimeScope(date: NSDate, start: NSDate, end: NSDate) -> Bool {
        let todayStart = start.todayTime()
        let todayEnd = end.todayTime()
        if todayEnd.isAfter(todayStart) {
            if date.isAfter(todayStart) && todayEnd.isAfter(date) {
                return true
            }
        }
        else { // the time scope cover midnight
            if date.isAfter(todayStart) || todayEnd.isAfter(date) {
                return true
            }
        }
        return false
    }
    
    /**
    Check if current date is after the given date
    
    - parameter date: the date to check
    
    - returns: true - if current date is after
    */
    func isAfter(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedDescending
    }
    
    /**
     Check if the date corresponds to the same day
     
     - parameter date: the date to check
     
     - returns: true - if the date has same year, month and day
     */
    func isSameDay(date:NSDate) -> Bool {
        let date1 = self
        let calendar = NSCalendar.currentCalendar()
        let comps1 = calendar.components([.Month, .Year, .Day], fromDate:date1)
        let comps2 = calendar.components([.Month, .Year, .Day], fromDate:date)
        
        return (comps1.day == comps2.day) && (comps1.month == comps2.month) && (comps1.year == comps2.year)
    }
    
    /**
     Parse full date string, e.g. 2014-11-17T19:39:12
     
     - parameter string: the date string
     
     - returns: date object or nil
     */
    class func parseFullDate(string: String) -> NSDate? {
        var stringToParse = string
        struct Static {
            static var dateParser: NSDateFormatter = {
                let f = NSDateFormatter()
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // if hours are [0-23]
                f.locale = NSLocale.currentLocale()
                return f
            }()
            
            /// the length of the date string
            static var dateStringLength = 19
        }
        
        stringToParse = stringToParse.substringToIndex(stringToParse.startIndex.advancedBy(Static.dateStringLength))
        return Static.dateParser.dateFromString(stringToParse)
    }
    
    /**
     Parse full date string, e.g. 2015-10-16T15:56:51.000+0000
     
     - parameter string: the date string
     
     - returns: date object or nil
     */
    class func parseFullDate(string: String) -> NSDate? {
        struct Static {
            static var dateParser: NSDateFormatter = {
                let f = NSDateFormatter()
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // if hours are [0-23]
                
                yyyy-MM-dd'T'HH:mm:ssZ  / 19+6 -> 2015-10-16T15:56:51+0000
                
                f.locale = NSLocale.currentLocale()
                return f
            }()
            static var dateStringLength = 19 + 9
        }
        
        var stringToParse = string
        if string.length > Static.dateStringLength {
            stringToParse = string.substringToIndex(string.startIndex.advancedBy(Static.dateStringLength))
        }
        return Static.dateParser.dateFromString(stringToParse)
    }

    /**
    Parse date string, e.g. 2014-11-17
    
    - parameter string: the date string
    
    - returns: date object or nil
    */
    class func parseDate(string: String) -> NSDate? {
        struct Static {
            static var dateParser: NSDateFormatter = {
                let f = NSDateFormatter()
                f.dateFormat = "yyyy-MM-dd"
                f.locale = NSLocale.currentLocale()
                return f
                }()
            static var dateStringLength = 10
        }
        
        let stringToParse = string.substringToIndex(string.startIndex.advancedBy(Static.dateStringLength))
        return Static.dateParser.dateFromString(stringToParse)
    }
    
    /**
    Is given date is of the same week
    
    - returns: true - if this day relates to the same week, false - else
    */
    func isTheSameWeekAsForDate(testDate: NSDate) -> Bool {
        return testDate.getNextSunday().isAfter(self)
    }
    
    /**
     Get Sunday
     
     - returns: the next Sunday end or current day end if today is Sunday
     */
    func getNextSunday() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Weekday], fromDate: self)
        let sundayWeekDayNumber = 1
        if comp.weekday == sundayWeekDayNumber {
            return self.endOfDay()
        }
        else {
            comp.weekday = sundayWeekDayNumber
            let date = calendar.dateFromComponents(comp)!.endOfDay()
            if date.isAfter(self) {
                return date
            }
            else {
                // adding one week because Sunday is the first day of the week and we need to handle it as the last
                return date.addDays(7)
            }
        }
    }
    
    /**
     Convert time from the date to duration string, e.g. 1hr 20m
     
     - returns: the string representation
     */
    func toDurationString() -> String {
        if let h = Int(DateFormatters.durationFormatterHour.stringFromDate(self)),
            let m = Int(DateFormatters.durationFormatterMinute.stringFromDate(self)) {
                if h > 0 || m > 0 {
                    let hStr = (h > 0 ? (String(h) + (h > 1 ? "hrs" : "hr")) : "")
                    let mStr = (m > 0 ? (String(m) + "min") : "")
                    return (hStr + " " + mStr).trim()
                }
                else {
                    return "0"
                }
        }
        return "-"
    }
    
    /**
     Convert time from the date to duration in minutes
     
     - returns: the string representation
     */
    func toDuration() -> Int {
        if let h = Int(DateFormatters.durationFormatterHour.stringFromDate(self)),
            let m = Int(DateFormatters.durationFormatterMinute.stringFromDate(self)) {
                return h * 60 + m
        }
        return 0
    }
    
    /**
     Get date with time that corresponds to given number of minutes
     
     - parameter minutes: the minutes
     
     - returns: the date
     */
    class func fromDuration(minutes minutes: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([.Month, .Year, .Day],
            fromDate: NSDate())
        components.hour = minutes / 60
        components.minute = minutes % 60
        
        return calendar.dateFromComponents(components)!
    }
    
    /**
     Get number of months since current date till now
     
     - returns: the number of months
     */
    func monthsSinceDate() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([.Month], fromDate:self, toDate: NSDate(), options: [])
        return dateComponents.month
    }
    
    /**
     Check if date occured given number of days before
     
     - parameter nDaysBefore: the tested number of days
     
     - returns: true - if current date is N days before
     */
    func occuredDaysBeforeToday(nDaysBefore: Int) -> Bool {
        
        let now = NSDate()
        let today = now.beginningOfDay()
        let comp = NSDateComponents()
        comp.day = -nDaysBefore      // lets go N days back from today
        let before = NSCalendar.currentCalendar().dateByAddingComponents(comp, toDate: today, options: [])!
        if self.compare(before) == .OrderedDescending {
            if self.compare(now) == .OrderedAscending {
                return true
            }
        }
        return false
    }
    
    func daysAgo() -> String {
        if self.occuredDaysBeforeToday(0) {
            return "Today"
        }
        else if self.occuredDaysBeforeToday(1) {
            return "Yesterday"
        }
        else if self.occuredDaysBeforeToday(7) {
            return "This week"
        }
        else if self.occuredDaysBeforeToday(14) {
            return "1 week ago"
        }
        else if self.occuredDaysBeforeToday(21) {
            return "2 weeks ago"
        }
        else {
            return "month ago"
        }
    }
}

extension Bool {
    
    /**
    Get random boolean value.
    
    :returns: random value
    */
    static func random() -> Bool {
        return arc4random_uniform(10) > 5
    }
}

/**
 * Extenstion adds helpful methods to Int
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension Int {
    
    /**
     Get uniform random value between 0 and maxValue
     
     - parameter maxValue: the limit of the random values
     
     - returns: random Int
     */
    public static func random(maxValue: Int) -> Int {
        return Int(arc4random_uniform(UInt32(maxValue)))
    }
    
    /**
    Returns string to show as a currency.
    Examples: 1230 -> "1,230"
    
    :returns: string
    */
    func currencyValue() -> String {
        return NSString.localizedStringWithFormat("%d", self) as String
    }
}

/**
 * Extenstion adds helpful methods to Float
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension Float {
    
    /**
     Format as string
     
     - returns: string
     */
    func toString() -> String {
        return NSString.localizedStringWithFormat("%.1f", self) as String
    }
    
    /**
     Format as string
     
     - returns: string
     */
    func toCurrencyString() -> String {
        if value.isInteger() {
            return NSString.localizedStringWithFormat("%.f", round(self)) as String
        }
        else {
            return NSString.localizedStringWithFormat("%.2f", value) as String
        }
    }
    
    /**
    Get uniform random value between 0 and maxValue
    
    - parameter maxValue: the limit of the random values
    
    - returns: random Float
    */
    static func random(maxValue: UInt32) -> Float {
        let floating: UInt32 = 100
        return Float(arc4random_uniform(maxValue * floating)) / Float(floating)
    }
    
    /**
    Get uniform random value between 0 and maxValue and randomly use integer or float value
    
    :param: maxValue the limit of the random values
    
    :returns: random Float
    */
    static func randomForDemo(maxValue: UInt32) -> Float {
        return Int.random(2) > 0 ? Float.random(10) : Float(Int.random(10))
    }
    
    /**
     Check if the value is integer
     
     - returns: true - if integer value, false - else
     */
    func isInteger() -> Bool {
        if self > Float(Int.max)
            || self < Float(Int.min) {
                print("ERROR: the value can not be converted to Int because it is greater/smaller than Int.max/min")
                return false
        }
        return  self == Float(Int(self))
    }
    
    /**
    Returns string to show as a currency.
    For dollar values, all stats that are less than $1 should be rounded to the nearest 10 cents.
    Examples: 1.23 -> "1", "0.53" -> "0.5", "0.98" -> "1.0", "4.0 -> "4"
    
    :returns: string
    */
    func currencyString() -> String {
        if self >= 1  || self == 0 {
            return NSString.localizedStringWithFormat("%.f", round(self)) as String
        }
        else {
            let value = round(self * 10) / 10
            return NSString.localizedStringWithFormat("%.1f", value) as String
        }
    }
    
    /**
    Rounds the value according to the rules:
    Rounding should always be done to the nearest whole number unless the numbers is less than 1.
    If it’s larger than .05 then round to the tenth.
    If it’s smaller than .05 but larger than .005 then round to the hundredth.
    If it’s smaller than .005, then it should be zero.
    
    :returns: string representation of the rounded value
    */
    func smartRounding() -> String {
        if self >= 1 {
            return NSString.localizedStringWithFormat("%.f", round(self)) as String
        }
        else if self > 0.05 {
            let value = round(self * 10) / 10
            return NSString.localizedStringWithFormat("%.1f", value) as String
        }
        else if self > 0.005 {
            let value = round(self * 100) / 100
            return NSString.localizedStringWithFormat("%.2f", value) as String
        }
        else {
            return "0"
        }
    }
    
    /**
    Rounds the value to quarter.
    Examples: 12.03->12, 3.46->3.25, 0.77->0.75
    
    :returns: the rounded value
    */
    func quarterFloor() -> Float {
        if isInteger() {
            return self
        }
        else {
            return floor(self * 4) / 4
        }
    }
    /**
    Rounds the value to quarter.
    Examples: 12.03->12, 3.46->3.25, 0.77->0.75
    
    :returns: string representation of the rounded value
    */
    func quarterString() -> String {
        let value = quarterFloor()
        if value.isInteger() {
            return NSString.localizedStringWithFormat("%.f", round(self)) as String
        }
        else if value % floor(value) == 0.5 {
            return NSString.localizedStringWithFormat("%.1f", value) as String
        }
        else {
            return NSString.localizedStringWithFormat("%.2f", value) as String
        }
    }
    
    /**
    Rounds the value using next rules:
    0.002 -> 0 // < 0.005
    0.034 -> 0.034 // < 0.05
    0.056 -> 0.6 // < 1
    7.8 -> 8 // < 1000
    1000 -> 0.1K // 1 < x < 1000000
    100000000 -> 100M // > 1000000
    
    :returns: string representation of the rounded value
    */
    func letterRounding() -> String {
        if self < 1000 {
            return smartRounding()
        }
        else if self < 1000000 { // *k
            let value = self/1000
            return value.smartRounding() + "k"
        }
        else if self < 1000000000 { // *M
            let value = self/1000000
            return value.smartRounding() + "M"
        }
        else { // *G
            let value = self/1000000000
            return value.smartRounding() + "G"
        }
    }
    
    /**
    Do the same as letterRounding but return digits and letters separatly.
    Used for rounding dollars on map markers.
    "G" for values grader than 1000000000 is replaced with "B"
    
    :returns: tuple: (digits, letters), e.g. (100, "k"), (3, "M"), (450, "B")
    */
    func letterRoundingSeparatedDollar() -> (String, String) {
        // using currencyString because it's dollar rounding
        if self < 1000 {
            return (currencyString(), "")
        }
        else if self < 1000000 { // *k
            let value = self/1000
            return (value.smartRounding(), "k")
        }
        else if self < 1000000000 { // *M
            let value = self/1000000
            return (value.smartRounding(), "M")
        }
        else { // *G
            let value = self/1000000000
            return (value.smartRounding(), "B")
        }
    }
    
    /**
    Do the same as letterRounding but return digits and letters separatly.
    Used for rounding kWatts.
    
    :returns: tuple: (digits, letters), e.g. (5, "Wh"), (100, "kWh"), (3, "MWh"), (450, "GWh")
    */
    func letterRoundingSeparatedKWatts() -> (String, String) {
        // using currencyString because it's dollar rounding
        if self < 1000 {
            return (currencyString(), "Wh")
        }
        else if self < 1000000 { // *k
            let value = self/1000
            return (value.smartRounding(), "kWh")
        }
        else if self < 1000000000 { // *M
            let value = self/1000000
            return (value.smartRounding(), "MWh")
        }
        else { // *G
            let value = self/1000000000
            return (value.smartRounding(), "GWh")
        }
    }
}

/**
Check if iPhone5 like device

- returns: true - if this device has width as on iPhone5, false - else
*/
func isIPhone5() -> Bool {
    return UIScreen.mainScreen().nativeBounds.width == 640
}

/**
Check if iPhone6+ device

- returns: true - if this device has width as on iPhone6+, false - else
*/
func isIPhone6Plus() -> Bool {
    return UIScreen.mainScreen().nativeBounds.width == 1242
}

// pad check
let isIPad = UIDevice.currentDevice().userInterfaceIdiom == .Pad

/**
Delays given callback invocation

- parameter delay:    the delay in seconds
- parameter callback: the callback to invoke after 'delay' seconds
*/
func delay(delay: NSTimeInterval, callback: ()->()) {
    let delay = delay * Double(NSEC_PER_SEC)
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay));
    dispatch_after(popTime, dispatch_get_main_queue(), {
        callback()
    })
}

/**
Shows an alert with the title and message.

:param: title   the title
:param: message the message
*/
func showAlert(title: String, _ message: String) {
    let myAlertView = UIAlertView()
    myAlertView.title = title
    myAlertView.message = message
    myAlertView.addButtonWithTitle("OK".localized())
    myAlertView.show()
}

/**
 Shows an alert with the title and message.
 
 - parameter title:      the title
 - parameter message:    the message
 - parameter completion: the completion callback
 */
func showAlert(title: String, message: String, completion: (()->())? = nil) {
    UIViewController.getCurrentViewController()?.showAlert(title, message, completion: completion)
}

/**
 Show alert with given error message
 
 - parameter errorMessage: the error message
 - parameter completion:   the completion callback
 */
func showError(errorMessage: String, completion: (()->())? = nil) {
    showAlert(NSLocalizedString("Error", comment: "Error alert title"), message: errorMessage, completion: completion)
}

/**
Show alert message about stub functionalify
*/
func showStub() {
    showAlert("Stub", message: "This feature will be implemented in future")
}

extension String  {
    
add #import <CommonCrypto/CommonCrypto.h> in bridging header
    
    /// MD5 hash sum for the string
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.dealloc(digestLen)
        
        return hash as String
    }
    
    func contains(find: String) -> Bool{
        if let temp = self.rangeOfString(find){
            return true
        }
        return false
    }
}

/**
 * Helpful shortcur methods for getting custom fonts
 *
 * @author TCASSEMBLER
 * @version 1.0
 */
extension UIFont {
    
    /**
    Gets medimum font
    
    :param: size The size
    
    :returns: the font
    */
    class func mediumOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: size)!
    }
    
    /**
    Gets light font
    
    :param: size The size
    
    :returns: the font
    */
    class func lightOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: size)!
    }
    
    /**
    Gets thin font
    
    :param: size The size
    
    :returns: the font
    */
    class func thinOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Thin", size: size)!
    }
    
    /**
    Returns the size of the string
    
    :param: string the string to measure.
    :param: width  the width of the string.
    
    :returns: the size of the string
    */
    func sizeOfString(string: String, constrainedToWidth width: CGFloat) -> CGSize {
        return string.boundingRectWithSize(CGSize(width: width, height: CGFloat.max),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self],
            context: nil).size
    }
}

/**
*  Helper class for regular expressions
*
* @author Alexander Volkov
* @version 1.0
*/
class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)!
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: nil,
            range:NSMakeRange(0, count(input)))
        return matches.count > 0
    }
}

// Define operator for simplisity of Regex class
infix operator ≈ { associativity left precedence 140 }
func ≈(input: String, pattern: String) -> Bool {
    return Regex(pattern).test(input)
}

NSBundle(forClass: MockData.self)

let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
NSUserDefaults.standardUserDefaults().setObject(version, forKey: "buildNumber")
NSUserDefaults.standardUserDefaults().setObject(Configuration.sharedConfig.apiBaseUrl, forKey: "apiBase")
NSUserDefaults.standardUserDefaults().synchronize()

func dateParser() {
    struct Static {
        static var dateParser: NSDateFormatter = {
            let f = NSDateFormatter()
            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // if hours are [0-23]
            f.locale = NSLocale.currentLocale()
            return f
            }()
        static var dateStringLength = 19
    }
    
    var dateString = "2014-11-17T19:39:12Z"
    dateString = dateString.substringToIndex(advance(dateString.startIndex, Static.dateStringLength))
    if let date = Static.dateParser.dateFromString(dateString) {
        println("\(date)")
    }
    else {
        println("no date")
    }
}

NSLocale(localeIdentifier: "en_US_POSIX")

extension NSTimeInterval {
    
    /**
    Get string representation of the time, e.g. 90 -> "1:30"
    
    :returns: string
    */
    func getTime() -> String {
        if self.isNaN {
            return "--:--"
        }
        let minutes = Int(floor(self / 60))
        var minStr = "\(minutes)"
        if minutes < 10 {
            minStr = "0" + minStr
        }
        let seconds = Int(self) - minutes * 60
        var secStr = "\(seconds)"
        if seconds < 10 {
            secStr = "0" + secStr
        }
        return "\(minStr):\(secStr)"
    }
}

/**
 * Shortcut methods for NSDate
 *
 * - author:  TCASSEMBLER
 * - version: 1.0
 */
extension NSDate {
    
    /**
    Returns now many hours, minutes, etc. the date is from now.
    
    - parameter separator: the separator used between number and text
    
    - returns: string, e.g. "5d ago"
    */
    func timeToNow(separator: String = "") -> String {
        let timeInterval = NSDate().timeIntervalSinceDate(self)
        
        let days = Int(floor(timeInterval / (3600 * 24)))
        let hours = Int(floor((timeInterval % (3600 * 24)) / 3600))
        let minutes = Int(floor((timeInterval % 3600) / 60))
        let seconds = Int(timeInterval % 60)
        
        if days > 0 { return "\(days)\(separator)"
            + (days == 1 ? "DAY_AGO".localized() : "DAYS_AGO".localized()) }
        if hours > 0 { return "\(hours)\(separator)"
            + (hours == 1 ? "HOUR_AGO".localized() : "HOURS_AGO".localized()) }
        if minutes > 0 { return "\(minutes)\(separator)"
            + (minutes == 1 ? "MIN_AGO".localized() : "MINS_AGO".localized()) }
        if seconds > 0 { return "\(seconds)\(separator)"
            + (seconds == 1 ? "SEC_AGO".localized() : "SECS_AGO".localized()) }
        return "JUST_NOW".localized()
    }
    
    /**
     Returns now many years, months, days is left
     
     - returns: string, e.g. "5 years, 6 months"
     */
    func left() -> String {
        let calendar = NSCalendar.currentCalendar()
        
        var fromDate: NSDate?, toDate: NSDate?
        
        calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: NSDate())
        calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: self)
        
        //        let dayDiff = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: [])
        //        let days = dayDiff.day
        let monthDiff = calendar.components(.Month, fromDate: fromDate!, toDate: toDate!, options: [])
        let month = monthDiff.month
        let yearDiff = calendar.components(.Year, fromDate: fromDate!, toDate: toDate!, options: [])
        let year = yearDiff.year
        
        var strs = [String]()
        if year > 0 { strs.append("\(year)" + (year == 1 ? "year" : "yeas")) }
        if month > 0 { strs.append("\(month)" + (month == 1 ? "month" : "months")) }
        //        if days > 0 { strs.append("\(days)" + (days == 1 ? "day" : "days")) }
        return strs.joinWithSeparator(", ")
    }
    
    /**
     Returns now many months, days, hours and minutes is left
     
     - returns: string, e.g. "6 months, 1d 2h 3m"
     */
    func left(extendedVersion: Bool = false) -> String {
        let calendar = NSCalendar.currentCalendar()
        
        var fromDate: NSDate?, toDate: NSDate?
        
        calendar.rangeOfUnit(.Minute, startDate: &fromDate, interval: nil, forDate: NSDate())
        calendar.rangeOfUnit(.Minute, startDate: &toDate, interval: nil, forDate: self)
        
        let diff = calendar.components([.Minute, .Hour, .Day, .Month, .Year], fromDate: NSDate(), toDate: self, options: [])
        let minute = diff.minute
        let hour = diff.hour
        let days = diff.day
        let month = diff.month
        
        let mSuffix = extendedVersion ? (minute > 1 ? " Minutes": " Minute") : "m"
        let hSuffix = extendedVersion ? (minute > 1 ? " Hours": " Hour") : "h"
        let dSuffix = extendedVersion ? (minute > 1 ? " Days": " Day") : "d"
        let monSuffix = extendedVersion ? (minute > 1 ? " Months": " Month") : (minute > 1 ? " months": " month")
        
        let mStr = (minute > 0 ? (String(minute) + mSuffix) : "")
        let hStr = (hour > 0 ? (String(hour) + hSuffix) : "")
        let dStr = (days > 0 ? (String(days) + dSuffix) : "")
        let monStr = (month > 0 ? (String(month) + monSuffix) : "")
        
        let str = (monStr + " " + dStr + " " + hStr + " " + mStr).trim()
        if str.isEmpty {
            return "-"
        }
        return str.replace("  ", withString: " ")
    }
    
    /**
     Returns now many years, months or days is passed
     
     - returns: string, e.g. "5 years" or "6 months" or "1 day"
     */
    func passed() -> String {
        let calendar = NSCalendar.currentCalendar()
        
        var fromDate: NSDate?, toDate: NSDate?
        
        calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: self)
        calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: NSDate())
        
        let dayDiff = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: [])
        let days = dayDiff.day
        let monthDiff = calendar.components(.Month, fromDate: fromDate!, toDate: toDate!, options: [])
        let month = monthDiff.month
        let yearDiff = calendar.components(.Year, fromDate: fromDate!, toDate: toDate!, options: [])
        let year = yearDiff.year
        
        if year > 0 { return "\(year) " + (year == 1 ? "year" : "years") }
        if month > 0 { return "\(month) " + (month == 1 ? "month" : "months") }
        if days > 0 { return "\(days) " + (days == 1 ? "day" : "days") }
        return "-"
        
        //        var strs = [String]() // dodo
        //        if year > 0 { strs.append("\(year) " + (year == 1 ? "year" : "years")) }
        //        if month > 0 { strs.append("\(month) " + (month == 1 ? "month" : "months")) }
        //        if days > 0 { strs.append("\(days) " + (days == 1 ? "day" : "days")) }
        //        return strs.joinWithSeparator(", ")
    }
    
    /**
     Returns now many hours, minutes, etc. the date is from now.
     
     - returns: string, e.g. "5 hours ago"
     */
    func timeToNow() -> String {
        let timeInterval = NSDate().timeIntervalSinceDate(self)
        
        let weeks = Int(floor(timeInterval / (7 * 3600 * 24)))
        let days = Int(floor(timeInterval / (3600 * 24)))
        let hours = Int(floor((timeInterval % (3600 * 24)) / 3600))
        let minutes = Int(floor((timeInterval % 3600) / 60))
        let seconds = Int(timeInterval % 60)
        
        if weeks > 0 { return weeks == 1 ? "\(weeks) " + "week ago" : "\(weeks) " + "weeks ago" }
        if days > 0 { return days == 1 ? "\(days) " + "day ago" : "\(days) " + "days ago" }
        if hours > 0 { return hours == 1 ? "\(hours) " + "hour ago" : "\(hours) " + "hours ago" }
        if minutes > 0 { return minutes == 1 ? "\(minutes) " + "minute ago" : "\(minutes) " + "minutes ago" }
        if seconds > 0 { return seconds == 1 ? "\(seconds) " + "second ago" : "\(seconds) " + "seconds ago" }
        return "Now"
    }
}

localized >>
// Time labels
"DAY_AGO"="day ago";
"DAYS_AGO"="days ago";
"HOUR_AGO"="hr ago";
"HOURS_AGO"="hrs ago";
"MIN_AGO"="min ago";
"MINS_AGO"="mins ago";
"SEC_AGO"="sec ago";
"SECS_AGO"="sec ago";
"JUST_NOW"="Just now";


/**
 * Helpful extension for arrays
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension Array {
    
    /**
     Convert array to hash array
     
     - parameter transform: the transformation of an object to a key
     
     - returns: a hashmap
     */
    func hashmapWithKey<K>(transform: (Element) -> (K)) -> [K:Element] {
        var hashmap = [K:Element]()
        
        for item in self {
            let key = transform(item)
            hashmap[key] = item
        }
        return hashmap
    }
    
    /**
     Convert array to hash array
     
     - parameter transform: the transformation of an object to a key
     
     - returns: a hashmap with arrays as values
     */
    func hasharrayWithKey<K>(transform: (Element) -> (K)) -> [K:[Element]] {
        var hashmap = [K:[Element]]()
        
        for item in self {
            let key = transform(item)
            var a = hashmap[key]
            if a == nil {
                a = [Element]()
            }
            a!.append(item)
            hashmap[key] = a
        }
        return hashmap
    }
}

/**
 * Helpful extension for arrays
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension Array where Element: Equatable {
    
    /**
     Get unique elements
     
     - returns: the list with unique element from this array
     */
    func unique() -> [Element] {
        var list = [Element]()
        for item in self {
            if !list.contains(item) {
                list.append(item)
            }
        }
        return list
    }
}

// Hashable, Equatable

/// unique hash used to upload video after offline mode
var uniqueHash: Int {
    let h1 = (31 &* diveNumber.hashValue) &+ height.hashValue
    let h2 = (31 &* h1) &+ divingBoardType.hashValue
    let h3 = (31 &* h2) &+ rating.hashValue
    return h3
}

/// hash value
var hashValue: Int {
    var hash = name.hashValue
    if let phone = phone {
        hash = (31 &* hash) &+ phone.hashValue
    }
    if let email = email {
        hash = (31 &* hash) &+ email.hashValue
    }
    if let username = username {
        hash = (31 &* hash) &+ username.hashValue
    }
    return hash
}
/**
 Equatable protocol implementation
 
 - parameter lhs: the left object
 - parameter rhs: the right object
 
 - returns: true - if objects are equal, false - else
 */
public func == (lhs: ABSFWholesalerAccount, rhs: ABSFWholesalerAccount) -> Bool {
    return lhs.accountId == rhs.accountId
}

/**
 Check if something was activated for the first time
 
 - parameter key: the key for the event/action
 
 - returns: true - if need to do something extra as this is the first time, false - else
 */
func isFirstTime(key: String) -> Bool {
    if NSUserDefaults.standardUserDefaults().boolForKey(key) {
        return false
    }
    return true
}

/**
Updates NSUserDefaults and saves a flag to mark that corresponding event is not first time
 
 - parameter key: the key for the event/action
 */
func updateNotFirstTime(key: String) {
    NSUserDefaults.standardUserDefaults().setObject(true, forKey: key)
    NSUserDefaults.standardUserDefaults().synchronize()
}

/**
creates thumb from video

- parameter videoURL: video URL

- returns: frame at video middle time
*/
func thumbnailImageForVideo(videoURL: NSURL) -> UIImage? {
    
    // load asset
    let asset = AVURLAsset(URL:videoURL, options:nil)
    
    // load image generator
    let assetIG = AVAssetImageGenerator(asset: asset)
    assetIG.appliesPreferredTrackTransform = true
    assetIG.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels
    
    var thumbnailImageRef: CGImageRef?
    var igError: NSError?
    do {
        // copy at half time
        if #available(iOS 7.1, *) {
            thumbnailImageRef = try assetIG.copyCGImageAtTime(CMTimeMultiplyByRatio(asset.duration, 1, 2), actualTime: nil)
        } else {
            return nil
        }
    } catch let error as NSError {
        igError = error
        thumbnailImageRef = nil
    }
    
    if thumbnailImageRef == nil {
        print("failed to generate video thumb \(igError?.localizedDescription)")
        return nil
    }
    
    return UIImage(CGImage: thumbnailImageRef!)
}

/**
 * Helpful extension
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension NSError {
    
    /**
    Show the error as alert
    */
    func showError() {
        if code != NSURLErrorNotConnectedToInternet  {
            showAlert("Error".localized(), message: self.localizedDescription)
        } else {
            AppDelegate.sharedInstance().showNetworkUnavailable()
        }
    }
    
}

/**
 * Dictionary Extension
 * Some useful functions added to Dictionary class
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension Dictionary {
    
    /**
     Create url string from Dictionary
     
     - Returns: the url string
     */
    func toURLString() -> String {
        var urlString = ""
        
        // Iterate all key,value and form the url string
        for (key, value) in self {
            let keyEncoded = (key as! String).stringByAddingPercentEncodingWithAllowedCharacters(
                .URLHostAllowedCharacterSet())!
            let valueEncoded = (value as! String).stringByAddingPercentEncodingWithAllowedCharacters(
                .URLHostAllowedCharacterSet())!
            urlString += ((urlString == "") ? "" : "&") + keyEncoded + "=" + valueEncoded
        }
        return urlString
    }
}




/**
 * Shortcut methods
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension NSMutableAttributedString {
    
    /**
     Adds link in given range and applies style from design
     
     - parameter url:   the URL for the link
     - parameter range: the range in which to add the link
     */
    func addLink(url url: String, inRange range: NSRange) {
        self.addAttribute(NSLinkAttributeName, value: url, range: range)
        self.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: range)
        self.addAttribute(NSForegroundColorAttributeName, value: UIColor.gray(), range: range)
    }
    
    /**
     Adds underline
     */
    func addUnderline() {
        self.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSMakeRange(0, self.string.length))
    }
}

// NSAttributedString

/**
 Update string with Privacy Policy and Terms of Service
 */
func updatePolicyAndTerms() {
    let font1 = UIFont(name: "AvenirLTStd-Book", size: 14.5)!
    let font2 = UIFont(name: "AvenirLTStd-Heavy", size: 14.5)!
    
    let s1 = "By signing up, you are agreeing to the "
    let s2 = "Privacy Policy"
    let s3 = " and the "
    let s4 = "Terms of Service"
    let s5 = "."
    
    let paragrahStyle = NSMutableParagraphStyle()
    paragrahStyle.lineSpacing = 2.5
    paragrahStyle.alignment = .Justified
    
    let string = NSMutableAttributedString(string: s1 + s2 + s3 + s4 + s5, attributes: [
        NSFontAttributeName: font1,
        NSForegroundColorAttributeName: UIColor.blackText(),
        NSParagraphStyleAttributeName: paragrahStyle
        ])
    
    let range1 = NSMakeRange(s1.length, s2.length)
    let range2 = NSMakeRange(s1.length + s2.length + s3.length, s4.length)
    let boldAttributes = [
        NSFontAttributeName: font2,
        NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
    ]
    string.addAttributes(boldAttributes, range: range1)
    string.addAttributes(boldAttributes, range: range2)
    
    termsLabel.attributedText = string
}


 /// /// /// /// /// /// /// /// /// /// /// AppDelegate.swift

/// the singleton
class var sharedInstance: AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
}

// flag: true - all orientations supported, false - else
var allowAllOrientations = false
/**
Get supported orientations

- parameter application: the application
- parameter window:      the window

- returns: UIInterfaceOrientationMask
*/
func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) ->
    UIInterfaceOrientationMask {
        if self.allowAllOrientations {
            return UIInterfaceOrientationMask.All
        }
        return .Landscape
}
 /// /// /// /// /// /// /// /// /// /// ///


/**
* Helpful methods for NSMutableAttributedString
*
* - author: TCASSEMBLER
* - version: 1.0
*/
extension NSMutableAttributedString {
    
    /**
     Append given string with given font and color
     
     - parameter string: the string
     - parameter font:   the font
     - parameter color:  the color
     
     - returns: self
     */
    func append(string: String, font: UIFont? = nil, color: UIColor? = nil) -> NSMutableAttributedString {
        
        var attributes = [String: AnyObject]()
        if let font = font {
            attributes[NSFontAttributeName] = font
        }
        if let color = color {
            attributes[NSForegroundColorAttributeName] = color
        }
        let str = NSAttributedString(string: string, attributes: attributes.isEmpty ? nil : attributes)
        self.appendAttributedString(str)
        return self
    }
}

self.animationTimer?.invalidate()
self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(self.TREES_ANIMATION_INTERVAL,
    target: self,
    selector: Selector("animateTrees"),
    userInfo: nil, repeats: true)

/**
 * Helpful methods in UILabel
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension UILabel {
    
    /**
     Updates line spacing in the label
     
     - parameter lineSpacing: the linespacing
     */
    func setLineSpacing(lineSpacing: CGFloat) {
        let paragrahStyle = NSMutableParagraphStyle()
        paragrahStyle.lineSpacing = lineSpacing
        paragrahStyle.alignment = self.textAlignment
        let attributedString = NSMutableAttributedString(string: self.text ?? "", attributes: [
            NSParagraphStyleAttributeName: paragrahStyle,
            NSForegroundColorAttributeName: self.textColor,
            NSFontAttributeName: UIFont(name: self.font.fontName, size: self.font.pointSize)!
            ])
        self.attributedText = attributedString
    }
    
    /**
     Updates letter spacing in the label
     
     - parameter letterSpacing: the letter spacing
     */
    func setLetterSpacing(letterSpacing: CGFloat) {
        let attributedString = NSMutableAttributedString(string: self.text ?? "", attributes: [
            NSKernAttributeName: letterSpacing,
            NSForegroundColorAttributeName: self.textColor,
            NSFontAttributeName: UIFont(name: self.font.fontName, size: self.font.pointSize)!
            ])
        self.attributedText = attributedString
    }
    
    /**
     Add strike line
     */
    func addStrikeLine() {
        let attributedString = NSMutableAttributedString(string: self.text ?? "", attributes: [
            NSForegroundColorAttributeName: self.textColor,
            NSFontAttributeName: UIFont(name: self.font.fontName, size: self.font.pointSize)!,
            NSStrikethroughStyleAttributeName: 1
            ])
        self.attributedText = attributedString
    }
}


/**
 * Date and time formatters
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
struct DateFormatters {
    
    /// minutes formetter
    static var durationFormatterMinute: NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "mm"
        return f
    }()
    
    /// date formetter (hours only)
    static var dateAndHours: NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "EEE, MMM d, h"
        return f
    }()
    
    /// date and time formetter
    static var dateHoursAndMinutes: NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "EEE, MMM d, h:mm"
        return f
    }()
    
    /// date formetter
    static var date: NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "EEE, MMM d, yyyy"
        return f
    }()
    
    /// time formetter (hours only)
    static var hours: NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "h"
        return f
    }()
    
    /// time formetter
    static var hoursAndMinutes: NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "h:mm"
        return f
    }()
    
    /// date formetter
    static var amPm: NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "a"
        return f
    }()
}

/**
 * Shortcut methods for NSDate
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
extension NSDate {
    
    /**
     Check if minutes are zero
     
     - returns: true - if minutes == 0, false - else
     */
    func hasZeroMinutes() -> Bool {
        if let m = Int(DateFormatters.durationFormatterMinute.stringFromDate(self)) {
            return m == 0
        }
        return false
    }
    
    /**
     Format date as a string, e.g. "Wed, Sep 9, 10am"
     
     - returns: the string
     */
    func toString() -> String {
        let am = DateFormatters.amPm.stringFromDate(self).lowercaseString
        return (self.hasZeroMinutes() ? DateFormatters.dateAndHours
            : DateFormatters.dateHoursAndMinutes).stringFromDate(self) + am
    }
    
    /**
     Check if current date is after the given date
     
     - parameter date: the date to check
     
     - returns: true - if current date is after
     */
    func isAfter(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedDescending
    }
    
    /**
     Format time as a string, e.g. "10am"
     
     - returns: the string
     */
    func toTimeString() -> String {
        let am = DateFormatters.amPm.stringFromDate(self).lowercaseString
        if self.hasZeroMinutes() {
            return DateFormatters.hours.stringFromDate(self) + am
        }
        else {
            return DateFormatters.hoursAndMinutes.stringFromDate(self) + am
        }
    }
}


/// number formatter for percents
var numberFormatter: NSNumberFormatter {
    let f = NSNumberFormatter()
    f.numberStyle = .DecimalStyle
    f.minimumFractionDigits = 0
    f.maximumFractionDigits = 0
    f.positivePrefix = "+"
    return f
}

/**
 * Custom NSDateFormatter for the form
 *
 * - author: TCASSEMBLER
 * - version: 1.0
 */
class NewbornDateFormatter: NSDateFormatter {
    
    /**
     Override to provide format like "March 10th, 2016"
     
     - parameter date: the date
     
     - returns: the string
     */
    override func stringFromDate(date: NSDate) -> String {
        struct Static {
            static var month: NSDateFormatter = {
                let f = NSDateFormatter()
                f.dateFormat = "MMMM"
                return f
            }()
            static var day: NSDateFormatter = {
                let f = NSDateFormatter()
                f.dateFormat = "d"
                return f
            }()
            static var year: NSDateFormatter = {
                let f = NSDateFormatter()
                f.dateFormat = "yyyy"
                return f
            }()
        }
        let day = Int(Static.day.stringFromDate(date))!
        return Static.month.stringFromDate(date) + " " + getWithPostfix(day) + ", " + Static.year.stringFromDate(date)
    }
    
    /**
     Get value with postfix for day number, e.g. 1 -> "1st", 22 -> "22nd, 15 -> "15th"
     
     - parameter number: the number
     
     - returns: the value with postfix
     */
    private func getWithPostfix(number: Int) -> String {
        if number%10 == 1 && number != 11 {
            return "\(number)st"
        }
        else if number%10 == 2 && number != 12 {
            return "\(number)nd"
        }
        else if number%10 == 3 && number != 13 {
            return "\(number)rd"
        }
        return "\(number)th"
    }
}


////////// UIWebView
/// URL to open
var url: NSURL?

/// URL request
var urlRequest: NSURLRequest?

/// PDF data to show
var data: NSData?

/**
 Setup UI
 */
override func viewDidLoad() {
    super.viewDidLoad()
    
    webView.delegate = self
    
    openUrl()
}

String(data: yourData, encoding: NSUTF8StringEncoding)

/**
 Open given URL
 */
func openUrl() {
    showLoadingIndicator(true)
    if let data = data {
        webView.loadData(data, MIMEType: "application/pdf", textEncodingName: "UTF-8", baseURL: NSURL(string: "http://google.com")!)
    }
    else if let request = urlRequest {
        webView.loadRequest(request)
    }
    else if let url = url {
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/pdf", forHTTPHeaderField: "Accept")
        webView.loadRequest(request)
    }
}

////////// \UIWebView
/**
 Notifies with given request URL, Method and body
 
 - parameter request:       NSURLRequest to log
 - parameter needToLogBody: flag used to decide either to log body or not
 */
func logRequest(request: NSURLRequest, _ needToLogBody: Bool) {
    // Log request URL
    var info = "url"
    if let m = request.HTTPMethod { info = m }
    var logMessage = "curl -X \(info) \(request.URL!.absoluteString)"
    
    if needToLogBody {
        // log body if set
        if let body = request.HTTPBody {
            if let bodyAsString = NSString(data: body, encoding: NSUTF8StringEncoding) as? String {
                logMessage += "\t -d '\(bodyAsString)'"
            }
        }
    }
    for (k,v) in request.allHTTPHeaderFields ?? [:] {
        logMessage += "\t -H \"\(k): \(v.replace("\"", withString: "\\\""))\""
    }
    print("[Info] : \(logMessage)")
}

///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////// SWIFT 3 ////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
/**
 Checking if the device is connected to a network
 */
class func isConnectedToNetwork() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    return (isReachable && !needsConnection)
}

