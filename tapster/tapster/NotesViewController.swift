//
//  NotesViewController.swift
//  tapster
//
//  Created by Matthew Lewis on 08/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit
import CoreData
import Social

class NotesViewController: UIViewController, UITextViewDelegate {
    
    var dateOfNote: NSDate = NSDate()
    var isForSharing: Bool = false
    var returnSegue: String = ""
    let socialMessage: String = "I just scored #left #right on Taptimal - www.taptimal.co"
    
    var currentSyncStatusParse: NSInteger = -1
    var currentSyncStatusQuantid: NSInteger = -1

    @IBOutlet weak var imageTextArea: UIImageView!
    @IBOutlet weak var buttonAddNote: UIButton!
    @IBOutlet weak var buttonFacebook: UIButton!
    @IBOutlet weak var buttonTwitter: UIButton!
    @IBOutlet weak var labelDay: UILabel!
    @IBOutlet weak var labelMonth: UILabel!
    @IBOutlet weak var labelLeftScore: UILabel!
    @IBOutlet weak var labelRightScore: UILabel!
    @IBOutlet weak var inputNote: UITextView!
    @IBOutlet weak var labelError: UILabel!
    
    @IBAction func actionGoBack(sender: AnyObject) {
        
        self.performSegueWithIdentifier(self.returnSegue, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up
        
        self.view.backgroundColor = UIColor(red:242/255, green:244/255, blue:245/255, alpha:1.0)

        labelLeftScore.text = ""
        labelRightScore.text = ""
        labelError.text = ""
        
        var tapCount: NSInteger
        var dateDayFormatter = NSDateFormatter()
        var dateMonthFormatter = NSDateFormatter()
        
        dateDayFormatter.dateFormat = "dd"
        dateMonthFormatter.dateFormat = "MMM"
        
        labelDay.text = dateDayFormatter.stringFromDate(dateOfNote) as NSString
        labelMonth.text = dateMonthFormatter.stringFromDate(dateOfNote).uppercaseString as NSString

        // Collect tapCount from core data
        
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        let request = NSFetchRequest(entityName: "Results")
        request.predicate = NSPredicate(format: "date = %@", dateOfNote)
        request.returnsObjectsAsFaults = false
        
        var error : NSError?

        if let results = context.executeFetchRequest(request, error: &error) {
            
            if results.count > 0 {
                
                for result in results as [NSManagedObject] {
                    
                    currentSyncStatusParse = result.valueForKey("syncStatusParse") as NSInteger
                    currentSyncStatusQuantid = result.valueForKey("syncStatusQuantid") as NSInteger
                    
                    tapCount = result.valueForKey("tapCount") as NSInteger

                    if result.valueForKey("hand") as NSString == "left" {
                        labelLeftScore.text = "L\(tapCount)"
                        if results.count == 1 {labelRightScore.text = "R--"}
                    }
                    else {
                        labelRightScore.text = "R\(tapCount)"
                        if results.count == 1 {labelLeftScore.text = "L--"}
                    }
                    
                    if let note = result.valueForKey("note") as? NSString {
                        inputNote.text = note
                    }
                    else {
                        inputNote.text = "Enter a note..."
                    }
                }
            }
            else {
                
                // This is odd. Perform segue back to main screen.
            }
        }
        else {
            println("Fetch failed: \(error)")
        }
        
        // Sharing or Note
        
        if isForSharing {
            inputNote.hidden = true
            imageTextArea.hidden = true
            buttonAddNote.hidden = true
        }
        else {
            buttonFacebook.hidden = true
            buttonTwitter.hidden = true
            inputNote.delegate = self
        }
    }

    @IBAction func actionProcessNote(sender: AnyObject) {
        
        let noteText = inputNote.text
        var error = ""
        
        // Validate note
        
        if noteText.utf16Count > 255 {
            error = "Your note is too long (Max. 255 chars)"
        }
        
        if error == "" {
            
            // Check whether record has already been synced. If not, keep sync status as 0 instead of changing to 2
            
            var updatedSyncStatusParse = 2
            var updatedSyncStatusQuantid = 2
            
            if currentSyncStatusParse == 0 {
                updatedSyncStatusParse = 0
            }
            
            if currentSyncStatusQuantid == 0 {
                updatedSyncStatusQuantid = 0
            }
            
            // Initiate core data
            
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext!
            
            var request = NSFetchRequest(entityName: "Results")
            let filterPredicate: NSPredicate = NSPredicate(format: "date = %@", dateOfNote)!
            request.predicate = filterPredicate
            
            var errorResults : NSError?
            
            if let results = context.executeFetchRequest(request, error: &errorResults) {
                
                for result in results {
                    
                    result.setValue(noteText as String, forKey: "note")
                    result.setValue(updatedSyncStatusParse, forKey: "syncStatusParse")
                    result.setValue(updatedSyncStatusQuantid, forKey: "syncStatusQuantid")
                }
                
                context.save(nil)
                
                notifyThenReturn("Saved")
            }
            else {
                println("Fetch failed: \(errorResults)")
            }
        }
        else {
            labelError.text = error
        }
    }
    
    
    @IBAction func actionTwitter(sender: AnyObject) {

        var message = socialMessage
        message = message.stringByReplacingOccurrencesOfString("#left", withString: labelLeftScore.text!, options: NSStringCompareOptions.LiteralSearch, range: nil)
        message = message.stringByReplacingOccurrencesOfString("#right", withString: labelRightScore.text!, options: NSStringCompareOptions.LiteralSearch, range: nil)

        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            var controller = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            controller.setInitialText(message)
            self.presentViewController(controller, animated:true, completion: {
                self.notifyThenReturn("Posted")
            })
        }
        else {
            var alert = UIAlertController(title: "Accounts", message: "Please log into your Twitter app", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func actionFacebook(sender: AnyObject) {
        
        var message = socialMessage
        message = message.stringByReplacingOccurrencesOfString("#left", withString: labelLeftScore.text!, options: NSStringCompareOptions.LiteralSearch, range: nil)
        message = message.stringByReplacingOccurrencesOfString("#right", withString: labelRightScore.text!, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            var controller = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            controller.setInitialText(message)
            self.presentViewController(controller, animated:true, completion: {
                self.notifyThenReturn("Posted")
            })
        }
        else {
            var alert = UIAlertController(title: "Accounts", message: "Please log into your Facebook app", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func notifyThenReturn(message: String) {
        
        var alert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        
        alert.dismissViewControllerAnimated(true, completion: {
            self.performSegueWithIdentifier(self.returnSegue, sender: nil)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Clear the textview when user start editing
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        if textView.text == "Enter a note..." {
            textView.text = ""
        }
        labelError.text = ""
        
        return true
    }
    
    // Get rid of keyboard when finished entering text
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    // Get rid of keyboard if user touches anywhere on the screen
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        self.view.endEditing(true)
    }
}
