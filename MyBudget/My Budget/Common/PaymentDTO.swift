//
//  PaymentDTO.swift
//  My Budget
//
//  Created by Joshua Colley on 12/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation

struct PaymentDTO {
    var uuid: String
    var transactionDay: Int
    var amount: Double
    var contractLength: Int
    var startDate: Date
    var isIncome: Bool
    var isOngoing: Bool
    var payee: String
}

extension PaymentDTO {
    init() {
        self.uuid = UUID().uuidString
        self.transactionDay = 0
        self.amount = 0.0
        self.contractLength = 0
        self.startDate = Date()
        self.isIncome = false
        self.isOngoing = false
        self.payee = ""
    }
    
    init(model: Payment) {
        self.uuid = model.uuid ?? ""
        self.transactionDay = Int(model.transactionDay)
        self.amount = model.amount
        self.contractLength = Int(model.contractLength)
        self.startDate = model.startDate ?? Date()
        self.isIncome = model.isIncome
        self.isOngoing = model.isOngoing
        self.payee = model.payee ?? ""
    }
}
