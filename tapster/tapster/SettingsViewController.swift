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

class SettingsViewController: UIViewController, SideBarDelegate, MFMailComposeViewControllerDelegate {
    
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
    var alert: UIAlertController = UIAlertController()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var imageLabelBackgrounds: [UIImageView] = []
    var labelTitles: [UILabel] = []
    var labelSubs: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Menu selector button
        
        let buttonMenuSelector: UIButton = UIButton(frame: CGRectMake(20, 24, 19, 17))
        buttonMenuSelector.setImage(UIImage(named: "icon-menu-selector.png"), forState: UIControlState.Normal)
        buttonMenuSelector.addTarget(self, action: "actionMenu", forControlEvents: UIControlEvents.TouchUpOutside)
        buttonMenuSelector.addTarget(self, action: "actionMenu", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(buttonMenuSelector)
        
        scrollView.frame = self.view.bounds
        scrollView.contentSize = CGSize(width: screenSize.width, height: 750)
        scrollView.center = CGPoint(x: screenSize.width/2, y: screenSize.height/2 + 60)
        scrollView.backgroundColor = UIColor(red: 242/255, green: 244/255, blue: 245/255, alpha: 1.0)
        scrollView.scrollEnabled = true
        view.addSubview(scrollView)
        
        var labelBackgroundPositionY = [30, 5, 30, 30, 5, 30, 30]
        var labelTitleText = ["Morning Reminder", "Reminder Time", "Sharing", "Sync Status", "Force Sync", "Export Data", "Log Out of Taptimal"]
        var labelSubText = [
            "Receive a reminder every morning to do test",
            "Set the time you want to receive the alert",
            "Allow others to see your life average score",
            "Last sync conducted at:",
            "Manually force synchronisation process",
            "Export your results as a CSV file",
            ""
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
        if let reminderStatus = NSUserDefaults.standardUserDefaults().objectForKey("isSharingSet") as? NSString {
            if reminderStatus == "true" {
                
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
        
        let buttonSync: UIButton = UIButton(frame: CGRectMake(0, 0, 50, 30))
        buttonSync.center = CGPoint(x: screenSize.width - 32, y: imageLabelBackgrounds[4].center.y)
        buttonSync.setImage(UIImage(named: "button-sync.png"), forState: UIControlState.Normal)
        buttonSync.addTarget(self, action: "actionSync", forControlEvents: UIControlEvents.TouchUpInside)
        
        // Set up EXPORT button
        
        let buttonExport: UIButton = UIButton(frame: CGRectMake(0, 0, 50, 30))
        buttonExport.center = CGPoint(x: screenSize.width - 32, y: imageLabelBackgrounds[5].center.y)
        buttonExport.setImage(UIImage(named: "button-export.png"), forState: UIControlState.Normal)
        buttonExport.addTarget(self, action: "actionExport", forControlEvents: UIControlEvents.TouchUpInside)
        
        // Set up LOGOUT button
        
        let buttonLogout: UIButton = UIButton(frame: CGRectMake(0, 0, screenSize.width, 45))
        buttonLogout.setImage(UIImage(named: "icon-disclosure.png"), forState: UIControlState.Normal)
        buttonLogout.imageEdgeInsets = UIEdgeInsetsMake(0, buttonLogout.frame.width-15, 0, 0)
        buttonLogout.center = CGPoint(x: imageLabelBackgrounds[6].center.x, y: imageLabelBackgrounds[6].center.y)
        buttonLogout.addTarget(self, action: "actionLogout", forControlEvents: UIControlEvents.TouchUpInside)
        
        scrollView.addSubview(switchReminder)
        scrollView.addSubview(labelReminderTime)
        scrollView.addSubview(labelLastSyncDate)
        scrollView.addSubview(switchSharing)
        scrollView.addSubview(buttonSync)
        scrollView.addSubview(buttonExport)
        scrollView.addSubview(buttonSetTime)
        scrollView.addSubview(buttonLogout)
        
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
                
                alert = UIAlertController(title: "Enable Notifications", message: "Sorry, we can't activate reminders. Go to your iPhone Settings and allow Taptimal to send notifications.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                switchReminder.on = false
            }
            else {
                
                let dateToday =  NSDate()
                let dateTomorrow = dateToday.dateByAddingTimeInterval(24 * 60 * 60)
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateNotification = dateFormatter.stringFromDate(dateTomorrow) + " " + labelReminderTime.text!
                
                var notify: UILocalNotification = UILocalNotification()
                notify.fireDate = dateFormatter.dateFromString(dateNotification)
                notify.timeZone = NSTimeZone.defaultTimeZone()
                notify.alertBody = "It's time for your tapping test."
                notify.alertAction = "Go for it"
                notify.soundName = UILocalNotificationDefaultSoundName
                //notify.applicationIconBadgeNumber = 1
                notify.repeatInterval = NSCalendarUnit.DayCalendarUnit
                
                UIApplication.sharedApplication().scheduleLocalNotification(notify)
                
                NSUserDefaults.standardUserDefaults().setObject("true", forKey: "isReminderSet")
            }
        }
        else {
            
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            
            NSUserDefaults.standardUserDefaults().setObject("false", forKey: "isReminderSet")
            
            println("Nofication Deactivated")
        }
    }
    
    func actionExport() {
        
        // Export to CSV file and launch email
        
        var dateCSV: NSString = ""
        var handCSV: NSString = ""
        var tapCountCSV: NSInteger = 0
        var noteCSV: NSString = ""
        var resultLine: NSString = ""
        var fileCSV: NSString = ""
        var messageText: NSString = ""
        
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm" // Set csv date format
        
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
                fileCSV = documentsPath.stringByAppendingPathComponent("taptimal-results.csv")
                
                //if !fileManager.fileExistsAtPath(documentsPath) {
                    
                    fileManager.createFileAtPath(fileCSV, contents: nil, attributes: nil)
                //}
                
                let fileHandle: NSFileHandle? = NSFileHandle(forUpdatingAtPath: fileCSV)
                
                if fileHandle == nil {
                    
                    println("Failed to initate file")
                }
                else {
                    
                    fileHandle?.seekToEndOfFile()
                    
                    for result in results {
                        
                        dateCSV = dateFormatter.stringFromDate(result.valueForKey("date") as NSDate) as NSString
                        handCSV = result.valueForKey("hand") as NSString
                        tapCountCSV = result.valueForKey("tapCount") as NSInteger
                        
                        if let noteCSV = result.valueForKey("note") as? NSString {
                            
                            resultLine = ("\(dateCSV), \(handCSV), \(tapCountCSV), \(noteCSV) \n")
                        }
                        else {
                            
                            resultLine = ("\(dateCSV), \(handCSV), \(tapCountCSV), \n")
                        }
                        
                        fileHandle?.writeData(resultLine.dataUsingEncoding(NSUTF8StringEncoding)!)
                    }
                    
                    fileHandle?.closeFile()
                }
            }
            else {
                
                // There are no results to export
            }
            
            // EMAIL
            
            if MFMailComposeViewController.canSendMail() {
                
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
                
                alert = UIAlertController(title: "Alert", message: "Your device cannot send emails", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
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

    func actionMenu() {
        
        sideBar.showSideBar(true)
    }
    
    func actionLogout() {
        
        // Log out user
        
        PFUser.logOut()
        
        startLogoutAlert()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: Selector("timerCompleted"), userInfo: nil, repeats: false)
    }
    
    func timerCompleted() {
        
        stopLogoutAlert()
    }

    func actionSetReminderTime() {
        
        // Show time picker
        timePickerView.hidden = false
        buttonCancel.hidden = false
    }
    
    func handleTimePicker(sender: UIDatePicker) {
        
        dateFormatter.dateFormat = "HH:mm"
        let selectedTime = dateFormatter.stringFromDate(sender.date)
        labelReminderTime.text = selectedTime
        NSUserDefaults.standardUserDefaults().setObject(selectedTime, forKey: "ReminderTime")
        
        // Turn on switch for reminder
        
        switchReminder.on = true
        
        actionSetReminderNotification()
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
        
        scrollView.addSubview(activityIndicator)
        
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

    func sideBarDidSelectButtonAtIndex(index: Int) {
        
        switch index {
            
        case 0:
            
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
            
        case 1:
            
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PerformanceView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
            
        case 2:
            
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
            
        case 3:
            
            let vc:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SettingsView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
            
        default:
            println("default")
        }
    }
}
