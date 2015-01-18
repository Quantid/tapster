//
//  NotesViewController.swift
//  tapster
//
//  Created by Matthew Lewis on 08/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController, UITextViewDelegate {
    
    var dateOfNote: NSDate = NSDate()
    var returnSegue: String = ""
    
    var currentSyncStatusParse: NSInteger = -1
    var currentSyncStatusQuantid: NSInteger = -1

    @IBOutlet weak var labelDay: UILabel!
    @IBOutlet weak var labelMonth: UILabel!
    @IBOutlet weak var labelLeftScore: UILabel!
    @IBOutlet weak var labelRightScore: UILabel!
    @IBOutlet weak var inputNote: UITextView!
    
    @IBAction func actionGoBack(sender: AnyObject) {
        
        self.performSegueWithIdentifier(self.returnSegue, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up
        
        self.view.backgroundColor = UIColor(red:242/255, green:244/255, blue:245/255, alpha:1.0)
        inputNote.text = ""
        labelLeftScore.text = ""
        labelRightScore.text = ""
        
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
                        
                        labelLeftScore.text = "L:\(tapCount)"
                        
                        if results.count == 1 {labelRightScore.text = "R:--"}
                    } else {
                        
                        labelRightScore.text = "R:\(tapCount)"
                        if results.count == 1 {labelLeftScore.text = "L:--"}
                    }
                    
                    if let note = result.valueForKey("note") as? NSString {
                        
                        inputNote.text = note
                    } else {
                        
                        inputNote.text = ""
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
        
        inputNote.delegate = self
        
        // Do any additional setup after loading the view.
    }

    @IBAction func actionProcessNote(sender: AnyObject) {
        
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

        var error : NSError?
        
        if let results = context.executeFetchRequest(request, error: &error) {
            
            for result in results {
                
                result.setValue(inputNote.text as String, forKey: "note")
                result.setValue(updatedSyncStatusParse, forKey: "syncStatusParse")
                result.setValue(updatedSyncStatusQuantid, forKey: "syncStatusQuantid")
            }
            
            context.save(nil)
            
            notifyThenReturn()
        }
        else {
            
            println("Fetch failed: \(error)")
        }
        
    }
    
    func notifyThenReturn() {
        
        var alert = UIAlertController(title: "Saved!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        
        alert.dismissViewControllerAnimated(true, completion: {
        
            self.performSegueWithIdentifier(self.returnSegue, sender: nil)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
