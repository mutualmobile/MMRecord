//
//  MMRecordAtlassian.Issue
//  MMRecordAtlassian
//
//  Created by Conrad Stoll on 6/24/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

import CoreData

class Issue: ATLRecord {
    @NSManaged var key: NSString
    @NSManaged var id: NSString
    @NSManaged var issueLinks: NSSet
}
