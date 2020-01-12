//
//  PaymentDetailsViewModel.swift
//  Expense Tracker
//
//  Created by Joshua Colley on 05/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation

struct PaymentDetailsViewModel {
    var isIncome: Bool
    var amount: String
    var payee: String
    var startDate: String
    var contractLength: String
    var transactionDay: String
    var isOngoing: Bool
}

extension PaymentDetailsViewModel {
    init(model: Payment) {
        self.isIncome = model.isIncome
        self.amount = "\(model.amount.format(f: ".2"))"
        self.payee = model.payee ?? ""
        self.startDate = model.startDate!.toDisplayString()
        self.contractLength = "\(model.contractLength)"
        self.transactionDay = "\(model.transactionDay)"
        self.isOngoing = model.isOngoing
    }
}
