//
//  MMRecordAtlassian.InwardLink
//  MMRecordAtlassian
//
//  Created by Conrad Stoll on 6/24/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

import CoreData

class InwardLink: Link {
    override class func shouldUseSubEntityRecordClassToRepresentData(dict : [NSObject : AnyObject]!) -> Bool {
        let inwardIssue : AnyObject! = dict["inwardIssue"]
        
        if (inwardIssue) {
            return true
        }
        
        return false
    }
}
