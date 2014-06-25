//
//  MMRecordAtlassian.Link
//  MMRecordAtlassian
//
//  Created by Conrad Stoll on 6/24/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

import CoreData

class Link: ATLRecord {
    @NSManaged var id: NSString
    @NSManaged var name: NSString
    @NSManaged var key: NSString
}
