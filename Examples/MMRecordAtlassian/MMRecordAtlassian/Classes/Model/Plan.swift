//
//  Plan.swift
//  MMRecordAtlassian
//
//  Created by Conrad Stoll on 6/20/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

import CoreData

class Plan: ATLRecord {
    @NSManaged var name: NSString
    @NSManaged var id: NSString
    
    override class func keyPathForResponseObject() -> String {
        return "plans.plan"
    }
}
