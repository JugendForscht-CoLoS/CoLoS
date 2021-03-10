//
//  Date.swift
//  CoLoS
//
//  Created by Tim Jaeger on 04.01.21.
//

import Foundation

extension Date {
    // gibt die Zeit in Sekunden nach 00:00Uhr zurück
    var timeInSec: Int {
        
        get {
            
            let cal = Calendar.current
            
            let comps = cal.dateComponents([.day, .month, .year, .hour, .minute, .second], from: self)
            
            let timeZone: Int = TimeZone.current.secondsFromGMT()
            
            var time = 3600 * comps.hour! + 60 * comps.minute! + comps.second!
            
            time = time - timeZone
            
            if time < 0 {
                
                time = 86400 + time
            }
            
            return time
        }
    }
    // gibt die Zeit in Sekunden nach Jahresbeginn zurück
    var dateInSec: Int {
        
        get {
            
            let cal = Calendar.current
            
            let comps = cal.dateComponents([.day, .month, .year, .hour, .minute, .second], from: self)
            
            let timeZone: Int = TimeZone.current.secondsFromGMT()
            
            var time = 3600 * comps.hour! + 60 * comps.minute! + comps.second!
            
            time = time - timeZone
            
            if time < 0 {
                
                time = 86400 + time
            }
            
            let month: [Int] = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
            
            let date: Int
            
            if ((comps.year! - 2004) % 4) == 0 && comps.month! >= 2 {
                
                date = time + 86400 * (comps.day! - 1 + month[comps.month! - 1] + 1)
            }
            else {
                
                date = time + 86400 * (comps.day! - 1 + month[comps.month! - 1])
            }
            
            return date
        }
    }
}
