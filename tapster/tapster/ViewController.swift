//
//  ViewController.swift
//  tapster
//
//  Created by Matthew Lewis on 01/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var timer = NSTimer()
    var tappingHasStarted = false
    var tapCount = 0
    var handSetting = ""

    var timeMilliseconds = 0
    var timeSeconds = 0
    var secondsZero = "0"
    
    // Main buttons & labels
    
    @IBOutlet weak var buttonRightSelector: UIButton!
    @IBOutlet weak var buttonLeftSelector: UIButton!
    @IBOutlet weak var labelTapToStart: UILabel!
    @IBOutlet weak var labelTapCounter: UILabel!
    @IBOutlet weak var labelTimer: UILabel!
    @IBOutlet weak var buttonTapSurface: UIButton!
    
    // History buttons & labels
    
    @IBOutlet weak var labelHistoryDate1: UILabel!
    @IBOutlet weak var labelHistoryLeftResult1: UILabel!
    @IBOutlet weak var labelHistoryRightResult1: UILabel!
    

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
        
        // Reset history
        
        var tapCount: NSInteger
        var dateString: NSString
        
        var resultsByDate: AnyObject = getRecentResultsByDate()
        
        if resultsByDate.count > 0 {
            
            var date1 = resultsByDate[0].valueForKey("date") as NSDate
            var date2 = resultsByDate[1].valueForKey("date") as NSDate
            var date3 = resultsByDate[2].valueForKey("date") as NSDate
            var date4 = resultsByDate[3].valueForKey("date") as NSDate

            if date1 == date2 {

                dateString = getDateHistoryString(date1)
                labelHistoryDate1.text = dateString.uppercaseString
                
                tapCount = resultsByDate[0].valueForKey("tapCount") as NSInteger
                labelHistoryLeftResult1.text = "L:\(tapCount)"
                
                tapCount = resultsByDate[1].valueForKey("tapCount") as NSInteger
                labelHistoryRightResult1.text = "R:\(tapCount)"
            }
            else {
                
                tapCount = resultsByDate[0].valueForKey("tapCount") as NSInteger
                dateString = getDateHistoryString(date1)
                labelHistoryDate1.text = dateString.uppercaseString
                
                if resultsByDate[0].valueForKey("hand") as NSString == "left" {
                    
                    labelHistoryLeftResult1.text = "L:\(tapCount)"
                    labelHistoryRightResult1.text = "R:"
                }
                else {
                
                    labelHistoryLeftResult1.text = "L:"
                    labelHistoryRightResult1.text = "R:\(tapCount)"
                }
            }
        }
        else {
            
            // No results found (must be new user). Clear all history labels
            
            labelHistoryDate1.text = ""
            labelHistoryLeftResult1.font = labelHistoryLeftResult1.font.fontWithSize(20)
            labelHistoryLeftResult1.text = "No activity yet. Start tapping..."
            labelHistoryRightResult1.text = ""
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
        
        // Get results ordered by descending date

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

        // Reset labels, buttons and background
        
        actionSwitchRight(0)
        self.view.backgroundColor = UIColor(red:51/255, green:58/255, blue:64/255, alpha:1.0)
        
        //tapCount = 45
        //handSetting = "left"
        //saveResult()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

