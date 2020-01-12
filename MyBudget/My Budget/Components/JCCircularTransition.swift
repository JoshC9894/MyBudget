//
//  JCCircularTransition.swift
//  Custom Tab Bar
//
//  Created by Joshua Colley on 09/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation
import UIKit

class JCCircularTransition: NSObject {
    var circle: UIView = UIView()
    var duration: Double = 0.35
    var transitionMode: JCCircularTransitionMode = .present
    var startingPoint: CGPoint = CGPoint.zero {
        didSet{
            circle.center = startingPoint
        }
    }
    enum JCCircularTransitionMode: Int {
        case present, dismiss, pop
    }
    
    // MARK: - Helper Methods
    fileprivate func frameForCircle(withCenter viewCenter: CGPoint, size viewSize: CGSize, startPoint: CGPoint) -> CGRect {
        let xLen = fmax(startPoint.x, viewSize.width - startPoint.x)
        let yLen = fmax(startPoint.y, viewSize.height - startPoint.y)
        
        let offsetVector = sqrt((xLen * xLen) + (yLen * yLen)) * 2
        let size = CGSize(width: offsetVector, height: offsetVector)
        
        return CGRect(origin: CGPoint.zero, size: size)
    }
    
    fileprivate func presentTransition(containerView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        if let presentedView = transitionContext.view(forKey: .to) {
            let viewCenter = presentedView.center
            let viewSize = presentedView.frame.size
            
            self.circle = UIView()
            self.circle.frame = frameForCircle(withCenter: viewCenter,
                                               size: viewSize,
                                               startPoint: self.startingPoint)
            self.circle.layer.cornerRadius = self.circle.frame.height / 2.0
            self.circle.center = self.startingPoint
            self.circle.addGradient()
            self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            containerView.addSubview(self.circle)
            
            presentedView.center = self.startingPoint
            presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            presentedView.alpha = 0.0
            containerView.addSubview(presentedView)
            
            UIView.animate(withDuration: self.duration, animations: {
                self.circle.transform = CGAffineTransform.identity
                presentedView.transform = CGAffineTransform.identity
                presentedView.alpha = 1.0
                presentedView.center = viewCenter
            }) { (success) in
                transitionContext.completeTransition(success)
            }
        }
    }
    
    fileprivate func dismissTransition(dismissType:JCCircularTransitionMode, containerView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        if let returningView = transitionContext.view(forKey: dismissType == .pop ? .to : .from) {
            let viewCenter = returningView.center
            let viewSize = returningView.frame.size
        
            self.circle.frame = frameForCircle(withCenter: viewCenter,
                                               size: viewSize,
                                               startPoint: self.startingPoint)
            self.circle.layer.cornerRadius = self.circle.frame.height / 2.0
            self.circle.center = self.startingPoint
            self.circle.addGradient()
            
            UIView.animate(withDuration: self.duration, animations: {
                self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                returningView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                returningView.alpha = 0.0
                returningView.center = self.startingPoint
                
                if dismissType == .pop {
                    containerView.insertSubview(returningView, belowSubview: returningView)
                    containerView.insertSubview(self.circle, belowSubview: returningView)
                }
            }) { (success) in
                returningView.center = viewCenter
                returningView.removeFromSuperview()
                self.circle.removeFromSuperview()
                transitionContext.completeTransition(success)
            }
        }
    }
}

// MARK: - Implement VCAnimatedTransitioning Delegate
extension JCCircularTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        switch self.transitionMode {
        case .present:
            self.presentTransition(containerView: containerView,
                                   transitionContext: transitionContext)
        case .dismiss, .pop:
            self.dismissTransition(dismissType: self.transitionMode,
                                   containerView: containerView,
                                   transitionContext: transitionContext)
        }
    }
}
