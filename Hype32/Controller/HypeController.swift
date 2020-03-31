//
//  HypeController.swift
//  Hype32
//
//  Created by Hin Wong on 3/30/20.
//  Copyright © 2020 Hin Wong. All rights reserved.
//

import CloudKit

class HypeController {
    
    //MARK: - SOURCE OF TRUTH AND SHARED INSTANCE
    
    static let shared = HypeController()
    var hypes: [Hype] = []
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //MARK: - CRUD
    
    func saveHype(body: String, completion: @escaping (Bool) -> Void) {
        
        let hype = Hype(body: body)
        let record = CKRecord(hype: hype)
        publicDB.save(record) { (record, error) in
            
            //handle error
            if let error = error {
                print(error, error.localizedDescription)
                return completion(false)
            }
            
            //record?
            guard let record = record,
                let hype = Hype(ckRecord: record) else { return completion(false)}
            self.hypes.insert(hype, at: 0)
            return completion(true)
        }
    }
    
    func fetchAllHypes(completion: @escaping (Bool) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            //error handling
            if let error = error {
                print(error, error.localizedDescription)
                return completion(false)
            }
            
            // records?
            guard let records = records else {return completion(false)}
            let hypes: [Hype] = records.compactMap(Hype.init(ckRecord:))
            
            self.hypes = hypes
            return completion(true)
        }
    }
    
    func update(_ hype: Hype, completion:@escaping (Result<Hype?, HypeError>) -> Void) {
        
        //declaring a constant called record of type CKRecord that will be created from the hype object that we passed in
        let record = CKRecord(hype: hype)
        
        // staging the record that we want to update into our operation
        // creating an operation that will modify records currently on the database
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        // setting our operations properties
        // stating that we only want to update the changed keys or values
        operation.savePolicy = .changedKeys
        
        // stating that this operation is important for the UI
        operation.qualityOfService = .userInteractive
        
        // setting the completion block for our operation
        operation.modifyRecordsCompletionBlock = { (records, _ , error) in
            
            // error handling
            if let error = error {
                print(error, error.localizedDescription)
                completion(.failure(.ckError(error)))
                return
            }
            
            // making sure that we got records back and then turning them into "Hype" objects
            guard let record = records?.first,
                let updateHype = Hype(ckRecord: record) else {completion(.failure(.couldNotUnwrap)); return}
            completion(.success(updateHype))
        }
        
        // adding this to our publicDB so that it is ran
        publicDB.add(operation)
    }
    
    func delete ( _ hype: Hype, completion: @escaping(Result<Bool, HypeError>) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.recordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            
            if let error = error {
                print(error, error.localizedDescription)
                completion(.failure(.ckError(error)))
                return
            }
            
            if records?.count == 0 {
                completion(.success(true))
            } else {
                completion(.failure(.unexpectedRecordFound))
            }
        }
        
        publicDB.add(operation)
    }
    
    func subscribeForRemoteNotifications(completion: @escaping (Error?) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: HypeStrings.recordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "Hype was added"
        notificationInfo.alertBody = "Come check it out"
        notificationInfo.shouldBadge = true
        
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (_, error) in
            if let error = error {
                print(error, error.localizedDescription)
                completion(error)
            }
            completion(nil)
        }
    }
}
