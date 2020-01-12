//
//  AddPaymentVC.swift
//  My Budget
//
//  Created by Joshua Colley on 13/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import UIKit

protocol PaymentDetailsViewProtocol: class {
    func dismissView()
    func displayData(model: PaymentDetailsViewModel)
}

class AddPaymentVC: UIViewController {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var addTitleLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var typeSegmentControl: UISegmentedControl!
    @IBOutlet weak var amountField: JCTextField!
    @IBOutlet weak var payeeField: JCTextField!
    @IBOutlet weak var startField: JCTextField!
    @IBOutlet weak var lengthField: JCTextField!
    @IBOutlet weak var ongoingSwitch: UISwitch!
    
    var interactor: PaymentDetailsInteractorProtocol!
    var presenter: PaymentDetailsPresenterProtocol!
    var dto: PaymentDTO = PaymentDTO()
    private var datePicker: UIDatePicker!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.presenter = PaymentDetailsPresenter(view: self)
        self.interactor = PaymentDetailsInteractor(presenter: self.presenter,
                                                   appDelegate: appDelegate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) {
            self.addTitleLabel.alpha = 1.0
            self.cardView.transform = CGAffineTransform.identity
            self.blurView.effect = nil
        }
    }
    
    // MARK: - Actions
    @objc func dismissAction() {
        UIView.animate(withDuration: 0.25, animations: {
            self.cardView.transform = CGAffineTransform(translationX: 0.0, y: self.cardView.frame.height)
            self.addTitleLabel.alpha = 0.0
            self.blurView.effect = nil
        }) { (_) in
            self.cardView.isHidden = true
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        self.dto.uuid = UUID().uuidString
        self.dto.amount = Double(self.amountField.text ?? "0.0") ?? 0.0
        self.dto.contractLength = Int(self.lengthField.text ?? "0") ?? 0
        self.dto.isIncome = self.typeSegmentControl.selectedSegmentIndex == 1
        self.dto.isOngoing = self.ongoingSwitch.isOn
        self.dto.payee = self.payeeField.text ?? ""
        self.dto.startDate = self.datePicker.date
        self.dto.transactionDay = 0
        
        self.interactor.savePayment(model: self.dto)
    }
    
    @objc func dateHandler(datePicker: UIDatePicker) {
        self.startField.text = datePicker.date.toDisplayString()
        self.dto.startDate = datePicker.date
    }
    
    
    // MARK: - Helper Methods
    fileprivate func setupUI() {
        self.addTitleLabel.textColor = UIColor.white
        self.view.backgroundColor = UIColor.clear
        
        self.blurView.contentView.addGradient()
        
        self.blurView.effect = nil
        self.cardView.backgroundColor = UIColor.clear
        self.saveButton.addGradient()
        self.saveButton.layer.cornerRadius = self.saveButton.frame.height / 2.0
        self.saveButton.setTitleColor(UIColor.white, for: .normal)
        self.ongoingSwitch.onTintColor = UIColor.primaryCTA()
        self.typeSegmentControl.tintColor = UIColor.primaryCTA()
        self.addTitleLabel.alpha = 0.0
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                            y: 0,
                                                            width: self.view.frame.width,
                                                            height: self.cardView.frame.height),
                                        byRoundingCorners: [.topLeft, .topRight],
                                        cornerRadii: CGSize(width: 25.0, height: 25.0)).cgPath
        
        shadowLayer.fillColor = UIColor.backgroundColour().cgColor
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowRadius = 4.0
        shadowLayer.shadowOpacity = 0.35
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        self.cardView.layer.insertSublayer(shadowLayer, at: 0)
        cardView.transform = CGAffineTransform(translationX: 0.0, y: cardView.frame.height)
        
        self.dismissButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
    }
    
    fileprivate func setupTextFields() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.date = Date()
        datePicker.addTarget(self, action: #selector(dateHandler(datePicker:)), for: .valueChanged)
        
        self.amountField.customDelegate = self
        self.payeeField.customDelegate = self
        self.startField.customDelegate = self
        self.startField.text = Date().toDisplayString()
        self.lengthField.customDelegate = self
        self.startField.inputView = self.datePicker
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tap)
    }
}

// MARK: - Implement View Protocol
extension AddPaymentVC: PaymentDetailsViewProtocol {
    func displayData(model: PaymentDetailsViewModel) {
    }
    
    func dismissView() {
        self.dismissAction()
    }
}

// MARK: - JCTextField Delegate {
extension AddPaymentVC: JCTextFieldDelegate {
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
}
