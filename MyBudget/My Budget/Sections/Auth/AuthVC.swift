//
//  AuthVC.swift
//  My Budget
//
//  Created by Joshua Colley on 17/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        bioAuth()
    }
    
    @IBAction func authButton(_ sender: Any) {
        bioAuth()
    }
    
    // MARK: - Helper Methods
    fileprivate func bioAuth() {
        let authContext = LAContext()
        authContext.localizedFallbackTitle = "Use passcode"
        
        var authError: NSError?
        let reason = "To access secure data"
        
        if authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            authContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (success, error) in
                if success {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "JCTabBarController")
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overFullScreen
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }
                } else {
                    guard let error = authError else { return }
                    let message = self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code)
                    DispatchQueue.main.async {
                        self.displayError(message: message)
                    }
                }
            }
        } else {
            guard let error = authError else { return }
            let message = self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code)
            DispatchQueue.main.async {
                self.displayError(message: message)
            }
        }
    }
    
    fileprivate func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
                
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
            default:
                message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."
                
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"
                
            default:
                message = "Did not find error code on LAError object"
            }
        }
        
        return message;
    }
    
    fileprivate func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }
}

extension UIViewController {
    func displayError(message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
