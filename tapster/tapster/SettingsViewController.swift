//
//  TestViewController.swift
//  tapster
//
//  Created by Matthew Lewis on 21/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class SettingsViewController: UIViewController, SideBarDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate {
    
    let delegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    var sideBar:SideBar = SideBar()
    
    let scrollView: UIScrollView = UIScrollView()
    var timer = NSTimer()
    let timePickerView  : UIDatePicker = UIDatePicker()
    let switchReminder: UISwitch = UISwitch()
    let switchSharing: UISwitch = UISwitch()
    let buttonCancel: UIButton = UIButton()
    let labelReminderTime: UILabel = UILabel()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let dateFormatter = NSDateFormatter()
    let message: UIAlertView = UIAlertView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var alertLogout: UIAlertController = UIAlertController()
    
    var imageLabelBackgrounds: [UIImageView] = []
    var labelTitles: [UILabel] = []
    var labelSubs: [UILabel] = []
    
    @IBOutlet weak var buttonImportCSV: UIButton!
    @IBAction func actionImportCSV(sender: AnyObject) {
        importCSVFile()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonImportCSV.hidden = true
        
        // Menu selector button
        
        let buttonMenuSelector: UIButton = UIButton(frame: CGRectMake(10, 14, 40, 40))
        buttonMenuSelector.setImage(UIImage(named: "icon-menu-selector.png"), forState: UIControlState.Normal)
        buttonMenuSelector.contentMode = UIViewContentMode.ScaleAspectFit
        buttonMenuSelector.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 0)
        buttonMenuSelector.addTarget(self, action: "actionMenu", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(buttonMenuSelector)
        
        scrollView.frame = self.view.bounds
        scrollView.contentSize = CGSize(width: screenSize.width, height: 750)
        scrollView.center = CGPoint(x: screenSize.width/2, y: screenSize.height/2 + 60)
        scrollView.backgroundColor = UIColor(red: 242/255, green: 244/255, blue: 245/255, alpha: 1.0)
        scrollView.scrollEnabled = true
        view.addSubview(scrollView)
        
        var labelBackgroundPositionY = [30, 5, 30, 30, 5, 30, 30, 30, 30]
        var labelTitleText = ["Morning Reminder", "Reminder Time", "Sharing", "Sync Status", "Cloud Restore", "Export Data", "Your Feedback", "Log Out of Taptimal", "Version:"]
        var labelSubText = [
            "Receive a reminder every morning to do test",
            "Set the time you want to receive the alert",
            "Allow others to see your life average score",
            "Last sync conducted at:",
            "Restore your data backed-up in the cloud",
            "Export your results as a CSV file",
            "Tell us what you think about Taptimal",
            "Logging out will not remove your data",
            "Current version"
        ]
        
        var spacingY = 0
        
        for var i = 0; i < labelBackgroundPositionY.count; i++ {
            
            spacingY = spacingY + labelBackgroundPositionY[i] + 45
            
            imageLabelBackgrounds.append(UIImageView(image: UIImage(named: "label-background.png")!))
            imageLabelBackgrounds[i].frame = CGRectMake(0, 0, screenSize.width, 45)
            imageLabelBackgrounds[i].center = CGPoint(x: screenSize.width/2, y: CGFloat(spacingY))
            scrollView.addSubview(imageLabelBackgrounds[i])
            
            labelTitles.append(UILabel(frame: CGRect(x: 8, y: spacingY - 20, width: 200, height: 22)))
            labelTitles[i].textColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0)
            labelTitles[i].font = UIFont(name: "HelveticaNeue-Regular", size: 22)
            labelTitles[i].text = labelTitleText[i]
            labelTitles[i].textAlignment = NSTextAlignment.Left
            scrollView.addSubview(labelTitles[i])
            
            labelSubs.append(UILabel(frame: CGRect(x: 8, y: spacingY, width: 300, height: 18)))
            labelSubs[i].textColor = UIColor(red: 110/255, green: 110/255, blue: 110/255, alpha: 1.0)
            labelSubs[i].font = UIFont(name: "HelveticaNeue-Light", size: 13)
            labelSubs[i].text = labelSubText[i]
            labelSubs[i].textAlignment = NSTextAlignment.Left
            scrollView.addSubview(labelSubs[i])
        }

        // SETUP BUTTONS AND CONTROLS
        
        // Setup reminder switch
        
        switchReminder.onTintColor = UIColor(red: 86/255, green: 199/255, blue: 149/255, alpha: 1.0)
        switchReminder.center = CGPoint(x: screenSize.width - 32, y: imageLabelBackgrounds[0].center.y)
        switchReminder.addTarget(self, action: "actionSetReminderNotification", forControlEvents: UIControlEvents.ValueChanged)
        if let reminderStatus = NSUserDefaults.standardUserDefaults().objectForKey("isReminderSet") as? NSString {
            
            if reminderStatus == "true" {
                switchReminder.on = true
            }
            else {
                switchReminder.on = false
            }
        }
        else {
            switchReminder.on = false
        }
        
        // Setup button and the label for selecting the reminder time
        
        let buttonSetTime: UIButton = UIButton(frame: CGRectMake(0, 0, screenSize.width, 45))
        buttonSetTime.center = CGPoint(x: imageLabelBackgrounds[1].center.x, y: imageLabelBackgrounds[1].center.y)
        buttonSetTime.addTarget(self, action: "actionSetReminderTime", forControlEvents: UIControlEvents.TouchUpInside)
        
        labelReminderTime.frame = CGRect(x: 0, y: 0, width: 50, height: 24)
        labelReminderTime.center = CGPoint(x: screenSize.width - 32, y: imageLabelBackgrounds[1].center.y)
        labelReminderTime.textColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0)
        labelReminderTime.font = UIFont(name: "HelveticaNeue-Regular", size: 24)
        if let reminderTime = NSUserDefaults.standardUserDefaults().objectForKey("ReminderTime") as? NSString {
 
            labelReminderTime.text = reminderTime
        }
        else {
            
            labelReminderTime.text = "07:30"
        }
        labelReminderTime.textAlignment = NSTextAlignment.Right
        
        // Setup sharing switch
        
        switchSharing.onTintColor = UIColor(red: 86/255, green: 199/255, blue: 149/255, alpha: 1.0)
        switchSharing.center = CGPoint(x: screenSize.width - 32, y: imageLabelBackgrounds[2].center.y)
        switchSharing.addTarget(self, action: "actionSetSharing", forControlEvents: UIControlEvents.ValueChanged)
        if let sharingStatus = NSUserDefaults.standardUserDefaults().objectForKey("isSharing") as? NSString {
            if sharingStatus == "true" {
                
                switchSharing.on = true
            }
            else {
                
                switchSharing.on = false
            }
        }
        else {
            
            switchSharing.on = false
        }
        
        // Setup the label which shows the most recent sync time
        
        let labelLastSyncDate: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 18))
        labelLastSyncDate.textColor = UIColor(red: 110/255, green: 110/255, blue: 110/255, alpha: 1.0)
        labelLastSyncDate.font = UIFont(name: "HelveticaNeue-Light", size: 13)
        labelLastSyncDate.center = CGPoint(x: 220, y: labelSubs[3].center.y)
        // Set sync date
        if let lastSyncDateText: NSString = NSUserDefaults.standardUserDefaults().valueForKey("lastSyncDate") as? NSString {
            
            labelLastSyncDate.text = lastSyncDateText
        }
        else {
            
            labelLastSyncDate.text = "Unknown"
        }
        
        // Setup the button which forces a SYNC
        
        let buttonSync: UIButton = UIButton(frame: CGRectMake(0, 0, screenSize.width, 45))
        buttonSync.setImage(UIImage(named: "icon-disclosure.png"), forState: UIControlState.Normal)
        buttonSync.imageEdgeInsets = UIEdgeInsetsMake(0, buttonSync.frame.width-15, 0, 0)
        buttonSync.center = CGPoint(x: imageLabelBackgrounds[4].center.x, y: imageLabelBackgrounds[4].center.y)
        buttonSync.addTarget(self, action: "actionCloudRestore", forControlEvents: UIControlEvents.TouchUpInside)
        
        // Set up EXPORT button
        
        let buttonExport: UIButton = UIButton(frame: CGRectMake(0, 0, screenSize.width, 45))
        buttonExport.setImage(UIImage(named: "icon-disclosure.png"), forState: UIControlState.Normal)
        buttonExport.imageEdgeInsets = UIEdgeInsetsMake(0, buttonExport.frame.width-15, 0, 0)
        buttonExport.center = CGPoint(x: imageLabelBackgrounds[5].center.x, y: imageLabelBackgrounds[5].center.y)
        buttonExport.addTarget(self, action: "actionExport", forControlEvents: UIControlEvents.TouchUpInside)
        
        // Set up FEEDBACK button
        
        let buttonFeedback: UIButton = UIButton(frame: CGRectMake(0, 0, screenSize.width, 45))
        buttonFeedback.setImage(UIImage(named: "icon-disclosure.png"), forState: UIControlState.Normal)
        buttonFeedback.imageEdgeInsets = UIEdgeInsetsMake(0, buttonExport.frame.width-15, 0, 0)
        buttonFeedback.center = CGPoint(x: imageLabelBackgrounds[6].center.x, y: imageLabelBackgrounds[6].center.y)
        buttonFeedback.addTarget(self, action: "actionFeedback", forControlEvents: UIControlEvents.TouchUpInside)
        
        // Set up LOGOUT button
        
        let buttonLogout: UIButton = UIButton(frame: CGRectMake(0, 0, screenSize.width, 45))
        buttonLogout.setImage(UIImage(named: "icon-disclosure.png"), forState: UIControlState.Normal)
        buttonLogout.imageEdgeInsets = UIEdgeInsetsMake(0, buttonLogout.frame.width-15, 0, 0)
        buttonLogout.center = CGPoint(x: imageLabelBackgrounds[7].center.x, y: imageLabelBackgrounds[7].center.y)
        buttonLogout.addTarget(self, action: "actionLogout", forControlEvents: UIControlEvents.TouchUpInside)
        
        // Set up version number label
        
        let labelVersion: UILabel = UILabel(frame: CGRectMake(0, 0, 50, 24))
        labelVersion.center = CGPoint(x: screenSize.width - 32, y: imageLabelBackgrounds[8].center.y)
        labelVersion.textColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0)
        labelVersion.font = UIFont(name: "HelveticaNeue-Regular", size: 24)
        labelVersion.text = delegate.versionNumber
        
        scrollView.addSubview(switchReminder)
        scrollView.addSubview(labelReminderTime)
        scrollView.addSubview(labelLastSyncDate)
        scrollView.addSubview(switchSharing)
        scrollView.addSubview(buttonSync)
        scrollView.addSubview(buttonExport)
        scrollView.addSubview(buttonFeedback)
        scrollView.addSubview(buttonSetTime)
        scrollView.addSubview(buttonLogout)
        scrollView.addSubview(labelVersion)
        
        // Set up time picker for alert time setting
        
        timePickerView.datePickerMode = UIDatePickerMode.Time
        //timePickerView.addTarget(self, action: Selector("handleTimePicker:"), forControlEvents: UIControlEvents.ValueChanged)
        timePickerView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
        timePickerView.center = CGPoint(x: screenSize.width/2, y: 252)
        timePickerView.layer.borderWidth = 1.0
        timePickerView.layer.borderColor = UIColor.lightGrayColor().CGColor
        timePickerView.hidden = true
        
        view.addSubview(timePickerView)
        
        buttonCancel.setImage(UIImage(named: "icon-cancel.png"), forState: UIControlState.Normal)
        buttonCancel.frame = CGRectMake(screenSize.width - 40, timePickerView.frame.origin.y + 10, 30, 30)
        buttonCancel.addTarget(self, action: "handleTimePicker:", forControlEvents: UIControlEvents.TouchUpInside)
        buttonCancel.hidden = true
        
        view.addSubview(buttonCancel)
        
        // Establish side bar menu
        
        sideBar = SideBar(sourceView: self.view)
        sideBar.delegate = self
        
        // Register app to receive notifications
        
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Sound, categories: nil))
        }
        else {
            
            // User hasn't enabled notification (I think)
        }
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func actionSetReminderNotification() {
        
        if switchReminder.on {
            
            let grantedSettings: UIUserNotificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
            
            if grantedSettings.types == UIUserNotificationType.None {
                
                let alert = UIAlertController(title: "Enable Notifications", message: "Sorry, we can't activate reminders. Go to your iPhone Settings and allow Taptimal to send notifications.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                switchReminder.on = false
            }
            else {
                
                // Remove all existing notifications
                
                UIApplication.sharedApplication().cancelAllLocalNotifications()
                
                NSUserDefaults.standardUserDefaults().setObject("false", forKey: "isReminderSet")
                
                // Calculate new notification date, starting tomorrow

                let dateToday =  NSDate()
                let dateTomorrow = dateToday.dateByAddingTimeInterval(24 * 60 * 60)
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateNotification = dateFormatter.stringFromDate(dateTomorrow) + " " + labelReminderTime.text!
                
                // Setup new notification
                
                var notify: UILocalNotification = UILocalNotification()
                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
                notify.fireDate = dateFormatter.dateFromString(dateNotification)
                notify.timeZone = NSTimeZone.defaultTimeZone()
                notify.alertBody = "It's time for your tapping test."
                notify.alertAction = "Go for it"
                notify.soundName = UILocalNotificationDefaultSoundName
                //notify.applicationIconBadgeNumber = 1
                notify.repeatInterval = NSCalendarUnit.DayCalendarUnit
                
                // Lock in new notification
                UIApplication.sharedApplication().scheduleLocalNotification(notify)
                NSUserDefaults.standardUserDefaults().setObject("true", forKey: "isReminderSet")
                println("Notification set for: \(dateFormatter.dateFromString(dateNotification))")
            }
        }
        else {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            NSUserDefaults.standardUserDefaults().setObject("false", forKey: "isReminderSet")
            println("Nofication Deactivated")
        }
    }
    
    func syncWithParse() {
        
        /*
        Sync local results with Parse
        Step 1. Upload new local measurements (where syncStatusParse = 0) to Parse
        Step 2. Remove deleted local measurements (where syncStatusParse = 3) from Parse
        Step 3. If a local measurement has been updated/edited (where syncStatusParse = 2) then update the matching Parse record
        */
        
        dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
        let lastSyncDate = dateFormatter.stringFromDate(NSDate())
        
        NSUserDefaults.standardUserDefaults().setObject(lastSyncDate, forKey: "lastSyncDate")
        
        // Initiate core data
        
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        // STEP 1. Get unsynced measurements (where syncStatusParse = 0) and upload to Parse
        
        var request = NSFetchRequest(entityName: "Results")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.predicate = NSPredicate(format: "syncStatusParse = %@", "0")!
        var fetchError : NSError?
        var updateError: NSError?
        
        if let results = context.executeFetchRequest(request, error: &fetchError) {
            
            if results.count > 0 {
                
                for result in results {

                    var post = PFObject(className: "Results")
                    
                    post["user"] = PFUser.currentUser()
                    post["date"] = result.valueForKey("date")
                    post["hand"] = result.valueForKey("hand")
                    post["tapCount"] = result.valueForKey("tapCount")
                    
                    if let note = result.valueForKey("note") as? String {
                        post["note"] = note
                    }
                    
                    if let lat = result.valueForKey("lat") as? Double {
                        post["lat"] = lat
                    }
                    
                    if let lng = result.valueForKey("lng") as? Double {
                        post["lng"] = lng
                    }
                    
                    post.saveInBackgroundWithBlock {
                        (success: Bool, postError:NSError!) -> Void in
                        if success {
                            result.setValue(post.objectId, forKey: "objectId")
                            result.setValue(1, forKey: "syncStatusParse")
                            
                            context.save(&updateError)
                            
                            if updateError == nil {
                                println("Success: synced a core data sync record up to Parse")
                            }
                            else {
                                self.showAlert("Error:", msg: "There was a problem updating core data.")
                            }
                        }
                        else {
                            if let errorString = postError.userInfo?["error"] as? NSString {
                                self.showAlert("Error:", msg: errorString)
                            }
                        }
                    }
                }
                // Calculate and update life average results
                
                let lifeAverageResults = Calculations().lifeAverage()
                
                if lifeAverageResults.count > 1 {
                    self.updateLifeAverage(lifeAverageResults)
                }
            }
        }
        else {
            println("Add record fetch failed: \(fetchError)")
        }
        
        // STEP 2. Update measurements on Parse which haved been updated locally
        
        request.predicate = NSPredicate(format: "syncStatusParse = %@", "2")!
        
        if let results = context.executeFetchRequest(request, error: &fetchError) {
            
            if results.count > 0 {
                
                println("\(results.count) updated records found")
                
                for result in results {
                    var query = PFQuery(className: "Results")

                    let objectId = result.valueForKey("objectId") as NSString

                    query.getObjectInBackgroundWithId(objectId){
                        (record: PFObject!, queryError:NSError!) -> Void in
                        
                        if query.countObjects() > 0 {
                            
                            if queryError == nil {
                                
                                record["note"] = result.valueForKey("note")
                                
                                record.saveInBackgroundWithBlock {
                                    (success: Bool, saveError: NSError!) -> Void in
                                    
                                    if success {
                                        result.setValue(1, forKey: "syncStatusParse")
                                        
                                        context.save(&updateError)
                                        
                                        if updateError == nil {
                                            println("Success: updated a core data record on Parse")
                                        }
                                        else {
                                            self.showAlert("Error:", msg: "There was a problem updating core data.")
                                        }
                                    }
                                    else {
                                        if let errorString = saveError.userInfo?["error"] as? NSString {
                                            self.showAlert("Error:", msg: errorString)
                                        }
                                    }
                                }
                            }
                            
                        } else {
                            
                            // That's odd. No matching records found on Parse to update. Let's reset local record to sync (syncStatus = 0)
                            
                            println("No matching record on Parse. Resetting...")
                            
                            result.setValue(0, forKey: "syncStatusParse")
                            
                            context.save(&updateError)
                            
                            if updateError == nil {
                                println("Success: updated a core data record on Parse")
                            }
                            else {
                                self.showAlert("Error:", msg: "There was a problem updating core data.")
                            }
                        }
                    }
                }
            }
        }

        // STEP 3. Remove deleted measurements from Parse
        
        request.predicate = NSPredicate(format: "syncStatusParse = %@", "3")!
        
        if let results = context.executeFetchRequest(request, error: &fetchError) {
            
            if results.count > 0 {
                
                println("\(results.count) deleted records found")
                
                for result in results {
                    var query = PFQuery(className: "Results")
                    
                    if let objectId = result.valueForKey("objectId") as? NSString {
                        
                        query.getObjectInBackgroundWithId(objectId){
                            (record: PFObject!, queryError:NSError!) -> Void in
                            
                            if queryError == nil {
                                record.deleteInBackgroundWithBlock{
                                    (success: Bool, deleteError: NSError!) -> Void in
                                    
                                    if !success {
                                        if let errorString = deleteError.userInfo?["error"] as? NSString {
                                            self.showAlert("Error:", msg: errorString)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // Delete from core data
                    context.deleteObject(result as NSManagedObject)
                    
                    if !context.save(&updateError) {
                        self.showAlert("Error:", msg: "There was a problem updating core data.")
                    }
                    else {
                        println("Local record deleted.")
                    }
                }
            }
        }
    }
    
    func updateLifeAverage(lifeAverageData: [NSInteger]) {
        
        var query = PFQuery(className:"_User")
        let userId = PFUser.currentUser().objectId
        
        query.getObjectInBackgroundWithId(userId) {
            (user: PFObject!, error: NSError!) -> Void in
            
            if error == nil {
                user["lifeAverage"] = lifeAverageData[2]
                user["lifeAverageLR"] = "\(lifeAverageData[0])#\(lifeAverageData[1])"
                user["dateLifeAverage"] = NSDate()

                user.saveInBackgroundWithBlock {
                    (success: Bool, saveError: NSError!) -> Void in
                    
                    if success {
                        NSLog("Life average saved")
                    }
                    else {
                        NSLog("Cannot save life average data: %@", saveError)
                    }
                }
            }
            else {
                NSLog("Cannot get user data: %@", error)
            }
        }
    }
    
    func importCSVFile() {

        var insertError: NSError?
        var fetchError: NSError?
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"

        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!

        let bundle = NSBundle.mainBundle()
        let myFilePath = bundle.pathForResource("taptimal-results", ofType: "csv")
        if let fileContent = String(contentsOfFile: myFilePath!, encoding: NSUTF8StringEncoding, error: nil) {
            var rows = fileContent.componentsSeparatedByString("\n")
            
            for row in rows {
                let items = row.componentsSeparatedByString(",")
                if items.count > 4 {
                    var note: NSString?
                    let date = dateFormatter.dateFromString(items[0])!
                    let hand = items[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    let tapCount = (items[2] as NSString).integerValue
                    let lat = (items[3] as NSString).doubleValue
                    let lng = (items[4] as NSString).doubleValue
                    if items.count > 5 {
                        note = items[5]
                    }
                    
                    var request = NSFetchRequest(entityName: "Results")
                    request.predicate = NSPredicate(format: "date = %@ AND hand = %@", date, hand) // Check if record already exists
                    
                    if let results = context.executeFetchRequest(request, error: &fetchError){
                        
                        if results.count == 0 {
                            var record = NSEntityDescription.insertNewObjectForEntityForName("Results", inManagedObjectContext: context) as NSManagedObject
                            record.setValue(date, forKey: "date")
                            record.setValue(tapCount, forKey: "tapCount")
                            record.setValue(hand, forKey: "hand")
                            record.setValue(0, forKey: "syncStatusParse")
                            record.setValue(0, forKey: "syncStatusQuantid")
                            record.setValue(lat, forKey: "lat")
                            record.setValue(lng, forKey: "lng")
                            if let nt = note {
                                record.setValue(nt, forKey: "note")
                            }
                            
                            println("\(date),\(hand),\(tapCount),\(lat),\(lng),\(note)")

                            if context.save(&insertError) {
                                println("saved...")
                            }
                            else {
                                println("Could not save \(insertError), \(insertError?.userInfo)")
                            }
                        }
                        else {
                            println("Record already exists.")
                        }
                    }
                }
            }
        }
    }
    
    func actionCloudRestore() {
        
        if Reachability.isConnectedToNetwork() {
            let alertWarning = UIAlertController(
                title: "Warning",
                message: "This will delete your local Taptimal data and restore your data from the cloud. Are you sure you want to continue?",
                preferredStyle: UIAlertControllerStyle.Alert
            )
            alertWarning.addAction(UIAlertAction(title: "Canel", style: UIAlertActionStyle.Default, handler: nil))
            alertWarning.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                action in
                
                self.launchActivityIndicator()
                
                // Check if there are any unsynced core data records
                if self.unsyncedRecords() {
                    self.stopActivityIndicator()
                    self.showAlert("Restore Failed", msg: "Data found which hasn't yet been backed-up to the cloud. Try again later.")
                }
                else {
                    // WARNING! - Delete all records
                    let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                    let context:NSManagedObjectContext = appDel.managedObjectContext!
                    var request = NSFetchRequest(entityName: "Results")
                    
                    var fetchError : NSError?
                    if let results = context.executeFetchRequest(request, error: &fetchError){
                        if fetchError == nil {
                            for result in results {
                                context.deleteObject(result as NSManagedObject)
                            }
                            println("Deleted: \(results.count) records")
                            
                            var saveError : NSError?
                            context.save(&saveError)
                            
                            if saveError != nil {
                                println("Error encountered deleting records: \(saveError?.userInfo)")
                                return
                            }
                        }
                    }
                    self.restoreFromParse()
                }
            }))
            self.presentViewController(alertWarning, animated: true, completion: nil)
        }
        else {
            showAlert("No Internet", msg: "Your phone seems to have lost its data connection. Try again later.")
        }
    }
    
    func unsyncedRecords() -> Bool {
        
        var fetchError : NSError?
        var response: Bool = true
        
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Results")
        request.predicate = NSPredicate(format: "syncStatusParse = 0")
        
        if let results = context.executeFetchRequest(request, error: &fetchError) {
            if results.count == 0 {
                response = false
            }
        }
        return response
    }
    
    func restoreFromParse() {

        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var query = PFQuery(className: "Results")
        query.whereKey("user", equalTo: PFUser.currentUser())
        query.findObjectsInBackgroundWithBlock {
            (results: [AnyObject]!, error: NSError!) -> Void in
            
            if error == nil {
                
                var restoreCounter: NSInteger = 0
                
                for result in results {
                    
                    var note: NSString?
                    let objectId = result.valueForKey("objectId") as NSString
                    let date = result.valueForKey("date") as NSDate
                    var hand = result.valueForKey("hand") as String
                    let tapCount = result.valueForKey("tapCount") as NSInteger
                    let lat = result.valueForKey("lat") as Double
                    let lng = result.valueForKey("lng") as Double
                    if let noted = result.valueForKey("note") as? NSString {
                        note = noted
                    }
                    
                    // Clead data
                    hand = hand.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    
                    var fetchError : NSError?
                    var record = NSEntityDescription.insertNewObjectForEntityForName("Results", inManagedObjectContext: context) as NSManagedObject
                    
                    record.setValue(objectId, forKey: "objectId")
                    record.setValue(date, forKey: "date")
                    record.setValue(tapCount, forKey: "tapCount")
                    record.setValue(hand, forKey: "hand")
                    record.setValue(1, forKey: "syncStatusParse")
                    record.setValue(1, forKey: "syncStatusQuantid")
                    record.setValue(lat, forKey: "lat")
                    record.setValue(lng, forKey: "lng")
                    if let nt = note {
                        record.setValue(nt, forKey: "note")
                    }
                    
                    println("\(date),\(hand),\(tapCount),\(lat),\(lng),\(note)")
                    
                    var insertError : NSError?
                    if context.save(&insertError) {
                        println("Saved \(restoreCounter) records")
                        restoreCounter++
                    }
                    else {
                        println("Error: Could not save \(insertError), \(insertError?.userInfo)")
                    }
                }
            }
            self.stopActivityIndicator()
        }
    }
    
    func actionForceSync() {
        if Reachability.isConnectedToNetwork() {
            
            message.title = "Syncing..."
            message.message = ""
            message.delegate = self
            message.cancelButtonIndex = 0
            message.show()
            //message.addSubview(self.view)
            
            launchActivityIndicator()
            
            timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: Selector("stopActivityIndicator"), userInfo: nil, repeats: false)
            
            syncWithParse()
        }
        else {
            showAlert("No Internet", msg: "Your phone seems to have lost its data connection. Try again later.")
        }
    }
    
    func actionMenu() {
        sideBar.showSideBar(true)
    }
    
    func actionLogout() {

        PFUser.logOut()
        
        alertLogout = UIAlertController(title: "Logging out...", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(alertLogout, animated: true, completion: nil)
        
        launchActivityIndicator()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: Selector("timerLogoutCompleted"), userInfo: nil, repeats: false)
    }
    
    func actionSetReminderTime() {
        
        // Show time picker
        timePickerView.hidden = false
        buttonCancel.hidden = false
    }
    
    func actionSetSharing() {
        
        if switchSharing.on {
            updateSharing("true")
        }
        else {
            updateSharing("false")
        }
    }
    
    func updateSharing(status: NSString) {
        
        if status != "true" && status != "false" {
            return
        }
        
        var query = PFQuery(className:"_User")
        let userId = PFUser.currentUser().objectId
        
        query.getObjectInBackgroundWithId(userId) {(user: PFObject!, error: NSError!) -> Void in
            
            if error == nil {
                
                // Success. Now update user details
                
                user["isSharing"] = status.boolValue
                
                user.saveInBackgroundWithBlock {(success: Bool, saveError: NSError!) -> Void in
                    
                    if success {
                        NSUserDefaults.standardUserDefaults().setObject(status, forKey: "isSharing")
                        
                        // Refresh user data
                        
                        user.fetchInBackgroundWithBlock({
                            (userData: PFObject!, fetchError: NSError!) -> Void in
                            
                            if fetchError != nil {
                                if let errorString = fetchError.userInfo?["error"] as? NSString {
                                    self.showAlert("Error:", msg: errorString)
                                }
                            }
                        })
                    }
                }
            }
            else {
                NSLog("Cannot update user profile information: %@", error)
            }
        }
    }
    
    func actionExport() {

        var fetchError : NSError?
        var resultLine: NSString = ""
        var fileCSV: NSString = ""
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
       
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        var request = NSFetchRequest(entityName: "Results")
        
        if let results = context.executeFetchRequest(request, error: &fetchError) {
            
            if results.count > 0 {
                
                // Set up file
                let fileManager = NSFileManager.defaultManager()
                let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
                fileCSV = documentsPath.stringByAppendingPathComponent("taptimal-results.csv")
                fileManager.createFileAtPath(fileCSV, contents: nil, attributes: nil)
                let fileHandle: NSFileHandle? = NSFileHandle(forUpdatingAtPath: fileCSV)
                
                if fileHandle == nil {
                    NSLog("Failed to initate file for export")
                }
                else {
                    fileHandle?.seekToEndOfFile()
                    
                    for result in results {
                        let dateCSV = dateFormatter.stringFromDate(result.valueForKey("date") as NSDate) as NSString
                        let handCSV = result.valueForKey("hand") as NSString
                        let tapCountCSV = result.valueForKey("tapCount") as NSInteger
                        let latCSV = result.valueForKey("lat") as Double
                        let lngCSV = result.valueForKey("lng") as Double
                        
                        if let noteCSV = result.valueForKey("note") as? NSString {
                            resultLine = ("\(dateCSV),\(handCSV),\(tapCountCSV),\(noteCSV)\n")
                            //resultLine = ("\(dateCSV),\(handCSV),\(tapCountCSV),\(latCSV),\(lngCSV),\(noteCSV)\n")
                        }
                        else {
                            resultLine = ("\(dateCSV),\(handCSV),\(tapCountCSV)\n")
                            //resultLine = ("\(dateCSV),\(handCSV),\(tapCountCSV),\(latCSV),\(lngCSV)\n")
                        }
                        fileHandle?.writeData(resultLine.dataUsingEncoding(NSUTF8StringEncoding)!)
                    }
                    fileHandle?.closeFile()
                }
            }
            else {
                showAlert("No Data", msg:"Sorry, you don't have any results data to export.")
                
                return
            }
            // EMAIL
            if MFMailComposeViewController.canSendMail() {
                var messageText: NSString = ""
                let mailComposer: MFMailComposeViewController = MFMailComposeViewController()
                mailComposer.mailComposeDelegate = self
                mailComposer.setSubject("Taptimal CSV file")
                
                if let dataCSV = NSData(contentsOfFile: fileCSV) {
                    messageText = "Taptimal data in CSV format is attached, exported on: \(NSDate())."
                    mailComposer.addAttachmentData(dataCSV, mimeType: "text/csv", fileName: "taptimal-results.csv")
                }
                else {
                    messageText = "[Sorry, there was an error with your attachment]"
                }
                mailComposer.setMessageBody(messageText, isHTML: false)
                self.presentViewController(mailComposer, animated: true, completion: nil)
            }
            else {
                showAlert("Alert", msg:"Sorry, there's a problem sending emails from this device.")
            }
        }
    }
    
    func actionFeedback() {
        
        if MFMailComposeViewController.canSendMail() {
            
            let mailComposer: MFMailComposeViewController = MFMailComposeViewController()
            let messageText = "Here's what I think about Taptimal, and the features I'd like to see you add in future versions:\n\n"
            
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject("Taptimal feedback")
            mailComposer.setToRecipients(["hello@taptimal.co"])
            mailComposer.setMessageBody(messageText, isHTML: false)
            
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
        else {
            showAlert("Alert", msg:"Sorry, there's a problem sending emails from this device.")
        }
    }

    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
        
        switch result.value {
        case MFMailComposeResultCancelled.value:
            println("Mail cancelled")
        case MFMailComposeResultSaved.value:
            println("Mail saved")
        case MFMailComposeResultSent.value:
            println("Mail sent")
        case MFMailComposeResultFailed.value:
            println("Mail sent failure: %@", [error.localizedDescription])
        default:
            break
        }
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func timerLogoutCompleted() {
        stopActivityIndicator()
        alertLogout.dismissViewControllerAnimated(true, completion: {
            self.performSegueWithIdentifier("jumpToRegister", sender: nil)
        })
    }
    
    func handleTimePicker(sender: AnyObject) {
        
        dateFormatter.dateFormat = "HH:mm"
        let selectedTime = dateFormatter.stringFromDate(timePickerView.date)
        labelReminderTime.text = selectedTime
        NSUserDefaults.standardUserDefaults().setObject(selectedTime, forKey: "ReminderTime")
        
        switchReminder.on = true    // Turn on switch for reminder (if it's not already on)
        
        timePickerView.hidden = true    // Remove time picker from screen
        buttonCancel.hidden = true
        
        actionSetReminderNotification() // Set new notification time
    }
    
    func removeTimePicker() {
        println("I should not be here.")
    }
    
    
    func showAlert(title: NSString, msg: NSString) {
        if (self.isViewLoaded() && self.view.window != nil) {
            // Only show alerts if Settings ViewController is active
            var alert: UIAlertController = UIAlertController()
            alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func launchActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 75, 75))
        activityIndicator.center = CGPoint(x: self.view.center.x, y: screenSize.height / 2)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        scrollView.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()  //Lock display
    }
    
    func stopActivityIndicator() {
        message.dismissWithClickedButtonIndex(0, animated: true)
        activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()    // Unlock display
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
