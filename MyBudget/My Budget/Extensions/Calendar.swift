//
//  Calendar.swift
//  My Budget
//
//  Created by Joshua Colley on 14/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation

extension Calendar {
    func daysRemaining() -> Int {
        let today = self.component(.day, from: Date())
        var components = Calendar.current.dateComponents([.year, .month], from: Date())
        components.month = components.month! + 1
        components.day = 1
        components.day = components.day! - 1
        let monthEnd = Calendar.current.date(from: components as DateComponents)!
        let last = self.component(.day, from: monthEnd)
        return last - today
    }
    
    func firstOfMonth() -> Date? {
        let components = self.dateComponents([.year, .month], from: Date())
        return self.date(from: components)
    }
}
