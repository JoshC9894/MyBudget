//
//  PaymentsInteractor.swift
//  My Budget
//
//  Created by Joshua Colley on 15/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation

protocol PaymentsInteractorProtocol {
    func fetchPaymentsData()
    func deletePayment(uuid: String)
}

class PaymentsInteractor: PaymentsInteractorProtocol {
    var presenter: PaymentsPresenterProtocol!
    var paymentService: PaymentServiceProtocol!
    
    init(presenter: PaymentsPresenterProtocol, appDelegate: AppDelegate) {
        self.presenter = presenter
        self.paymentService = PaymentService(appDelegate: appDelegate)
    }
    
    // MARK: - Implement Protocol Methods
    func fetchPaymentsData() {
        self.paymentService.fetchPayments { (payments) in
            guard let payments = payments else { return }
            self.presenter.presentPayments(payments)
        }
    }
    
    func deletePayment(uuid: String) {
        paymentService.deleteEntry(uuid: uuid) { (result) in
            guard result else { return }
            self.fetchPaymentsData()
        }
    }
}
