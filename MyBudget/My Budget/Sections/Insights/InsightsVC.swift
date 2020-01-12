//
//  InsightsVC.swift
//  My Budget
//
//  Created by Joshua Colley on 12/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation
import UIKit

protocol InsightsViewProtocol: class {
    func displayData(viewModel: InsightsViewModels, balance: String)
}

class InsightsVC: UIViewController {
    
    @IBOutlet weak var balanceWrapper: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var balanceLabel: UILabel!
    
    var presenter: InsightsPresenterProtocol!
    var interactor: InsightsInteractorProtocol!
    var viewModel: InsightsViewModels?
    var transitionManager: PaymentCellTransition!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.presenter = InsightsPresenter(view: self)
        self.interactor = InsightsInteractor(presenter: self.presenter, appDelegate: appDelegate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        self.collectionView.register(UINib(nibName: "InsightCell", bundle: nil), forCellWithReuseIdentifier: "InsightCell")
        self.tableView.register(UINib(nibName: "PaymentCell", bundle: nil), forCellReuseIdentifier: "PaymentCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.interactor.fetchData()
    }
    
    // MARK: - Actions
    @IBAction func editBalanceAction(_ sender: Any) {
        let alert = UIAlertController(title: "Update balance", message: "Please fill the below", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .decimalPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (_) in
            let text = alert.textFields![0].text ?? "0.0"
            self.interactor.updateBalance(text)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    fileprivate func setupUI() {
        self.balanceWrapper.addShadow()
        self.balanceWrapper.roundCorners()
        self.balanceWrapper.addGradient()
        self.view.backgroundColor = UIColor.backgroundColour()
    }
}

// MARK: - View Protocol
extension InsightsVC: InsightsViewProtocol {
    func displayData(viewModel: InsightsViewModels, balance: String) {
        self.balanceLabel.text = balance
        self.viewModel = viewModel
        self.tableView.reloadData()
        self.collectionView.reloadData()
    }
}

// MARK: - Table View Delegate/Data Source
extension InsightsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = self.viewModel else { return 0 }
        return model.payments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as? PaymentCell else {
            return UITableViewCell()
        }
        guard let model = self.viewModel else { return UITableViewCell() }
        guard model.payments.count > 0 else { return UITableViewCell() }
        cell.bindData(model: model.payments[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "🗑️") { (rowAction, indexPath) in
                let alert = UIAlertController(title: "Delete Payment",
                                              message: "Are you sure?",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                    if let model = self.viewModel?.payments[indexPath.row] {
                        let uuid = model.uuid
                        self.interactor.deletePayment(uuid: uuid)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
        }
        deleteAction.backgroundColor = UIColor.backgroundColour()
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PaymentCell else { return }
        let frame = cell.wrapperView.superview?.convert(cell.wrapperView.frame, to: nil)
        let blurView = UIVisualEffectView(frame: self.view.bounds)
        blurView.effect = UIBlurEffect(style: .dark)
        blurView.alpha = 0.0
        self.tabBarController!.view.addSubview(blurView)
        let card = UIView(frame: frame!)
        card.addShadow()
        card.roundCorners()
        card.backgroundColor = UIColor.cardColour()
        self.tabBarController!.view.addSubview(card)
        
        transitionManager = PaymentCellTransition(cardView: card,
                                                  blurView: blurView,
                                                  cellFrame: frame!)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            blurView.alpha = 1.0
            card.frame = CGRect(x: frame!.origin.x,
                                y: cardYMargin,
                                width: frame!.width,
                                height: self.view.frame.height - (cardYMargin * 2))
        }) { (_) in
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentDetailsVC") as? PaymentDetailsVC else {
                return
            }
            vc.modelUUID = self.viewModel?.payments[indexPath.row].uuid
            vc.selectedRow = indexPath.row
            vc.delegate = self
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
    }
}

// MARK: - Collection View Delegate/Data Source
extension InsightsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = self.viewModel else { return 0 }
        return model.insights.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let defaultCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InsightCell", for: indexPath) as? InsightCell else {
            return defaultCell
        }
        guard let model = self.viewModel else { return defaultCell }
        guard model.insights.count > 0 else { return defaultCell }
        cell.bindData(model: model.insights[indexPath.row])
        return cell
    }
}

// MARK: - Dismiss Delegate
extension InsightsVC: DismissDetailsProtocol {
    func dismissTransition() {
        UIView.animate(withDuration: 0.3, animations: {
            self.transitionManager.blurView.alpha = 0.0
            self.transitionManager.cardView.frame = self.transitionManager.cellFrame
        }) { (_) in
            self.transitionManager.cardView.removeFromSuperview()
            self.transitionManager.blurView.removeFromSuperview()
        }
    }
}
