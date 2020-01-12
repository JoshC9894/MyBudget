//
//  Date.swift
//  My Budget
//
//  Created by Joshua Colley on 13/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation

extension Date {
    static let formatter = DateFormatter()
    
    func toDisplayString() -> String {
        Date.formatter.dateFormat = "EEE, dd MMM yy"
        return Date.formatter.string(from: self)
    }
}
