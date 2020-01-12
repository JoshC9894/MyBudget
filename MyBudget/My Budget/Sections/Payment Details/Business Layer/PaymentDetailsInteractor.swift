//
//  PaymentDetailsInteractor.swift
//  My Budget
//
//  Created by Joshua Colley on 13/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation
import UIKit

protocol PaymentDetailsInteractorProtocol {
    func savePayment(model: PaymentDTO)
    func updateModel(model: PaymentDTO)
    func getModel(withUUID: String)
}

class PaymentDetailsInteractor: PaymentDetailsInteractorProtocol {
    var presenter: PaymentDetailsPresenterProtocol!
    var paymentService: PaymentServiceProtocol!
    
    init(presenter: PaymentDetailsPresenterProtocol, appDelegate: AppDelegate) {
        self.presenter = presenter
        self.paymentService = PaymentService(appDelegate: appDelegate)
    }
    
    // MARK: - Implement Protocol Methods
    func savePayment(model: PaymentDTO) {
        self.paymentService.saveEntry(dto: model) { (success) in
            guard success else { debugPrint("@DEBUG: Failed To Save"); return }
            self.presenter.dismissView()
        }
    }
    
    func updateModel(model: PaymentDTO) {
        self.paymentService.updateEntry(dto: model) { (success) in
            if success {
                // Yay...
                self.presenter.dismissView()
            } else {
                // Boo...
            }
        }
    }
    
    func getModel(withUUID: String) {
        self.paymentService.fetchPaymentWithUUID(uuid: withUUID) { (payment) in
            guard let payment = payment else { return }
            self.presenter.displayPayment(model: payment)
        }
    }
}
