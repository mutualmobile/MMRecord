//
//  MMRecordAtlassian.OutwardLink
//  MMRecordAtlassian
//
//  Created by Conrad Stoll on 6/24/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//
import CoreData

class OutwardLink: Link {
    override class func shouldUseSubEntityRecordClassToRepresentData(dict : NSDictionary) -> Bool {
        let outwardIssue : AnyObject! = dict["outwardIssue"]

        if (outwardIssue) {
            return true
        }
        
        return false
    }
}
