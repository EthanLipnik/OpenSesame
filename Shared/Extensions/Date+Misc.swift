//
//  Date+Misc.swift
//  Date+Misc
//
//  Created by Ethan Lipnik on 8/22/21.
//

import Foundation

extension Date {
    func nearestThirtySeconds() -> Date {
        let cal = Calendar.current
        let startOfMinute = cal.dateInterval(of: .minute, for: self)!.start
        var seconds = timeIntervalSince(startOfMinute)

        if seconds < 30 {
            seconds = 30
        } else {
            seconds = 60
        }

        return startOfMinute.addingTimeInterval(seconds)
    }
}
