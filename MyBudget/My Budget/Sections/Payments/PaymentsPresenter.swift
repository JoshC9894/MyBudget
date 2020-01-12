//
//  PaymentsPresenter.swift
//  My Budget
//
//  Created by Joshua Colley on 15/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation

typealias PaymentTabs = (income: [PaymentViewModel], outgoing: [PaymentViewModel], expired: [PaymentViewModel])

protocol PaymentsPresenterProtocol {
    func presentPayments(_ payments: [Payment])
}

class PaymentsPresenter: PaymentsPresenterProtocol {
    weak var view: PaymentsViewProtocol?
    
    init(view: PaymentsViewProtocol) {
        self.view = view
    }
    
    // MARK: - Implement Protocol Methods
    func presentPayments(_ payments: [Payment]) {
        let income = payments.filter({ $0.isIncome }).sorted(by: {$0.startDate! > $1.startDate!}).map({PaymentViewModel(model: $0)})
        let outgoing = payments.filter({ !$0.isIncome }).sorted(by: {$0.startDate! > $1.startDate!}).map({PaymentViewModel(model: $0)})
        let expired = self.getExpired(payments: payments)
        
        let viewModel: PaymentTabs = (income: income, outgoing: outgoing, expired: expired)
        self.view?.displayPayments(tabs: viewModel)
    }
    
    // MARK: - Helper Methods
    fileprivate func getExpired(payments: [Payment]) -> [PaymentViewModel] {
        let expired = payments.filter({ payment in
            let start = payment.startDate!
            let expiry = Calendar.current.date(byAdding: .month, value: Int(payment.contractLength), to: start)!
            return Date() > expiry
        })
        return expired.sorted(by: {$0.startDate! > $1.startDate!}).map({PaymentViewModel(model: $0)})
    }
}
