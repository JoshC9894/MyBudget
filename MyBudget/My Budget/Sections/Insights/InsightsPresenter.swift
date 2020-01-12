//
//  InsightsPresenter.swift
//  My Budget
//
//  Created by Joshua Colley on 12/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation

typealias InsightsViewModels = (insights: [InsightViewModel], payments: [PaymentViewModel])

protocol InsightsPresenterProtocol {
    func presentData(payments: [Payment], balance: Double)
}

class InsightsPresenter: InsightsPresenterProtocol {
    weak var view: InsightsViewProtocol?
    
    init(view: InsightsViewProtocol) {
        self.view = view
    }
    
    // MARK: - Protocol Methods
    func presentData(payments: [Payment], balance: Double) {
        let insights = createInsightsModels(payments: payments, balance: balance)
        let payments = payments.map({PaymentViewModel(model: $0)})
        let model: InsightsViewModels = (insights: insights, payments: payments)
        let balanceString = "£\(balance.format(f: ".2"))"
        self.view?.displayData(viewModel: model, balance: balanceString)
    }
    
    // MARK: - Helper Methods
    fileprivate func createInsightsModels(payments: [Payment], balance: Double) -> [InsightViewModel] {
        let post = getInsightVM(payments: payments, type: .after, balance: balance)
        let daily = getInsightVM(payments: payments, type: .daily, balance: balance)
        let weekly = getInsightVM(payments: payments, type: .weekly, balance: balance)
        let income = getInsightVM(payments: payments, type: .income, balance: balance)
        let outgoing = getInsightVM(payments: payments, type: .outgoing, balance: balance)
        return [post, daily, weekly, income, outgoing]
    }
    
    fileprivate func getInsightVM(payments: [Payment], type: InsightType, balance: Double) -> InsightViewModel {
        var total = 0.0
        var info = ""
        let outgoing = findTotalAmount(payments: payments.filter({$0.isIncome == false}))
        let income = findTotalAmount(payments: payments.filter({$0.isIncome == true}))
        let after = calculateRemaining(balance: balance, data: payments)
        
        switch type {
        case .daily:
            info = "Daily budget"
            let daysLeft = Double(Calendar.current.daysRemaining())
            total = after / daysLeft
            
        case .after:
            info = "After transactions"
            total = after
            
        case .outgoing:
            info = "Total out"
            total = outgoing
        case .income:
            info = "Total in"
            total = income
            
        case .weekly:
            info = "Weekly budget"
            let weeks = Double(Calendar.current.daysRemaining()) / 4
            total = after / weeks
        }
        let amount = "£\(total.format(f: ".2"))"
        return InsightViewModel(amount: amount, title: info)
    }
    
    fileprivate func findTotalAmount(payments: [Payment]) -> Double {
        var total: Double = 0.0
        payments.forEach({total = total + $0.amount})
        return total
    }
    
    fileprivate func calculateRemaining(balance: Double, data: [Payment]) -> Double {
        var balance: Double = balance
        let filtered = data.filter { $0.startDate! > Date() }
        filtered.forEach({balance = $0.isIncome ? balance + $0.amount : balance - $0.amount })
        
        return balance
    }
}
