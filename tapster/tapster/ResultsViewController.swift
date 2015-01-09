//
//  ResultsTableViewController.swift
//  tapster
//
//  Created by Matthew Lewis on 02/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit
import CoreData

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    
    var rightScore = [NSInteger]()
    var leftScore = [NSInteger]()
    var monthString = [NSString]()
    var dayString = [NSString]()
    var dateResult = [NSDate]()

    var ac = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self

        var dateMonthFormatter = NSDateFormatter()
        var dateDayFormatter = NSDateFormatter()
        
        dateMonthFormatter.dateFormat = "MMM"
        dateDayFormatter.dateFormat = "dd"


        // Initialise core data
        
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Results")
     
        request.propertiesToFetch = NSArray(object: "date")
        request.returnsObjectsAsFaults = false
        request.returnsDistinctResults = true
        request.resultType = NSFetchRequestResultType.DictionaryResultType
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        var dates:NSArray = context.executeFetchRequest(request, error: nil)!
        
        for date in dates {
            
            let dateQuery = date["date"] as NSDate
            
            var request = NSFetchRequest(entityName: "Results")
            
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "date = %@", dateQuery)

            var results = context.executeFetchRequest(request, error: nil)!

            if results[0].valueForKey("hand")! as NSString == "right" {
                
                rightScore.append(results[0].valueForKey("tapCount") as NSInteger)
                
                if results.count > 1 {
                    
                    leftScore.append(results[1].valueForKey("tapCount") as NSInteger)
                }
                else {
                    
                    leftScore.append(0)
                }
            }
            else {
                
                leftScore.append(results[0].valueForKey("tapCount") as NSInteger)
                
                if results.count > 1 {
                    
                    rightScore.append(results[1].valueForKey("tapCount") as NSInteger)
                }
                else {
                    
                    rightScore.append(0)
                }
            }
        
            dateResult.append(results[0].valueForKey("date") as NSDate)

            monthString.append(dateMonthFormatter.stringFromDate(dateQuery) as NSString)
            dayString.append(dateDayFormatter.stringFromDate(dateQuery) as NSString)
            
            ac = rightScore.count
            
            var dateString = dayString[ac-1] + monthString[ac-1]
            
            println("\(ac):")
          
            println("\(dateString) = [R]\(rightScore[ac-1]) [L]\(leftScore[ac-1])")
            
            //tableView?.reloadData()
        }
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        return rightScore.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: cellResult = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as cellResult

        //cell.textLabel?.text = dateString[indexPath.row]
        //cell.textLabel?.text = score[indexPath.row]
        
        cell.labelDay.text = dayString[indexPath.row]
        cell.labelMonth.text = monthString[indexPath.row].uppercaseString
        cell.labelLeftScore.text = "L:" + String(leftScore[indexPath.row])
        cell.labelRightScore.text = "R:" + String(rightScore[indexPath.row])
        
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "jumpToNotes" {
            
            if let selectedIndex = self.tableView.indexPathForSelectedRow()?.row {
                
                var dateOfSelectedItem = dateResult[selectedIndex] as NSDate
                
                var secondVC: NotesViewController = segue.destinationViewController as NotesViewController
                
                secondVC.dateOfNote = dateOfSelectedItem
                secondVC.returnSegue = "jumpToResults"
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
