//
//  PaymentsVC.swift
//  My Budget
//
//  Created by Joshua Colley on 15/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import UIKit

enum PaymentsTab: Int {
    case income, outgoing, expired
}

protocol PaymentsViewProtocol: class {
    func displayPayments(tabs: PaymentTabs)
}

class PaymentsVC: UIViewController {
    
    @IBOutlet weak var tabWrapper: UIView!
    @IBOutlet weak var tabStackWrapper: UIStackView!
    @IBOutlet weak var highlightedView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var incomeTab: UIButton!
    @IBOutlet weak var incomeView: UIView!
    @IBOutlet weak var incomeLabel: UILabel!
    
    @IBOutlet weak var outgoingTab: UIButton!
    @IBOutlet weak var outgoingView: UIView!
    @IBOutlet weak var outgoingLabel: UILabel!
    
    @IBOutlet weak var expiredTab: UIButton!
    @IBOutlet weak var expiredView: UIView!
    @IBOutlet weak var expiredLabel: UILabel!
    
    var interactor: PaymentsInteractorProtocol!
    var presenter: PaymentsPresenterProtocol!
    var viewModel: PaymentTabs?
    var transitionManager: PaymentCellTransition!
    var activeTab: PaymentsTab = .income {
        didSet {
            self.refreshTable()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.presenter = PaymentsPresenter(view: self)
        self.interactor = PaymentsInteractor(presenter: self.presenter, appDelegate: appDelegate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "PaymentCell", bundle: nil), forCellReuseIdentifier: "PaymentCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.interactor.fetchPaymentsData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    // MARK: - Helper Methods
    fileprivate func setupUI() {
        self.tabWrapper.backgroundColor = UIColor.cardColour()
        self.tabWrapper.addShadow()
        
        self.highlightedView.layer.cornerRadius = highlightedView.frame.height / 2.0
        self.highlightedView.addGradient()
        
        self.tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 65, right: 0)
    }
    
    fileprivate func refreshTable() {
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.tableView.reloadSections(sections as IndexSet, with: .automatic)
    }
    
    // MARK: - Actions
    @IBAction func tabChangeAction(_ sender: UIButton) {
        guard let selectedTab = PaymentsTab(rawValue: sender.tag) else { return }
        switch selectedTab {
        case .income:
            UIView.animate(withDuration: 0.3) {
                self.highlightedView.center = CGPoint(x: self.incomeView.center.x + 16,
                                                      y: self.tabWrapper.frame.height - 8)
                self.incomeLabel.textColor = UIColor.white
                self.outgoingLabel.textColor = UIColor.lightGray
                self.expiredLabel.textColor = UIColor.lightGray
            }
        case .outgoing:
            UIView.animate(withDuration: 0.3) {
                self.highlightedView.center = CGPoint(x: self.outgoingView.center.x + 16,
                                                      y: self.tabWrapper.frame.height - 8)
                self.outgoingLabel.textColor = UIColor.white
                self.incomeLabel.textColor = UIColor.lightGray
                self.expiredLabel.textColor = UIColor.lightGray
            }
        case .expired:
            UIView.animate(withDuration: 0.3) {
                self.highlightedView.center = CGPoint(x: self.expiredView.center.x + 16,
                                                      y: self.tabWrapper.frame.height - 8)
                self.expiredLabel.textColor = UIColor.white
                self.outgoingLabel.textColor = UIColor.lightGray
                self.incomeLabel.textColor = UIColor.lightGray
            }
        }
        self.activeTab = selectedTab
    }
}

// MARK: - Table View Delegate & Data Source
extension PaymentsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        switch activeTab {
        case .income: return viewModel.income.count
        case .outgoing: return viewModel.outgoing.count
        case .expired: return viewModel.expired.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as? PaymentCell else {
            return UITableViewCell()
        }
        guard let viewModel = self.viewModel else { return UITableViewCell() }
        switch activeTab {
        case .income: cell.bindData(model: viewModel.income[indexPath.row])
        case .outgoing: cell.bindData(model: viewModel.outgoing[indexPath.row])
        case .expired: cell.bindData(model: viewModel.expired[indexPath.row])
        }
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
                guard let viewModel = self.viewModel else { return }
                var model: PaymentViewModel?
                switch self.activeTab {
                case .income: model = viewModel.income[indexPath.row]
                case .outgoing: model = viewModel.outgoing[indexPath.row]
                case .expired: model = viewModel.expired[indexPath.row]
                }
                
                let uuid = model!.uuid
                self.interactor.deletePayment(uuid: uuid)
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
            vc.selectedRow = indexPath.row
            vc.delegate = self
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
    }
}

// MARK: - Impelement View Protocol
extension PaymentsVC: PaymentsViewProtocol {
    func displayPayments(tabs: PaymentTabs) {
        self.viewModel = tabs
        self.refreshTable()
    }
}

// MARK: - Dismiss Delegate
extension PaymentsVC: DismissDetailsProtocol {
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
