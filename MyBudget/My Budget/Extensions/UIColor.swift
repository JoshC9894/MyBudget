//
//  UIColor.swift
//  My Budget
//
//  Created by Joshua Colley on 12/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static func primaryCTA() -> UIColor {
        return UIColor(red: 61/255, green: 236/255, blue: 174/255, alpha: 1.0)
//        3decae
    }
    static func secondaryCTA() -> UIColor {
        return UIColor(red: 72/255, green: 210/255, blue: 239/255, alpha: 1.0)
//        48d2ef
    }
    static func incomeGreen() -> UIColor {
        return UIColor(red: 61/255, green: 236/255, blue: 174/255, alpha: 1.0)
    }
    static func outgoingRed() -> UIColor {
        return UIColor(red: 255/255, green: 66/255, blue: 83/255, alpha: 1.0)
    }
    static func cardColour() -> UIColor {
        return UIColor(red: 55/255, green: 64/255, blue: 103/255, alpha: 1.0)
    }
    static func backgroundColour() -> UIColor {
        return UIColor(red: 39/255, green: 49/255, blue: 81/255, alpha: 1.0)
    }
}
