//
//  PaymentDetailsVC.swift
//  My Budget
//
//  Created by Joshua Colley on 16/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import UIKit

protocol DismissDetailsProtocol: class {
    func dismissTransition()
}

class PaymentDetailsVC: UIViewController {
    
    @IBOutlet weak var cardWrapperView: UIView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var typeSegmentControl: UISegmentedControl!
    @IBOutlet weak var amountField: JCTextField!
    @IBOutlet weak var payeeField: JCTextField!
    @IBOutlet weak var startField: JCTextField!
    @IBOutlet weak var lengthField: JCTextField!
    @IBOutlet weak var ongoingSwitch: UISwitch!
    
    var modelUUID: String?
    var dto: PaymentDTO = PaymentDTO()
    private var datePicker: UIDatePicker!
    var interactor: PaymentDetailsInteractorProtocol!
    var presenter: PaymentDetailsPresenterProtocol!
    
    var selectedRow: Int!
    weak var delegate: DismissDetailsProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.presenter = PaymentDetailsPresenter(view: self)
        self.interactor = PaymentDetailsInteractor(presenter: self.presenter,
                                                   appDelegate: appDelegate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupTextFields()
        
        if let uuid = modelUUID {
            self.interactor.getModel(withUUID: uuid)
        }
    }
    
    // Helper Methods
    fileprivate func setupUI() {
        let dismissButton = UIButton(frame: self.view.bounds)
        dismissButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        self.view.insertSubview(dismissButton, at: 0)
        cardWrapperView.addShadow()
        cardWrapperView.roundCorners()
        
        self.saveButton.addGradient()
        self.saveButton.layer.cornerRadius = self.saveButton.frame.height / 2.0
        self.saveButton.setTitleColor(UIColor.white, for: .normal)
        self.ongoingSwitch.onTintColor = UIColor.primaryCTA()
        self.typeSegmentControl.tintColor = UIColor.primaryCTA()
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
    
    // MARK: - Actions
    @objc fileprivate func dismissAction() {
        delegate?.dismissTransition()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateAction(_ sender: Any) {
        guard let uuid = self.modelUUID else {
            return
        }
        self.dto.uuid = uuid
        self.dto.amount = Double(self.amountField.text ?? "0.0") ?? 0.0
        self.dto.contractLength = Int(self.lengthField.text ?? "0") ?? 0
        self.dto.isIncome = self.typeSegmentControl.selectedSegmentIndex == 1
        self.dto.isOngoing = self.ongoingSwitch.isOn
        self.dto.payee = self.payeeField.text ?? ""
        self.dto.startDate = self.datePicker.date
        self.dto.transactionDay = 0
        interactor.updateModel(model: dto)
    }
    
    @objc func dateHandler(datePicker: UIDatePicker) {
        self.startField.text = datePicker.date.toDisplayString()
        self.dto.startDate = datePicker.date
    }
}

// MARK: - JCTextField Delegate {
extension PaymentDetailsVC: JCTextFieldDelegate {
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
}

// MARK: - Implement View Protocol
extension PaymentDetailsVC: PaymentDetailsViewProtocol {
    func dismissView() {
        self.dismissAction()
    }
    
    func displayData(model: PaymentDetailsViewModel) {
        let typeIndex = model.isIncome ? 1 : 0
        self.typeSegmentControl.selectedSegmentIndex = typeIndex
        self.amountField.text = model.amount
        self.payeeField.text = model.payee
        self.startField.text = model.startDate
        self.lengthField.text = model.contractLength
        self.ongoingSwitch.isOn = model.isOngoing
    }
}
