//
//  ViewController.swift
//  MMRecordAtlassian
//
//  Created by Conrad Stoll on 6/20/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

import UIKit

class PlansViewController: UITableViewController, UITableViewDataSource {
    var plans: [Plan] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var managedObjectContext = appDelegate.managedObjectContext
        
        Plan.startRequestWithURN("/plans",
            data: nil,
            context: managedObjectContext,
            domain: self,
            resultBlock: {records in
                var results: [Plan] = records as [Plan]
                
                self.plans = results
                self.tableView.reloadData()
            },
            failureBlock: { error in
            
            })
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return plans.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier", forIndexPath: indexPath) as UITableViewCell
        var plan = plans[indexPath.row]
        
        cell.textLabel.text = plan.name
        
        return cell
    }
}

