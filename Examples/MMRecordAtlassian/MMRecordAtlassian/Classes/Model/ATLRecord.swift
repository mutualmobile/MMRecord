//
//  ATLRecord.swift
//  MMRecordAtlassian
//
//  Created by Conrad Stoll on 6/20/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

import CoreData

class ATLRecord: MMRecord {
    override class func keyPathForResponseObject() -> String {
        return "plans.plan"
    }
}
