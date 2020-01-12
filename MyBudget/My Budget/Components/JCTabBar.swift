//
//  JCTabBar.swift
//  Custom Tab Bar
//
//  Created by Joshua Colley on 08/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import UIKit

protocol JCTabBarDelegate: class {
    func animateTabBar(isOpen: Bool)
}

@IBDesignable
class JCTabBar: UITabBar {
    
    private var shapeLayer: CAShapeLayer?
    var isOpen = false
    
    override func draw(_ rect: CGRect) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.lineWidth = 1.0
        shapeLayer.fillColor = UIColor.cardColour().cgColor
        
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOpacity = 0.35
        shapeLayer.shadowRadius = 4
        shapeLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)

        if let oldLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
    }
    
    // MARK: - Setup Methods
    private func createPath() -> CGPath {
        let height: CGFloat = 42.0
        let path = UIBezierPath()
        let centerWidth = self.frame.width / 2.0
        
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: (centerWidth - height * 2), y: 0))
        
        path.addCurve(to: CGPoint(x: centerWidth, y: height),
                      controlPoint1: CGPoint(x: (centerWidth - 37), y: 0),
                      controlPoint2: CGPoint(x: centerWidth - 35, y: height))
        
        path.addCurve(to: CGPoint(x: (centerWidth + height * 2), y: 0),
                      controlPoint1: CGPoint(x: (centerWidth + 35), y: height),
                      controlPoint2: CGPoint(x: centerWidth + 37, y: 0))
        
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.close()
        
        return path.cgPath
    }
    
    private func animatePath() -> CGPath {
        let height: CGFloat = 42.0
        let path = UIBezierPath()
        let centerWidth = self.frame.width / 2.0
        
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: (centerWidth - height * 2), y: 0))
        
        path.addCurve(to: CGPoint(x: centerWidth, y: 0),
                      controlPoint1: CGPoint(x: (centerWidth - 42), y: 0),
                      controlPoint2: CGPoint(x: centerWidth - 40, y: 0))
        
        path.addCurve(to: CGPoint(x: (centerWidth + height * 2), y: 0),
                      controlPoint1: CGPoint(x: (centerWidth + 40), y: 0),
                      controlPoint2: CGPoint(x: centerWidth + 42, y: 0))
        
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.close()
        
        return path.cgPath
    }
}

extension JCTabBar: JCTabBarDelegate {
    func animateTabBar(isOpen: Bool) {
        if isOpen {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.close()
            }
        } else {
            open()
        }
    }
    
    
    
    fileprivate func open() {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = createPath()
        animation.toValue = animatePath()
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        shapeLayer?.add(animation, forKey: "path")
        
        isOpen = true
    }
    
    fileprivate func close() {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = animatePath()
        animation.toValue = createPath()
        animation.duration = 0.15
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        shapeLayer?.add(animation, forKey: "path")
        
        isOpen = false
    }
}
