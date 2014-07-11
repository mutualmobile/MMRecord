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
        if let inwardIssue : AnyObject! = dict["inwardIssue"] {
            return true
        }
        
        return false
    }
}
