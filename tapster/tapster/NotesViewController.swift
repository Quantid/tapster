//
//  NotesViewController.swift
//  tapster
//
//  Created by Matthew Lewis on 08/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {
    
    var dateOfNote: NSDate = NSDate()

    @IBOutlet weak var labelDay: UILabel!
    @IBOutlet weak var labelMonth: UILabel!
    @IBOutlet weak var labelLeftScore: UILabel!
    @IBOutlet weak var labelRightScore: UILabel!
    @IBOutlet weak var inputNote: UITextView!
    @IBAction func actionProcessNote(sender: AnyObject) {
        
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
                    
                    tapCount = result.valueForKey("tapCount") as NSInteger

                    if result.valueForKey("hand") as NSString == "left" {
                        
                        labelLeftScore.text = "L:\(tapCount)"
                        
                        if results.count == 1 {labelRightScore.text = "R:--"}
                    } else {
                        
                        labelRightScore.text = "R:\(tapCount)"
                        if results.count == 1 {labelLeftScore.text = "L:--"}
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
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}