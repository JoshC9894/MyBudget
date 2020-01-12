//
//  PaymentCell.swift
//  My Budget
//
//  Created by Joshua Colley on 12/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import UIKit

class PaymentCell: UITableViewCell {
    
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var payeeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wrapperView.backgroundColor = UIColor.cardColour()
        wrapperView.roundCorners()
        wrapperView.addShadow()
        self.contentView.backgroundColor = UIColor.clear
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindData(model: PaymentViewModel) {
        self.payeeLabel.text = model.payee
        self.dateLabel.text = model.date
        self.amountLabel.text = model.amount
        
        let image = model.type == .income ? UIImage(named: "income") : UIImage(named: "outgoing")
        self.typeImageView.image = image
        self.amountLabel.textColor = model.type == .income ? UIColor.incomeGreen() : UIColor.outgoingRed()
    }
}

struct PaymentViewModel {
    var uuid: String
    var payee: String
    var date: String
    var amount: String
    var type: PaymentType
}

extension PaymentViewModel {
    init(model: Payment) {
        self.uuid = model.uuid ?? ""
        self.payee = model.payee ?? ""
        self.amount = "£\(model.amount.format(f: ".2"))"
        self.type = model.isIncome ? .income : .outgoing
        self.date = ""
        if let start = model.startDate {
            self.date = start.toDisplayString()
        }
    }
}

enum PaymentType {
    case income, outgoing
}
