//
//  UIView.swift
//  My Budget
//
//  Created by Joshua Colley on 12/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func roundCorners() {
        self.layer.cornerRadius = 6.0
    }
    
    func addShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.25
    }
    
    func addGradient() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.primaryCTA().cgColor, UIColor.secondaryCTA().cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        self.layer.insertSublayer(gradient, at: 0)
        self.layer.masksToBounds = true
        self.subviews.forEach({ self.bringSubviewToFront($0) })
    }
}
