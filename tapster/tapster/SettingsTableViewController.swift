//
//  SettingsTableViewController.swift
//  tapster
//
//  Created by Matthew Lewis on 17/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit
import CoreData

class SettingsTableViewController: UITableViewController, UITableViewDelegate {
    
    let timePickerView  : UIDatePicker = UIDatePicker()
    let buttonCancel: UIButton = UIButton()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let dateFormatter = NSDateFormatter()
    var timer = NSTimer()
    
    var alert: UIAlertController = UIAlertController()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    @IBOutlet weak var labelLastSyncDate: UILabel!
    @IBOutlet weak var switchAlert: UISwitch!
    @IBOutlet weak var labelAlertTime: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(animated: Bool) {
        
        // Set up time picker for alert time setting
        
        timePickerView.datePickerMode = UIDatePickerMode.Time
        timePickerView.addTarget(self, action: Selector("handleTimePicker:"), forControlEvents: UIControlEvents.ValueChanged)
        timePickerView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
        timePickerView.center = CGPoint(x: screenSize.width/2, y: 252)
        timePickerView.layer.borderWidth = 1.0
        timePickerView.layer.borderColor = UIColor.lightGrayColor().CGColor
        timePickerView.hidden = true
        
        view.addSubview(timePickerView)
        
        buttonCancel.setImage(UIImage(named: "icon-cancel.png"), forState: UIControlState.Normal)
        buttonCancel.frame = CGRectMake(screenSize.width - 40, timePickerView.frame.origin.y + 10, 30, 30)
        buttonCancel.addTarget(self, action: "removeTimePicker", forControlEvents: UIControlEvents.TouchUpInside)
        buttonCancel.hidden = true
        
        view.addSubview(buttonCancel)
        
        // Set sync date
        if let lastSyncDate: NSString = NSUserDefaults.standardUserDefaults().valueForKey("lastSyncDate") as? NSString {
            
            labelLastSyncDate.text = lastSyncDate
        }
        else {
            
            labelLastSyncDate.text = "Unknown"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Clicked: Set alert time
        
        if indexPath.section == 0 && indexPath.row == 1 {
            
            // Show time picker
            timePickerView.hidden = false
            buttonCancel.hidden = false
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        // Clicked: Export
        
        if indexPath.section == 2 && indexPath.row == 0 {
            
            // Set up csv output variables
            
            var dateCSV: NSString = ""
            var handCSV: NSString = ""
            var tapCountCSV: NSInteger = 0
            var noteCSV: NSString = ""
            var resultLine: NSString = ""
            
            dateFormatter.dateFormat = "dd-mm-yyyy HH:mm" // Set csv date format
  
            // Initiate core data
            
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext!
            var request = NSFetchRequest(entityName: "Results")

            var fetchError : NSError?

            if let results = context.executeFetchRequest(request, error: &fetchError) {
                
                if results.count > 0 {
                    
                    // Set up file
                    let fileManager = NSFileManager.defaultManager()
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
                    let fileCSV = documentsPath.stringByAppendingPathComponent("taptimal-results.csv")

                    if !fileManager.fileExistsAtPath(documentsPath) {

                        fileManager.createFileAtPath(fileCSV, contents: nil, attributes: nil)
                    }

                    let fileHandle: NSFileHandle? = NSFileHandle(forUpdatingAtPath: fileCSV)

                    if fileHandle == nil {
                        
                        println("Failed to initate file")
                    }
                    else {

                        //fileHandle?.seekToEndOfFile()

                        for result in results {

                            dateCSV = dateFormatter.stringFromDate(result.valueForKey("date") as NSDate) as NSString
                            handCSV = result.valueForKey("hand") as NSString
                            tapCountCSV = result.valueForKey("tapCount") as NSInteger
                            
                            if let noteCSV = result.valueForKey("note") as? NSString {
                            
                                resultLine = ("\(dateCSV), \(handCSV), \(tapCountCSV), \(noteCSV) \n")
                                
                                fileHandle?.writeData(resultLine.dataUsingEncoding(NSUTF8StringEncoding)!)
                                
                                println(resultLine)
                            }
                        }
                        
                        fileHandle?.closeFile()
                        
                        // Generate email
                        let url = NSURL(string: "mailto:?Subject=Taptimal+CSV+data&attachment=\(fileCSV)")
                        
                        UIApplication.sharedApplication().openURL(url!)
                    }
                }
                else {
                    
                    // There are no results to export
                }
            }
        }
        
        // Clicked: Log out
        
        if indexPath.section == 3 && indexPath.row == 0 {
            
            PFUser.logOut()
            
            startLogoutAlert()
            
            timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: Selector("timerCompleted"), userInfo: nil, repeats: false)
        }
    }
    
    func timerCompleted() {
        
        stopLogoutAlert()
    }
    
    func handleTimePicker(sender: UIDatePicker) {
        
        dateFormatter.dateFormat = "HH:mm"
        labelAlertTime.text = dateFormatter.stringFromDate(sender.date)
    }

    func removeTimePicker() {
        
        timePickerView.hidden = true
        buttonCancel.hidden = true
    }
    
    func startLogoutAlert() {
        
        // Set up alert box
        
        alert = UIAlertController(title: "Loging Out...", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        
        // Set up activity indicator
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 75, 75))
        activityIndicator.center = CGPoint(x: self.view.center.x, y: screenSize.height / 2)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        //Lock display from user interaction
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func stopLogoutAlert() {
        
        activityIndicator.stopAnimating()
        
        //Unlock display for resumption of user interaction
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
        alert.dismissViewControllerAnimated(true, completion: {
            
            self.performSegueWithIdentifier("jumpToRegister", sender: nil)
        })
    }
    

    // MARK: - Table view data source

    /*
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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
