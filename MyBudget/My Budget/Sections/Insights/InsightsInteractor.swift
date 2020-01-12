//
//  InsightsInteractor.swift
//  My Budget
//
//  Created by Joshua Colley on 12/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation

protocol InsightsInteractorProtocol {
    func fetchData()
    func updateBalance(_ balance: String)
    func deletePayment(uuid: String)
}

class InsightsInteractor: InsightsInteractorProtocol {
    var presenter: InsightsPresenterProtocol!
    var paymentService: PaymentServiceProtocol!
    
    init(presenter: InsightsPresenterProtocol, appDelegate: AppDelegate) {
        self.presenter = presenter
        self.paymentService = PaymentService(appDelegate: appDelegate)
    }
    
    // MARK: - Protocol Methods
    func fetchData() {
        let balance = UserDefaults.standard.double(forKey: "balance")
        paymentService.fetchPayments { (data) in
            guard let response = data else {
                self.presenter.presentData(payments: [], balance: balance)
                return
            }
            let payments = self.filterForMonth(payments: response)
            self.presenter.presentData(payments: payments, balance: balance)
        }
    }
    
    func updateBalance(_ balance: String) {
        let double = Double(balance) ?? 0.0
        UserDefaults.standard.set(double, forKey: "balance")
        self.fetchData()
    }
    
    func deletePayment(uuid: String) {
        paymentService.deleteEntry(uuid: uuid) { (result) in
            guard result else { return }
            self.fetchData()
        }
    }
    
    // MARK: - Helper Methods
    fileprivate func filterForMonth(payments: [Payment]) -> [Payment] {
        let filtered = payments.filter({ payment in
            guard let start = payment.startDate else { return false }
            let contract = Int(payment.contractLength)
            guard let contractEnd = Calendar.current.date(byAdding: .month,
                                                          value: contract,
                                                          to: start) else { return false }
            guard let startOfMonth = Calendar.current.firstOfMonth() else { return false }
            return contractEnd > startOfMonth
        })
        return filtered.sorted(by: {$0.startDate! < $1.startDate!})
    }
}
