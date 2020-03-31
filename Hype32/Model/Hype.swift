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
    
    //String value of Hype text
    var body: String
    
    // Date value of when the Hype was created
    var timestamp: Date
    
    // Unique identifier for our CKRecord
    var recordID: CKRecord.ID
    
    init(body: String, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.body = body
        self.timestamp = timestamp
        self.recordID = recordID
    }
    
}

// Incoming <---- (CKRecord into Hype)

extension Hype {
    
    convenience init?(ckRecord: CKRecord) {
        // get the body and timestamp
        guard let body = ckRecord["body"] as? String,
            let timestamp = ckRecord["timestamp"] as? Date else {return nil}
        
        // init
        self.init(body: body, timestamp: timestamp, recordID: ckRecord.recordID)
    }
}

// Outgoing ----> (Hype into CKRecord)

extension CKRecord {
    
    convenience init(hype: Hype) {
        // create CKRecord
        self.init(recordType: HypeStrings.recordTypeKey, recordID: hype.recordID)
        
        // add properties to it
        self.setValuesForKeys ([ HypeStrings.bodyKey: hype.body,
                                 HypeStrings.timestampKey: hype.timestamp])
    }
    
}

extension Hype: Equatable {
    static func == (lhs: Hype, rhs: Hype) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}
