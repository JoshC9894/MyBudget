//
//  PaymentService.swift
//  My Budget
//
//  Created by Joshua Colley on 12/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

//
//  PaymentService.swift
//  Expense Tracker
//
//  Created by Joshua Colley on 03/02/2019.
//  Copyright © 2019 Joshua Colley. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol PaymentServiceProtocol {
    func saveEntry(dto: PaymentDTO, completion: @escaping(_ success: Bool) -> Void)
    func updateEntry(dto: PaymentDTO, completion: @escaping(_ success: Bool) -> Void)
    func deleteEntry(uuid: String, completion: @escaping(_ success: Bool) -> Void)
    func fetchPayments(completion: @escaping(_ data: [Payment]?) -> Void)
    func fetchPaymentWithUUID(uuid: String, completion: @escaping(_ data: Payment?) -> Void)
}

class PaymentService: PaymentServiceProtocol {
    
    var appDelegate: AppDelegate!
    var context: NSManagedObjectContext?
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        self.context = appDelegate.persistentContainer.viewContext
    }
    
    func saveEntry(dto: PaymentDTO, completion: @escaping (Bool) -> Void) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Payment", in: self.context!) else { return }
        let newPayment = NSManagedObject(entity: entity, insertInto: context)
        newPayment.setValue(dto.uuid, forKey: "uuid")
        newPayment.setValue(dto.transactionDay, forKey: "transactionDay")
        newPayment.setValue(dto.startDate, forKey: "startDate")
        newPayment.setValue(dto.payee, forKey: "payee")
        newPayment.setValue(dto.isOngoing, forKey: "isOngoing")
        newPayment.setValue(dto.isIncome, forKey: "isIncome")
        newPayment.setValue(dto.contractLength, forKey: "contractLength")
        newPayment.setValue(dto.amount, forKey: "amount")
        do {
            try context?.save()
            completion(true)
        } catch {
            debugPrint("@DEBUG: Unable to save")
            completion(false)
        }
    }
    
    func updateEntry(dto: PaymentDTO, completion: @escaping (Bool) -> Void) {
        // Do Stuff
        fetchPaymentWithUUID(uuid: dto.uuid) { (result) in
            guard let obj = result else {
                completion(false)
                return
            }
            obj.setValue(dto.transactionDay, forKey: "transactionDay")
            obj.setValue(dto.startDate, forKey: "startDate")
            obj.setValue(dto.payee, forKey: "payee")
            obj.setValue(dto.isOngoing, forKey: "isOngoing")
            obj.setValue(dto.isIncome, forKey: "isIncome")
            obj.setValue(dto.contractLength, forKey: "contractLength")
            obj.setValue(dto.amount, forKey: "amount")
            do {
                try self.context?.save()
                completion(true)
            } catch {
                debugPrint("@DEBUG: Unable to save")
                completion(false)
            }
            
        }
    }
    
    func deleteEntry(uuid: String, completion: @escaping (Bool) -> Void) {
        // Do Stuff
        fetchPaymentWithUUID(uuid: uuid) { (result) in
            guard let obj = result else {
                completion(false)
                return
            }
            self.context?.delete(obj)
            do {
                try self.context?.save()
                completion(true)
            } catch {
                debugPrint("@DEBUG: Unable to save")
                completion(false)
            }
        }
    }
    
    func fetchPayments(completion: @escaping ([Payment]?) -> Void) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Payment")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context?.fetch(request) as? [Payment]
            completion(result)
        } catch {
            debugPrint("@DEBUG: Payments not available (Service Catch Block)")
            completion(nil)
        }
    }
    
    func fetchPaymentWithUUID(uuid: String, completion: @escaping (Payment?) -> Void) {
        // Do stuff
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Payment")
        request.predicate = NSPredicate(format: "uuid == %@", uuid)
        do {
            let result = try context?.fetch(request) as? [Payment]
            completion(result?[0])
        } catch {
            debugPrint("@DEBUG: Payments not available (Service Catch Block)")
            completion(nil)
        }
    }
}


