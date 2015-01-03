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
    
    @IBOutlet weak var buttonRightSelector: UIButton!
    @IBOutlet weak var buttonLeftSelector: UIButton!
    @IBOutlet weak var labelTapToStart: UILabel!
    @IBOutlet weak var labelTapCounter: UILabel!
    @IBOutlet weak var labelTimer: UILabel!
    @IBOutlet weak var buttonTapSurface: UIButton!

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
        
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        var results = context.executeFetchRequest(request, error: nil)
        
        if results?.count > 0 {
            
            for result: AnyObject in results! {
                
                handMostRecent = result.valueForKey("hand") as String!
                dateMostRecent = result.valueForKey("date") as NSDate
                
                break
            }
            
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Reset labels, buttons and background
        
        resetLabels()
        actionSwitchRight(0)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        
        tapCount = 45
        handSetting = "left"
        saveResult()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

