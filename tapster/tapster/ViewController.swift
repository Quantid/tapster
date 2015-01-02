//
//  ViewController.swift
//  tapster
//
//  Created by Matthew Lewis on 01/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var timer = NSTimer()
    var tappingHasStarted = false
    var tapCount = 0

    var timeMilliseconds = 0
    var timeSeconds = 0
    var secondsZero = "0"
    
    @IBOutlet weak var labelTapCounter: UILabel!
    @IBOutlet weak var labelTimer: UILabel!
    @IBOutlet weak var buttonTapSurface: UIButton!

    @IBAction func actionTapSurface(sender: AnyObject) {
        
        if tappingHasStarted {
            
            tapCount++
        }
        else {
            
            tappingHasStarted = true
            tapCount++
            timeSeconds = 10
            timeMilliseconds = 0
            
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("countDown"), userInfo: nil, repeats: true)
        }
        
        labelTapCounter.text = String(tapCount)
    }
    
    func countDown(){
        
        if timeSeconds == 0 && timeMilliseconds == 0 {
            
            timer.invalidate()
            
            // generate alert to save result of test
            var alert = UIAlertController(title: "", message: "Do you want to save this test?", preferredStyle: .ActionSheet)
            
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: {action in

                if self.saveTest() {
                    
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
    
    func saveTest() -> Bool {
    
        return true
    }
    
    func resetLabels(){
        
        labelTimer.text = "00:00.0"
        labelTapCounter.text = "0"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetLabels()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

