//
//  Hype.swift
//  Hype32
//
//  Created by Hin Wong on 3/30/20.
//  Copyright © 2020 Hin Wong. All rights reserved.
//

import CloudKit

//MARK: CONSTANTS

struct HypeStrings {
    static let bodyKey = "body"
    static let timestampKey = "timestamp"
    static let recordTypeKey = "Hype"
}

//MARK:-MODEL

class Hype {
    
    let body: String
    let timestamp: Date
    
    init(body: String, timestamp: Date = Date()) {
        self.body = body
        self.timestamp = timestamp
    }
    
}

// Incoming <---- (CKRecord into Hype)

extension Hype {
    
    convenience init?(ckRecord: CKRecord) {
        // get the body and timestamp
        guard let body = ckRecord["body"] as? String,
            let timestamp = ckRecord["timestamp"] as? Date else {return nil}
        
        // init
        self.init(body: body, timestamp: timestamp)
    }
}

// Outgoing ----> (Hype into CKRecord)

extension CKRecord {
    
    convenience init(hype: Hype) {
        // create CKRecord
        self.init(recordType: HypeStrings.recordTypeKey)
        
        // add properties to it
        self.setValuesForKeys ([ HypeStrings.bodyKey: hype.body,
                                 HypeStrings.timestampKey: hype.timestamp])
    }
    
}
