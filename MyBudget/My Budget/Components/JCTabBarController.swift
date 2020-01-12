//
//  JCTabBarController.swift
//  Custom Tab Bar
//
//  Created by Joshua Colley on 09/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import UIKit

class JCTabBarController: UITabBarController {
    
    let transition = JCCircularTransition()
    var fab: UIButton!
    weak var animationDelegate: JCTabBarDelegate?
    
    var isOpen: Bool = true {
        didSet {
            animateFAB()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBar = self.tabBar as? JCTabBar {
            animationDelegate = tabBar
        }
        setupFAB()
    }
    
    //MARK: - Helper Methods
    private func setupFAB() {
        
        fab = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        fab.addGradient()
        self.view.addSubview(fab)
        fab.backgroundColor = UIColor.primaryCTA()
        fab.translatesAutoresizingMaskIntoConstraints = false
        fab.heightAnchor.constraint(equalToConstant: 70).isActive = true
        fab.widthAnchor.constraint(equalToConstant: 70).isActive = true
        fab.centerXAnchor.constraint(equalTo: self.tabBar.centerXAnchor).isActive = true
        fab.centerYAnchor.constraint(equalTo: self.tabBar.topAnchor).isActive = true
        fab.layer.cornerRadius = 35.0
        fab.layer.shadowColor = UIColor.black.cgColor
        fab.layer.shadowOpacity = 0.35
        fab.layer.shadowRadius = 4
        fab.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        let image = UIImage(named: "add")
        
        // Add action button
        let button = UIButton(frame: CGRect.zero)
        button.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(didTapFAB), for: .touchUpInside)
        fab.addSubview(button)
        fab.bringSubviewToFront(button)
    }
    
    func fabUp() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.fabDidAnimate()
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            let target = (UIScreen.main.bounds.height / 2.0) - self.tabBar.frame.height
            self.fab.transform = CGAffineTransform(translationX: 0.0, y: -target)

        }, completion: nil)
    }
    
    func fabDown() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.fab.transform = .identity
        }, completion: nil)
    }
    
    func fabDidAnimate() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddPaymentVC")
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: - Implement FAB Delegate
extension JCTabBarController {
    @objc func didTapFAB() {
        isOpen = !isOpen
    }
    
    func animateFAB() {
        if isOpen {
            fabDown()
            self.animationDelegate?.animateTabBar(isOpen: isOpen)
        } else {
            self.animationDelegate?.animateTabBar(isOpen: isOpen)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.fabUp()
            }
        }
    }
}

// MARK: - Implement Transition Delegate
extension JCTabBarController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = CGPoint(x: fab.center.x, y: UIScreen.main.bounds.height / 2.0)
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = CGPoint(x: fab.center.x, y: UIScreen.main.bounds.height / 2.0)
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                self.isOpen = !self.isOpen
            }
        }
        return transition
    }
}
