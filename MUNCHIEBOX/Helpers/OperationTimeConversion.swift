//
//  OperationTimeConversion.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 8/20/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import Foundation

class OperationTimeConversion {
    
    private func getCurrentWeekday() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return weekday
    }
    
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let now = Date()
        let dateString = formatter.string(from:now)
        return dateString
    }
    
    private func conver12HrTo24HrFormat(time: String) -> String {
        let hour12Fromat = DateFormatter()
        hour12Fromat.dateFormat = "hh:mma"
        let hour12result = hour12Fromat.date(from: time)
        
        let hour24Format = DateFormatter()
        hour24Format.dateFormat = "HH:MM"
        let hour24Result = hour24Format.string(from: hour12result!)
        
        return hour24Result
    }
    
    public func doesStaticWeekdayMatch(truck weekday: String) -> Bool {
        let weekdayFromDevice = getCurrentWeekday()
        var isMatch = false
        
        if weekday == "monday" && weekdayFromDevice == 2 {
            isMatch = true
        } else if weekday == "tuesday" && weekdayFromDevice == 3 {
            isMatch = true
        } else if weekday == "wednesday" && weekdayFromDevice == 4 {
            isMatch = true
        } else if weekday == "thursday" && weekdayFromDevice == 5 {
            isMatch = true
        } else if weekday == "friday" && weekdayFromDevice == 6 {
            isMatch = true
        } else if weekday == "saturday" && weekdayFromDevice == 7 {
            isMatch = true
        } else if weekday == "sunday" && weekdayFromDevice == 1 {
            isMatch = true
        }
        
        return isMatch
    }
    
    public func isCurrentTimeWithinTruckHours(truck time: String) -> Bool {
        var isOpen = false
        let open12HrTime = time.split(separator: "-")[0]
        let close12HrTime = time.split(separator: "-")[1]
        let open24HrTime = conver12HrTo24HrFormat(time: String(open12HrTime))
        let close24HrTime = conver12HrTo24HrFormat(time: String(close12HrTime))
        
        if let open = Time.create(time: String(open24HrTime)), let close = Time.create(time: String(close24HrTime)) {
            if Time.isOpen(open: open, close: close) == true {
                isOpen = true
            }
        } else {
            //error handling
        }
        
        return isOpen
    }
    
    public func doesDynamicScheduleMatch(truck scheduleDate: String?) -> Bool {
        guard (scheduleDate != "none") else { return false }
        
        let currentDate = getCurrentDate()
        var isMatch = false
        
        if scheduleDate == currentDate {
            isMatch = true
        }
        
        return isMatch
    }
    
    func checkIfTruckIsOpen(foodTrucks: [FoodTruck], completion: @escaping ([FoodTruck]) -> Void) {

        let dg = DispatchGroup()
        var checkedTrucks = [FoodTruck]()
        
        for truck in foodTrucks {
            dg.enter()
            let time = truck.time
            let weekday = truck.day
            let date = truck.date
            
            let doesDateMatch = doesDynamicScheduleMatch(truck: date!)
            let doesWeekdayMatch = doesStaticWeekdayMatch(truck: weekday)
            let isWithinOperationTime = isCurrentTimeWithinTruckHours(truck: time)
            
            if doesDateMatch == true {
                truck.showOnMap = true
            }
            
            if doesWeekdayMatch == true {
                truck.showOnMap = true
            }
            
            if isWithinOperationTime == true {
                truck.currentlyOpen = true
            }
            
            checkedTrucks.append(truck)
            dg.leave()
        }
        
        dg.notify(queue: .main, execute: {
            completion(checkedTrucks)
        })
        
    }
}
