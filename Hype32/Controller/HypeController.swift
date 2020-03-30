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
}
