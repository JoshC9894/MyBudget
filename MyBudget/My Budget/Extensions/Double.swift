//
//  Double.swift
//  My Budget
//
//  Created by Joshua Colley on 13/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
