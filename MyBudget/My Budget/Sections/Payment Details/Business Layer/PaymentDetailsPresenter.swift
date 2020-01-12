//
//  PaymentDetailsPresenter.swift
//  My Budget
//
//  Created by Joshua Colley on 13/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation

protocol PaymentDetailsPresenterProtocol {
    func dismissView()
    func displayPayment(model: Payment)
}

class PaymentDetailsPresenter: PaymentDetailsPresenterProtocol {
    weak var view: PaymentDetailsViewProtocol?
    
    init(view: PaymentDetailsViewProtocol) {
        self.view = view
    }
    
    // MARK: - Implement Protocol Methods
    func dismissView() {
        self.view?.dismissView()
    }
    
    func displayPayment(model: Payment) {
        let viewModel = PaymentDetailsViewModel(model: model)
        self.view?.displayData(model: viewModel)
    }
}
