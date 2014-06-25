//
//  IssuesViewController.swift
//  MMRecordAtlassian
//
//  Created by Conrad Stoll on 6/24/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

import UIKit
import CoreData

class IssuesViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var managedObjectContext = appDelegate.managedObjectContext
        
//        var options = Issue.defaultOptions()
//        options.entityPrimaryKeyInjectionBlock =
//        {(entity: NSEntityDescription, dictionary: NSDictionary, parentProtoRecord: MMRecordProtoRecord) -> NSCopying in
//            return ""
//        }
        
        Issue.startRequestWithURN("/issue",
            data: nil,
            context: managedObjectContext,
            domain: self,
            resultBlock: {records in
                var results: Issue[] = records as Issue[]
                print("\(results)")
                
            },
            failureBlock: { error in
                
            })
    }

}
