//
//  Availability.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 7/24/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import Foundation

class Utilities {
    
    func getDayOfWeek() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let dayName = calendar.component(.weekday, from: date)
        return dayName
    }
    
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha"
        dateFormatter.timeZone = NSTimeZone.system
        let currentTime = dateFormatter.string(from: now)
        return currentTime // Example: 4AM
    }
    
    // MARK: CHECK TIME AND DAY
    func isDayOpen(day: String) -> Bool {
        let deviceDayOfWeek = self.getDayOfWeek()
        var isOpen = false
        
        // Monday
        if day == "monday" && deviceDayOfWeek == 2 {
            isOpen = true
        }
        
        // Tuesday
        if day == "tuesday" && deviceDayOfWeek == 3 {
            isOpen = true
        }
        
        // Wednesday
        if day == "wednesday" && deviceDayOfWeek == 4 {
            isOpen = true
        }
        
        // Thursday
        if day == "thursday" && deviceDayOfWeek == 5 {
            isOpen = true
        }
        
        // Friday
        if day == "friday" && deviceDayOfWeek == 6 {
            isOpen = true
        }
        
        // Saturday
        if day == "saturday" && deviceDayOfWeek == 7 {
            isOpen = true
        }
        
        // Sunday
        if day == "sunday" && deviceDayOfWeek == 1 {
            isOpen = true
        }
        
        return isOpen
    }
    
    func seperateTime(time: String) -> Bool {
        
        let parts = time.split(separator: "-")
        
        let open = parts[0]
        let close = parts[1]
        
        let openConverted = converStingToDate(str_date: String(open))
        let closeConverted = converStingToDate(str_date: String(close))
        
        let isOpen = isTimeOpen(open: openConverted, close: closeConverted)
        
        return isOpen
    }
    
    // Converting 1:00PM to 12:00
    func converStingToDate(str_date:String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mma"
        let date = dateFormatter.date(from: str_date)
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date!)
        
    }
    
    // Input in 24hr time
    func isTimeOpen(open: String, close: String) -> Bool  {
        var isOpen = false
        
        if let open = Time.create(time: open), let close = Time.create(time: close) {
            if Time.isOpen(open: open, close: close) == true {
                isOpen = true
            }
        } else {
            //error handling
        }
        
        return isOpen
    }
    
    func isBothDayAndTimeOpen(day: String, time: String) -> Bool {
        var isOpen = false
        let checkDay = isDayOpen(day: day)
        let checkTime = seperateTime(time: time)
        
        if checkDay && checkTime == true {
            isOpen = true
        }
        
        return isOpen
    }
}
