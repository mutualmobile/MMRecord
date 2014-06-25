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
    var issue : Issue?
    var links : Link[] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var managedObjectContext = appDelegate.managedObjectContext
        
        var options = Issue.defaultOptions()
        
        options.entityPrimaryKeyInjectionBlock = {(entity, dictionary, parentProtoRecord) -> NSCopying in
            let dict = dictionary as Dictionary
            let key : AnyObject? = dict["id"]
            let returnKey = key as String
            return returnKey
        }
        
        options.recordPrePopulationBlock = { protoRecord in
            let proto : MMRecordProtoRecord = protoRecord
            let entity : NSEntityDescription = protoRecord.entity
            
            var dictionary : AnyObject! = proto.dictionary.mutableCopy()
            var mutableDictionary : NSMutableDictionary = dictionary as NSMutableDictionary
            var primaryKey : AnyObject! = ""
            
            if (entity.name == "OutwardLink") {
                primaryKey = mutableDictionary.valueForKeyPath("outwardIssue.key")
            }
            
            if (entity.name == "InwardLink") {
                primaryKey = mutableDictionary.valueForKeyPath("inwardIssue.key")
            }
            
            mutableDictionary.setValue(primaryKey, forKey: "PrimaryKey")
            
            proto.dictionary = mutableDictionary
        }
        
        Issue.setOptions(options)
        
        Issue.startRequestWithURN("/issue",
            data: nil,
            context: managedObjectContext,
            domain: self,
            resultBlock: {records in
                var results: Issue[] = records as Issue[]

                self.issue = results[results.startIndex]
                
                self.title = "Linked Issues for \(self.issue?.id)"
                
                let array = self.issue?.issueLinks.array
                let linksArray : Link[] = array as Link[]
                    
                if (array) {
                    self.links = linksArray
                }
                
                self.tableView.reloadData()
            },
            failureBlock: { error in
                
            })
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier", forIndexPath: indexPath) as UITableViewCell
        var link = links[indexPath.row]
        
        cell.textLabel.text = link.key
        
        return cell
    }

}
