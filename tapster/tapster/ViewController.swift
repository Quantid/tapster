//
//  ViewController.swift
//  tapster
//
//  Created by Matthew Lewis on 01/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, SideBarDelegate {
    
    var sideBar:SideBar = SideBar()
    
    var timer = NSTimer()
    var tappingHasStarted = false
    var tapCount = 0
    var handSetting = ""
    
    var lat: Double = 0
    var long: Double = 0

    var timeMilliseconds = 0
    var timeSeconds = 0
    var secondsZero = "0"
    
    // History variables
    
    var dateHistoryNote1 = NSDate() // For passing to notes view controller
    var dateHistoryNote2 = NSDate() // For passing to notes view controller
    
    // Main buttons & labels
    
    @IBOutlet weak var buttonRightSelector: UIButton!
    @IBOutlet weak var buttonLeftSelector: UIButton!
    @IBOutlet weak var labelTapToStart: UILabel!
    @IBOutlet weak var labelTapCounter: UILabel!
    @IBOutlet weak var labelTimer: UILabel!
    @IBOutlet weak var buttonTapSurface: UIButton!
    
    // History buttons & labels
    
    @IBOutlet weak var labelHistoryDate1: UILabel!
    @IBOutlet weak var labelHistoryDate2: UILabel!
    @IBOutlet weak var labelHistoryLeftResult1: UILabel!
    @IBOutlet weak var labelHistoryLeftResult2: UILabel!
    @IBOutlet weak var labelHistoryRightResult1: UILabel!
    @IBOutlet weak var labelHistoryRightResult2: UILabel!
    
    @IBAction func actionMenu(sender: AnyObject) {
        
        sideBar.showSideBar(true)
    }

    @IBAction func actionSwitchRight(sender: AnyObject) {
        
        handSetting = "right"
        tapCount = 0
        
        buttonRightSelector.setImage(UIImage(named: "rightON.png"), forState:UIControlState.Normal)
        buttonRightSelector.setImage(UIImage(named: "rightON.png"), forState:UIControlState.Highlighted)
        buttonLeftSelector.setImage(UIImage(named: "leftOFF.png"), forState:UIControlState.Normal)
        buttonLeftSelector.setImage(UIImage(named: "leftOFF.png"), forState:UIControlState.Highlighted)
        buttonTapSurface.setImage(UIImage(named: "tapSurface-r.png"), forState:UIControlState.Normal)
        buttonTapSurface.setImage(UIImage(named: "tapSurface-r.png"), forState:UIControlState.Highlighted)

        resetLabels()
    }
    
    @IBAction func actionSwitchLeft(sender: AnyObject) {
        
        handSetting = "left"
        tapCount = 0
        
        buttonRightSelector.setImage(UIImage(named: "rightOFF.png"), forState:UIControlState.Normal)
        buttonRightSelector.setImage(UIImage(named: "rightOFF.png"), forState:UIControlState.Highlighted)
        buttonLeftSelector.setImage(UIImage(named: "leftON.png"), forState:UIControlState.Normal)
        buttonLeftSelector.setImage(UIImage(named: "leftON.png"), forState:UIControlState.Highlighted)
        buttonTapSurface.setImage(UIImage(named: "tapSurface-l.png"), forState:UIControlState.Normal)
        buttonTapSurface.setImage(UIImage(named: "tapSurface-l.png"), forState:UIControlState.Highlighted)

        resetLabels()
    }
    
    @IBAction func actionTapSurface(sender: AnyObject) {
        
        if tappingHasStarted {
            
            tapCount++
        }
        else {
            
            tapCount = 0
            tappingHasStarted = true
            tapCount++
            timeSeconds = 10
            timeMilliseconds = 0
            
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("timerCountDown"), userInfo: nil, repeats: true)
        }
        
        labelTapCounter.text = String(tapCount)
    }
    
    func timerCountDown(){
        
        if timeSeconds == 0 && timeMilliseconds == 0 {
            
            // Reset timer and variables
            
            timer.invalidate()
            tappingHasStarted = false
            
            // Generate alert to save result of test
            
            var alert = UIAlertController(title: "", message: "Do you want to save this test?", preferredStyle: .ActionSheet)
            
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: {action in

                if self.saveResult() {
                    
                    // saved successfully. Do nothing
                }
                else {
                    
                    // save failed. Present user with an error
                }
            }))
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        }
        else {
            
            // Perform countdown
            
            if (timeMilliseconds == 0){
                
                timeSeconds--
                timeMilliseconds = 10
                
                if (timeSeconds > 9){
                    
                    secondsZero = ""
                }
                else {
                    
                    secondsZero = "0"
                }
            }
            
            timeMilliseconds--
        }
        
        labelTimer.text = "00:\(secondsZero)\(timeSeconds).\(timeMilliseconds)"
    }
    
    func saveResult() -> Bool {
        
        if (handSetting == "left" || handSetting == "right") && tapCount > 0 {
            
            var date = NSDate()
            var shouldPair = getUnpairedResult(handSetting)
            
            if shouldPair.shouldFormPair {
                
                date = shouldPair.date
            }

            // Initialise core data
            
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext!
            var result = NSEntityDescription.insertNewObjectForEntityForName("Results", inManagedObjectContext: context) as NSManagedObject
            var error: NSError?
            
            result.setValue(date, forKey: "date")
            result.setValue(tapCount, forKey: "tapCount")
            result.setValue(handSetting, forKey: "hand")
            result.setValue(0, forKey: "syncStatusParse")
            result.setValue(0, forKey: "syncStatusQuantid")
            result.setValue(lat, forKey: "lat")
            result.setValue(long, forKey: "long")
            
            if !context.save(&error) {
                
                // Save failed. Handle error
                
                println("Could not save \(error), \(error?.userInfo)")
                
                return false
            }
            
            println("Saved!")
            // Save succeeded
            return true
        }
        else {
            
            // Handle error
            
            return false
        }
    }
    
    func resetLabels(){

        labelTimer.text = "00:10.0"
        labelTapCounter.text = "0"
        
        // Generate history
        
        var dates = [NSDate]()
        var tapCount: NSInteger
        var dateString: NSString
        
        var resultsByDate: AnyObject = getRecentResultsByDate()
        
        for var i = 0; i < resultsByDate.count; i++ {
            
            dates.append(resultsByDate[i].valueForKey("date") as NSDate)
        }
        
        
        var i = 1 // label tag counter
        var j = 0 // result record counter
        var counter = 1 // loop counter
        
        while counter <= 2 && counter < dates.count {

            var isPaired = false
            var labelHistoryDate = self.view.viewWithTag(i) as UILabel
            var labelHistoryLeftResult = self.view.viewWithTag(i+1) as UILabel
            var labelHistoryRightResult = self.view.viewWithTag(i+2) as UILabel
            
            // Update variables used for notes segue
            
            if counter == 1 {
                
                dateHistoryNote1 = dates[j]
            } else {
                
                dateHistoryNote2 = dates[j]
            }
            
            // Check for paired results
            
            if j < (dates.count - 1) {
                
                if dates[j] == dates[j+1] {
                    
                    isPaired = true
                }
            }
            
            // Update history with paired or unpaired results

            if isPaired {
                
                dateString = getDateHistoryString(dates[j])
                labelHistoryDate.text = dateString.uppercaseString
                
                tapCount = resultsByDate[j].valueForKey("tapCount") as NSInteger
                labelHistoryLeftResult.text = "L:\(tapCount)"
                
                tapCount = resultsByDate[j+1].valueForKey("tapCount") as NSInteger
                labelHistoryRightResult.text = "R:\(tapCount)"
                
                j = j + 2
            }
            else {
                
                tapCount = resultsByDate[j].valueForKey("tapCount") as NSInteger
                dateString = getDateHistoryString(dates[j])
                labelHistoryDate.text = dateString.uppercaseString
                
                if resultsByDate[j].valueForKey("hand") as NSString == "left" {
                    
                    labelHistoryLeftResult.text = "L:\(tapCount)"
                    labelHistoryRightResult.text = "R:--"
                }
                else {
                    
                    labelHistoryLeftResult.text = "L:--"
                    labelHistoryRightResult.text = "R:\(tapCount)"
                }
                
                j = j + 1
            }
            
            i = i + 3
            
            counter++
        }
    }
    
    func getUnpairedResult(hand: String) -> (shouldFormPair: Bool, date: NSDate) {
        
        /* 
        The Problem: tap testing is conducted individually for each hand - right and left. However, a complete
        "result" is one righthand test and one lefthand test. Therefore, when a RH test and LH test are conducted
        at similar times (within 15 mins of each other) they should be paired at the same result.
        The Solution: one RH test and one LH test are paired into a result by assigning the two tests the same
        timestamp (date). After a test is completed, this getUnpairedResult function finds the date of the most recent
        unpaired test which the current test should be paired with. Pairing must only take places if:
        [@] The most recent test is unpaired
        [@] The most recent test if for the opposite hand
        [@] The most recent test was conducted within the past 15 mins (900 secs)
        */
        
        var responseBool = false
        var responseDate = NSDate()
        var dateMostRecent = NSDate()
        var handMostRecent = ""
        
        // Initialise core data
        
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        var request = NSFetchRequest(entityName: "Results")
        
        //request.returnsObjectsAsFaults = false
        //request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        // Get results ordered by descending date
        
        var resultsByDate: AnyObject = getRecentResultsByDate()

        if resultsByDate.count > 0 {
            
            handMostRecent = resultsByDate[0].valueForKey("hand") as String!
            dateMostRecent = resultsByDate[0].valueForKey("date") as NSDate

            // Checks if most recent result is aleady paired and is for opposite hand
            
            request.predicate = NSPredicate(format: "date = %@ and hand = %@", dateMostRecent, oppositeHand(handMostRecent))
            //request.predicate = NSPredicate(format: "hand = %@", oppositeHand(handMostRecent))
            
            var results = context.executeFetchRequest(request, error: nil)

            if results?.count > 0 {
                
                // Result is already paired. No available pair exisits. Do nothing
            }
            else {
                
                println("unpaired...")
                
                // The test is unpaired. Check is it is older than 15 mins
                
                let interval = NSDate().timeIntervalSinceDate(dateMostRecent)
                
                if interval < 900 {
                    
                    // The test is unpaided AND is less than 15 mins old. Check it is for the opposite hand
                    
                    if hand == oppositeHand(handMostRecent) {
                        
                        responseDate = dateMostRecent
                        responseBool = true
                    }
                }
            }
        }
        
        return (responseBool, responseDate)
    }
    
    func getRecentResultsByDate() -> [AnyObject] {
       
        // Initialise core data
        
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Results")
        
        request.returnsObjectsAsFaults = false

        let sortDescriptor1 = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: "hand", ascending: true)
        let sortDescriptors = [sortDescriptor1, sortDescriptor2]
        request.sortDescriptors = sortDescriptors
        
        // Get results ordered by descending date and ascending hand

        var results = context.executeFetchRequest(request, error: nil)

        return results!
    }
    
    func oppositeHand(hand: String) -> String {
    
        switch hand {
        
        case "right":
            return "left"
    
        case "left":
            return "right"
    
        default:
            return ""
        }
    }
    
    func getDateHistoryString(startDate: NSDate) -> NSString {
        
        var response = ""
        var plural = "s"
        
        let calendar = NSCalendar.autoupdatingCurrentCalendar()
        calendar.timeZone = NSTimeZone.systemTimeZone()
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = calendar.timeZone
        //dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let components = calendar.components(NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMinute,fromDate: startDate, toDate: NSDate(), options: nil)
        let months = components.month
        let days = components.day
        let mins = components.minute
        
        if months > 0 {
            
            if months == 1 {plural = ""}
            response = "\(months) month\(plural) ago"
        } else {
            
            if days > 0 {
                
                if days == 1 {plural = ""}
                response = "\(days) day\(plural) ago"
            } else {
                
                if mins > 0 {
                    
                    let hours = abs(mins/60)
                    
                    if hours > 0 {
                        
                        if hours == 1 {plural = ""}
                        response = "\(hours) hour\(plural) ago"
                    } else {
                        
                        if mins == 1 {plural = ""}
                        response = "\(mins) min\(plural) ago"
                    }
                    
                } else {
                    
                    response = "just now"
                }
            }
        }

        return response
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear history dates
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        let date = dateFormatter.dateFromString("1900-01-01")
        
        dateHistoryNote1 = date!
        dateHistoryNote2 = date!

        // Reset labels, buttons and background
        
        actionSwitchRight(0)
        self.view.backgroundColor = UIColor(red:45/255, green:55/255, blue:64/255, alpha:1.0)
        
        // Establish side bar menu
        
        sideBar = SideBar(sourceView: self.view,
            menuItems: ["Tap Test", "Performance", "Profile", "Settings"],
            menuIconItems: ["icon-menu-taptest.png", "icon-menu-performance.png", "icon-menu-profile.png", "icon-menu-settings.png"])
        
        sideBar.delegate = self
        
        // Get user location
        PFGeoPoint.geoPointForCurrentLocationInBackground {(geoPoint: PFGeoPoint!, error: NSError!) -> Void in
            
            if error == nil {
                
                self.lat = geoPoint.latitude
                self.long = geoPoint.longitude
            }
        }
        
        //Sync measurements with Parse
        
        syncWithParse()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "jumpToNotes" {
            
            var secondVC: NotesViewController = segue.destinationViewController as NotesViewController
            
            secondVC.dateOfNote = dateHistoryNote1
            secondVC.returnSegue = "jumpToMain"
        }
    }
    
    func syncWithParse() {
        
        /*
        Sync local measurement results with Parse
        Step 1. Upload new local measurements (where syncStatusParse = 0) to Parse
        Step 2. Remove deleted local measurements (where syncStatusParse = 2) from Parse
        Step 3. If a local measurement has been updated/edited (where syncStatusParse = 3) then update the matching Parse record
        */
        
        // Initiate core data
        
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        // Get unsynced measurements (where syncStatusParse = 0) and upload to Parse
        
        var request = NSFetchRequest(entityName: "Results")
        var filterPredicate: NSPredicate = NSPredicate(format: "syncStatusParse = %@", "0")!
        request.predicate = filterPredicate
        
        var fetchError : NSError?
        
        if let results = context.executeFetchRequest(request, error: &fetchError) {
            
            if results.count > 0 {
                
                println("Syncing...")
                
                for result in results {
                    
                    var post = PFObject(className: "Results")
                    
                    post["username"] = PFUser.currentUser().username
                    post["date"] = result.valueForKey("date")
                    post["hand"] = result.valueForKey("hand")
                    post["tapCount"] = result.valueForKey("tapCount")
                    post["note"] = result.valueForKey("note")
                    post["lat"] = result.valueForKey("lat")
                    post["long"] = result.valueForKey("long")
                    
                    post.saveInBackgroundWithBlock {(success: Bool, postError:NSError!) -> Void in
                        
                        if success {
                            
                            result.setValue(1, forKey: "syncStatusParse")
                        }
                        else {
                            
                            //TO DO: Handle error...probably update NSlog
                            println(postError)
                        }
                    }
                    
                    context.save(nil)
                }
            }
            else {
                
                println("Nothing to sync...")
            }
        }
        else {
            
            println("Fetch failed: \(fetchError)")
        }
        
        // Remove deleted measurements from Parse
        
        filterPredicate = NSPredicate(format: "syncStatusParse = %@", "2")!
        request.predicate = filterPredicate
        
        if let results = context.executeFetchRequest(request, error: &fetchError) {
            
            if results.count > 0 {
                
                println("Some deleted records found")
            }
            else {
                
                println("No deleted records found")
            }
            
            for result in results {
                
                var post = PFObject(className: "Results")
                
                // TO DO: delete records from Parse and the delete from core data
            }
        }
        else {
            
            println("Fetch failed: \(fetchError)")
        }
        
        // Finally, update measurements on Parse which haved been updated locally
        
        filterPredicate = NSPredicate(format: "syncStatusParse = %@", "3")!
        request.predicate = filterPredicate
        
        if let results = context.executeFetchRequest(request, error: &fetchError) {
            
            if results.count > 0 {
                
                println("Some updated records found")
            }
            else {
                
                println("No updated records found")
            }
            
            for result in results {
                
                var post = PFObject(className: "Results")
                
                // TO DO: delete records from Parse and the delete from core data
            }
        }
        else {
            
            println("Fetch failed: \(fetchError)")
        }
    }
    
    func sideBarDidSelectButtonAtIndex(index: Int) {
        
        switch index {
            
        case 0:
            
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
            
        case 1:

            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PerformanceView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)

        case 2:
            println("button2")
        case 3:
            println("button3")
        default:
           println("default")
        }
    }
}

