//
//  JCTextField.swift
//  JCTextField-Test
//
//  Created by Joshua Colley on 13/05/2018.
//  Copyright © 2018 Joshua Colley. All rights reserved.
//

import UIKit

@objc protocol JCTextFieldDelegate {
    @objc func hideKeyboard()
//    func scroll(up: Bool, fieldTag: FieldTag)
}

class JCTextField: UITextField {
    
    // MARK: - Properties
    let borderHeight: CGFloat = 2.0
    let floatingSpace: CGFloat = -15.0

    var border: UIView!
    var showEditingMode: Bool = true
    var floatingLabelIsVisible: Bool = false
    var placeholderText: String = ""
    var floatingLabel: UILabel!
    var customDelegate: JCTextFieldDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupFloatingLabel()
        self.setupBorder()
        self.delegate = self
        self.borderStyle = .none
        self.placeholderText = self.placeholder ?? ""
        self.attributedPlaceholder = NSAttributedString(string: placeholderText,
                                                        attributes: [NSAttributedString.Key.foregroundColor:UIColor.lightGray])
    }
    
    // MARK: - Helper Methods
    fileprivate func setupFloatingLabel() {
        self.floatingLabel = UILabel(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: self.frame.size.width,
                                                   height: 15.0))
        self.floatingLabel.textColor = self.tintColor
        self.floatingLabel.font = UIFont(name: "Helvetica", size: 14.0)
        self.floatingLabel.text = self.placeholder
        self.floatingLabel.alpha = 0.0
        
        self.addSubview(self.floatingLabel)
        self.bringSubviewToFront(self.floatingLabel)
    }
    
    fileprivate func setupBorder() {
        self.border = UIView(frame: CGRect(origin: CGPoint(x: self.frame.width / 2,
                                                           y: self.frame.height - 1),
                                           size: CGSize(width: 0.0,
                                                        height: 1.0)))
        
        self.border.backgroundColor = self.tintColor
        self.addSubview(border)
    }
    
    func toggleEditingMode() {
        if self.isEditing {
            self.attributedPlaceholder = NSAttributedString(string: "",
                                                            attributes: [NSAttributedString.Key.foregroundColor:UIColor.lightGray])
            self.showBorder()
            if !self.floatingLabelIsVisible { self.showFloatingLabel() }
        } else {
            self.hideBorder()
            if self.text == "" || self.text == nil {
                self.hideFloatingLabel()
            }
        }
        defer { showEditingMode = !showEditingMode }
    }
}

// MARK: -  UITextFieldDelegate
extension JCTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        toggleEditingMode()
//        self.customDelegate?.scroll(up: true, fieldTag: FieldTag(rawValue: textField.tag) ?? .amount)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        toggleEditingMode()
        self.customDelegate?.hideKeyboard()
//        self.customDelegate?.scroll(up: false, fieldTag: FieldTag(rawValue: textField.tag) ?? .amount)
    }
}


// MARK: -  Animation Methods
extension JCTextField {
    fileprivate func showFloatingLabel() {
        self.floatingLabelIsVisible = true
        UIView.animate(withDuration: 0.25) {
            self.floatingLabel.alpha = 1.0
            self.floatingLabel.transform = CGAffineTransform(translationX: 1, y: -15)
        }
    }
    
    fileprivate func hideFloatingLabel() {
        self.floatingLabelIsVisible = false
        UIView.animate(withDuration: 0.25, animations: {
            self.floatingLabel.alpha = 0.0
            self.floatingLabel.transform = CGAffineTransform.identity
        }) { (_) in
            self.attributedPlaceholder = NSAttributedString(string: self.placeholderText,
                                                            attributes: [NSAttributedString.Key.foregroundColor:UIColor.lightGray])
        }
    }
    
    fileprivate func showBorder() {
        UIView.animate(withDuration: 0.25) {
            self.border.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.height - 1),
                                       size: CGSize(width: self.frame.size.width - 0, height: 1.0))
        }
    }
    
    fileprivate func hideBorder() {
        UIView.animate(withDuration: 0.25) {
            self.border.frame = CGRect(origin: CGPoint(x: self.frame.width / 2, y: self.frame.height - 1),
                                       size: CGSize(width: 0.0, height: 1.0))
        }
    }
}
