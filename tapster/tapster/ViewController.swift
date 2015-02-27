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

    var buttonTapSurface: UIButton = UIButton()
    let labelTapToStart: UILabel! = UILabel()
    let labelGetTapping: UILabel = UILabel()
    var imageMedals:[UIImageView] = []
    let buttonHistory1 = UIButton()
    let buttonHistory2 = UIButton()
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let dateFormatter = NSDateFormatter()
    
    var timer = NSTimer()
    var tappingHasStarted = false
    var tapCount = 0
    var handSetting = ""
    var tapsurfaceFileName = ""
    
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
    @IBOutlet weak var labelTapCounter: UILabel!
    @IBOutlet weak var labelTimer: UILabel!
    
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
        buttonTapSurface.setImage(UIImage(named: tapsurfaceFileName + "-R.png"), forState:UIControlState.Normal)
        buttonTapSurface.setImage(UIImage(named: tapsurfaceFileName + "-R.png"), forState:UIControlState.Highlighted)

        resetLabels()
    }
    
    @IBAction func actionSwitchLeft(sender: AnyObject) {
        
        handSetting = "left"
        tapCount = 0
        
        buttonRightSelector.setImage(UIImage(named: "rightOFF.png"), forState:UIControlState.Normal)
        buttonRightSelector.setImage(UIImage(named: "rightOFF.png"), forState:UIControlState.Highlighted)
        buttonLeftSelector.setImage(UIImage(named: "leftON.png"), forState:UIControlState.Normal)
        buttonLeftSelector.setImage(UIImage(named: "leftON.png"), forState:UIControlState.Highlighted)
        buttonTapSurface.setImage(UIImage(named: tapsurfaceFileName + "-L.png"), forState:UIControlState.Normal)
        buttonTapSurface.setImage(UIImage(named: tapsurfaceFileName + "-L.png"), forState:UIControlState.Highlighted)

        resetLabels()
    }
    
    func actionTapSurface(sender: AnyObject) {
        
        if tappingHasStarted {
            
            tapCount++
        }
        else {
            
            tapCount = 0
            tappingHasStarted = true
            tapCount++
            timeSeconds = 10
            timeMilliseconds = 0
            labelTapToStart.hidden = true
            
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("timerCountDown"), userInfo: nil, repeats: true)
        }
        
        labelTapCounter.text = String(tapCount)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red:45/255, green:55/255, blue:64/255, alpha:1.0)
        
        // Set history background at bottom of screen
        
        var historyBackgroundWidth = 375
        var image = UIImage(named: "background-history-375.png")
        
        if screenSize.width == 414 {
            
            historyBackgroundWidth = 414
            var image = UIImage(named: "background-history-414.png")
        }
        
        let imageBackgroundHistory = UIImageView(image: image)
        imageBackgroundHistory.frame = CGRectMake(0, screenSize.height - 115, 375 , 115)
        imageBackgroundHistory.contentMode = UIViewContentMode.ScaleAspectFill
        
        view.addSubview(imageBackgroundHistory)
        view.sendSubviewToBack(imageBackgroundHistory)
        
        // Set the two disclosure symbols
        
        image = UIImage(named: "icon-disclosure.png")
        
        let imageDisclose1 = UIImageView(image: image)
        let imageDisclose2 = UIImageView(image: image)
        
        imageDisclose1.frame = CGRectMake(screenSize.width - 25, screenSize.height - 78, 13, 14)
        imageDisclose2.frame = CGRectMake(screenSize.width - 25, screenSize.height - 30, 13, 14)
        
        view.addSubview(imageDisclose1)
        view.addSubview(imageDisclose2)
        
        // Set the two history buttons
        
        buttonHistory1.frame = CGRectMake(0, screenSize.height - 100, screenSize.width, 48)
        buttonHistory1.tag = 19
        buttonHistory1.addTarget(self, action: "actionHistoryButtonPress:", forControlEvents: UIControlEvents.TouchUpInside)
        
        buttonHistory2.frame = CGRectMake(0, screenSize.height - 50, screenSize.width, 48)
        buttonHistory2.tag = 29
        buttonHistory2.addTarget(self, action: "actionHistoryButtonPress:", forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(buttonHistory1)
        view.addSubview(buttonHistory2)
        
        // Clear history dates
        
        dateFormatter.dateFormat = "yyyy-mm-dd"
        let date = dateFormatter.dateFromString("1900-01-01")
        
        dateHistoryNote1 = date!
        dateHistoryNote2 = date!
        
        // Setup medals
        
        imageMedals.append(UIImageView())
        imageMedals.append(UIImageView())
        
        var x: CGFloat = (screenSize.width - 60) as CGFloat
        var y: CGFloat = screenSize.height - 74
        
        for var i = 0; i < 2; i++ {
            
            if i == 1 {
                y = y + 48
            }
            
            imageMedals[i].frame = CGRectMake(-90, -90, 35, 35)
            imageMedals[i].contentMode = UIViewContentMode.ScaleAspectFit
            imageMedals[i].center = CGPoint(x: x, y: y)
            
            view.addSubview(imageMedals[i])
        }

        // Setup tap surface button depending on device
        
        switch screenSize.width {
            
        case 320:
            
            if screenSize.height == 480 {
                
                //iphone4
                println("this is an iPhone4")
                tapsurfaceFileName = "tap-surface-iphone4"
                buttonTapSurface.frame = CGRectMake(25, 85, 270, 225)
            } else {
                //iphone5
                println("this is an iPhone5")
                tapsurfaceFileName = "tap-surface-iphone5"
                buttonTapSurface.frame = CGRectMake(25, 85, 270, 300)
            }
        case 375:
            //iphone6
            tapsurfaceFileName = "tap-surface-iphone6"
            buttonTapSurface.frame = CGRectMake(25, 85, 325, 400)
        case 414:
            //iphone6plus
            tapsurfaceFileName = "tap-surface-iphone6"
            buttonTapSurface.frame = CGRectMake(45, 85, 325, 400)
        default:
            //iphone5
            tapsurfaceFileName = "tap-surface-iphone3"
            buttonTapSurface.frame = CGRectMake(25, 85, 270, 225)
        }
        
        buttonTapSurface.setImage(UIImage(named: tapsurfaceFileName + "-R.png"), forState:UIControlState.Normal)
        buttonTapSurface.setImage(UIImage(named: tapsurfaceFileName + "-R.png"), forState:UIControlState.Highlighted)
        buttonTapSurface.addTarget(self, action: "actionTapSurface:", forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(buttonTapSurface)
        
        labelTapToStart.frame = CGRectMake(0, 0, 150, 21)
        labelTapToStart.center = CGPoint(x: buttonTapSurface.center.x, y: buttonTapSurface.frame.height + 65)
        labelTapToStart.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        labelTapToStart.textColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
        labelTapToStart.textAlignment = NSTextAlignment.Center
        labelTapToStart.text = "Tap to start"
        
        view.addSubview(labelTapToStart)
        
        refreshHistory() // Reset history
        
        actionSwitchRight(0) // Reset labels and buttons
        
        // Get user location
        PFGeoPoint.geoPointForCurrentLocationInBackground {(geoPoint: PFGeoPoint!, error: NSError!) -> Void in
            
            if error == nil {
                
                self.lat = geoPoint.latitude
                self.long = geoPoint.longitude
            }
        }
        
        // Establish side bar menu
        
        sideBar = SideBar(sourceView: self.view)
        sideBar.delegate = self
        
        SettingsViewController().syncWithParse()    // Sync core data records with Parse
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    
                    // saved successfully
                    
                    SettingsViewController().syncWithParse()    // Sync core data records with Parse
                    
                    self.refreshHistory()
                    
                    // Now switch over to the other hand
                    
                    if self.handSetting == "left" {
                        self.actionSwitchRight(self)
                    } else {
                        self.actionSwitchLeft(self)
                    }
                }
                else {
                    // save failed. Present user with an error
                }
            }))
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Destructive, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            self.labelTapToStart.hidden = false
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
            
            println("Success - saved!")
            
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
    }
    
    func refreshHistory() {

        var dates = [NSDate]()
        var tapCount: NSInteger
        var dateString: NSString
        var isPaired = false
        
        // Enable history buttons
        
        buttonHistory1.enabled = true
        buttonHistory2.enabled = true
        
        labelGetTapping.text = "" // Clear get tapping message (if it's there)
        
        var resultsByDate: AnyObject = getRecentResultsByDate()
        
        if resultsByDate.count > 0 {
            
            for var i = 0; i < resultsByDate.count; i++ {
                
                dates.append(resultsByDate[i].valueForKey("date") as NSDate)
            }
            
            
            var i = 1 // label tag counter
            var j = 0 // result record counter
            var counter = 0 // loop counter ensures two loops happen ONLY when there's a sufficient number of results
            
            while (counter < 2 && counter < dates.count) || (counter == 2 && isPaired && counter < dates.count) {

                isPaired = false
                var labelHistoryDate = self.view.viewWithTag(i) as UILabel
                var labelHistoryLeftResult = self.view.viewWithTag(i+1) as UILabel
                var labelHistoryRightResult = self.view.viewWithTag(i+2) as UILabel
                
                // Update variables used for notes segue
                
                if counter == 0 {
                    
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
                    labelHistoryLeftResult.text = "L\(tapCount)"
                    
                    var average = tapCount
                    
                    tapCount = resultsByDate[j+1].valueForKey("tapCount") as NSInteger
                    labelHistoryRightResult.text = "R\(tapCount)"
                    
                    average = (average + tapCount) / 2
                    
                    awardMedals(average, slot: i)
                    
                    j = j + 2
                    
                    counter++
                }
                else {
                    
                    tapCount = resultsByDate[j].valueForKey("tapCount") as NSInteger
                    dateString = getDateHistoryString(dates[j])
                    labelHistoryDate.text = dateString.uppercaseString
                    
                    if resultsByDate[j].valueForKey("hand") as NSString == "left" {
                        labelHistoryLeftResult.text = "L\(tapCount)"
                        labelHistoryRightResult.text = "R--"
                    }
                    else {
                        labelHistoryLeftResult.text = "L--"
                        labelHistoryRightResult.text = "R\(tapCount)"
                    }
                    j = j + 1
                }
                i = i + 3
                
                counter++
            }
            
            // Check if there's only results for the first row of the history. If so, erase second row labels
            
            if counter == 1 || (dates.count == 2 && isPaired){
                
                // Clear all unused history labels
                
                labelHistoryDate2.text = ""
                labelHistoryLeftResult2.text = ""
                labelHistoryRightResult2.text = ""
                buttonHistory2.hidden = true
            }
        }
        else {
            
            // This must be a new user
            
            // Clear all unused history labels
            
            labelHistoryDate2.text = ""
            labelHistoryLeftResult1.text = ""
            labelHistoryRightResult1.text = ""
            labelHistoryLeftResult2.text = ""
            labelHistoryRightResult2.text = ""
            
            // Give new users a motivational message to appear in the history
            
            labelGetTapping.frame = CGRectMake(0, 0, 300, 18)
            labelGetTapping.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
            labelGetTapping.font = UIFont(name: "HelveticaNeue", size: 14)
            labelGetTapping.textAlignment = NSTextAlignment.Center
            labelGetTapping.center = CGPoint(x: screenSize.width / 2, y: screenSize.height - 70)
            labelGetTapping.text = "No results yet. Let's get tapping..."
            labelHistoryDate1.text = "JUST NOW"

            view.addSubview(labelGetTapping)
            
            // Disable history buttons
            
            buttonHistory1.enabled = false
            buttonHistory2.enabled = false
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
        request.predicate = NSPredicate(format: "syncStatusParse < %@", "3")!
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
    
    func actionHistoryButtonPress(sender: UIButton!) {
        
        // Alert to select notes or sharing
        var alert = UIAlertController(title: "", message: "Share with your friends or add note..", preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.Default, handler: {action in
            self.performSegueWithIdentifier("jumpToSharing", sender: sender)
        }))
        alert.addAction(UIAlertAction(title: "Add a Note", style: UIAlertActionStyle.Default, handler: {action in
            self.performSegueWithIdentifier("jumpToNotes", sender: sender)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var isForSharing: Bool = false
        
        let segueIdentifier = segue.identifier!
        if segueIdentifier == "jumpToSharing" {
            isForSharing = true
        }

        if let senderId = sender?.tag {
            
            var secondVC: NotesViewController = segue.destinationViewController as NotesViewController
            
            switch senderId {
                case 19:
                    secondVC.dateOfNote = dateHistoryNote1
                    secondVC.isForSharing = isForSharing
                case 29:
                    secondVC.dateOfNote = dateHistoryNote2
                    secondVC.isForSharing = isForSharing
                default:
                    NSLog("Segue to notes view. Should not see this senderId. SenderId = %d", senderId)
            }
            secondVC.returnSegue = "jumpToMain"
        }
    }
    
    func awardMedals(average: NSInteger, slot: NSInteger){
        
        let imageStrong: UIImage = UIImage(named: "medal-strong.png")!
        let imageGood: UIImage = UIImage(named: "medal-good.png")!
        let imageWeak: UIImage = UIImage(named: "medal-weak.png")!
        
        var strongThreshold: NSInteger = 0
        var weakThreshold: NSInteger = 0
        
        var i = slot
        
        if slot == 4 {
            i = 1
        } else {
            i = 0
        }

        if let strongT: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("strongThreshold") {
            strongThreshold = strongT as NSInteger
        }
        
        if let weakT: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("weakThreshold") {
            weakThreshold = weakT as NSInteger
        }
        
        
        if strongThreshold > 0 && weakThreshold > 0 {
            imageMedals[i].image = imageWeak
            
            if average > weakThreshold {
                imageMedals[i].image = imageGood
            }
            
            if average >= strongThreshold {
                imageMedals[i].image = imageStrong
            }
        }
        else {
            imageMedals[i].image = imageGood
        }
    }
    
    func sideBarDidSelectButtonAtIndex(index: Int) {
        // Managed slide-out side bar menu
        switch index {
            case 0:
                let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainView") as UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            case 1:
                let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PerformanceView") as UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            case 2:
                let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RankingView") as UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            case 3:
                let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileView") as UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            case 4:
                let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SettingsView") as UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            default:
               println("default")
        }
    }
}

