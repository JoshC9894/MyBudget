//
//  InsightCell.swift
//  My Budget
//
//  Created by Joshua Colley on 12/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import UIKit

class InsightCell: UICollectionViewCell {
    
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wrapperView.backgroundColor = UIColor.cardColour()
        wrapperView.roundCorners()
        wrapperView.addShadow()
    }
    
    func bindData(model: InsightViewModel) {
        self.amountLabel.text = model.amount
        self.titleLabel.text = model.title
    }
}

struct InsightViewModel {
    var amount: String
    var title: String
}

enum InsightType {
    case daily, after, income, outgoing, weekly
}
