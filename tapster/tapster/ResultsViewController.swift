//
//  ResultsTableViewController.swift
//  tapster
//
//  Created by Matthew Lewis on 02/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit
import CoreData

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SideBarDelegate  {
    
    var sideBar:SideBar = SideBar()
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds

    let imageBackground = UIImageView()
    let labelTitle = UILabel()
    let labelLeftAverage = UILabel()
    let labelRightAverage = UILabel()
    let imageUserPhoto = UIImageView()

    
    @IBOutlet weak var tableView: UITableView!
    
    var rightScore = [NSInteger]()
    var leftScore = [NSInteger]()
    var monthString = [NSString]()
    var dayString = [NSString]()
    var dateResult = [NSDate]()
    var hideNoteIcon = [Bool]()
    var hideSyncIcon = [Bool]()

    var ac = 0
    
    @IBAction func actionMenu(sender: AnyObject) {
        
            sideBar.showSideBar(true)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Establish side bar menu
        
        sideBar = SideBar(sourceView: self.view)
        sideBar.delegate = self
        
        self.tableView.dataSource = self
        self.tableView.delegate = self

        var dateMonthFormatter = NSDateFormatter()
        var dateDayFormatter = NSDateFormatter()
        
        dateMonthFormatter.dateFormat = "MMM"
        dateDayFormatter.dateFormat = "dd"
        
        setupPerformanceView()  // Setup performace view at the top of table
        
        setupChartingButtons()  // Setup charting buttons at bottom of screen
        
        // Get week's date for calculating life average
        let dateToday =  NSDate()
        let dateLastWeek = dateToday.dateByAddingTimeInterval(-7 * 24 * 60 * 60)
        
        // Reset life average variables
        var leftCounter: NSInteger = 0
        var rightCounter: NSInteger = 0
        var leftTotal: NSInteger = 0
        var rightTotal: NSInteger = 0 as NSInteger
        var daysInSeconds: Double = 60 * 60 * 24
        let averagingPeriod: Double = 7
        
        var averageOfPairedResults = [NSInteger]() // An array of the averages of all paird results
        var average: NSInteger = 0
        
        // Initialise core data
        
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Results")
     
        request.propertiesToFetch = NSArray(object: "date")
        request.returnsObjectsAsFaults = false
        request.returnsDistinctResults = true
        request.resultType = NSFetchRequestResultType.DictionaryResultType
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        let statusPredicate = NSPredicate(format: "syncStatusParse < 3")
        request.predicate = statusPredicate

        var dates:NSArray = context.executeFetchRequest(request, error: nil)!
        
        for date in dates {
            
            var dateQuery = date["date"] as NSDate
            
            var request = NSFetchRequest(entityName: "Results")
            
            request.returnsObjectsAsFaults = false

            let datePredicate = NSPredicate(format: "date == %@", dateQuery)
            request.predicate = datePredicate

            var results = context.executeFetchRequest(request, error: nil)!

            var interval = dateQuery.timeIntervalSinceDate(dateLastWeek) / daysInSeconds
            
            if results[0].valueForKey("hand")! as NSString == "right" {
                
                var tc = results[0].valueForKey("tapCount") as NSInteger
                
                rightScore.append(tc)
                average = tc
                
                if interval < averagingPeriod {
                    rightTotal = rightTotal + tc
                    rightCounter++
                }
                
                if results.count > 1 {
                    
                    var tc = results[1].valueForKey("tapCount") as NSInteger
                    
                    leftScore.append(tc)
                    average = average + tc
                    
                    if interval < averagingPeriod {
                        
                        leftTotal = leftTotal + tc
                        leftCounter++
                    }
                    
                    // Handle array of averages
                    
                    averageOfPairedResults.append(average / 2)
                }
                else {
                    
                    leftScore.append(0)
                }
            }
            else {
                
                var tc = results[0].valueForKey("tapCount") as NSInteger
                
                leftScore.append(tc)
                average = tc
                
                if interval < averagingPeriod {
                    
                    leftTotal = leftTotal + tc
                    leftCounter++
                }
                
                if results.count > 1 {
                    
                    var tc = results[1].valueForKey("tapCount") as NSInteger
                    
                    rightScore.append(tc)
                    average = average + tc
                    
                    if interval < averagingPeriod {
                        
                        rightTotal = rightTotal + tc
                        rightCounter++
                    }
                    
                    // Handle array of averages
                    
                    averageOfPairedResults.append(average / 2)
                }
                else {
                    
                    rightScore.append(0)
                }
            }
        
            dateResult.append(results[0].valueForKey("date") as NSDate)

            monthString.append(dateMonthFormatter.stringFromDate(dateQuery) as NSString)
            dayString.append(dateDayFormatter.stringFromDate(dateQuery) as NSString)
            
            // Handle displaying life average
            
            if leftCounter > 0 && rightCounter > 0 {
                
                labelLeftAverage.text = "L:\(Int(leftTotal / leftCounter))"
                labelRightAverage.text = "R:\(Int(rightTotal / rightCounter))"
            }
            else {
                
                labelLeftAverage.frame = CGRectMake(72, imageBackground.frame.origin.y + 17, 60, 200)
                labelLeftAverage.font = UIFont(name: "HelveticaNeue-Light", size: 18)
                labelLeftAverage.text = "Not enough activity..."
                labelRightAverage.hidden = true
            }
            
            // Handle displaying note icon
            
            if let note = results[0].valueForKey("note") as? NSString {
                
                if note == "" {
                    
                    hideNoteIcon.append(true)
                } else {
                    
                    hideNoteIcon.append(false)
                }
                
            } else {
                
                hideNoteIcon.append(true)
            }
            
            // Handle displaying sync icon
            
            if let sync = results[0].valueForKey("syncStatusParse") as? NSInteger {
                
                if sync > 0 {
                    
                    hideSyncIcon.append(true)
                } else {
                    
                    hideSyncIcon.append(false)
                }
                
            } else {
                
                hideSyncIcon.append(true)
            }

            ac = rightScore.count
            
            var dateString = dayString[ac-1] + monthString[ac-1]
            
            println("\(ac):")
          
            println("\(dateString) = [R]\(rightScore[ac-1]) [L]\(leftScore[ac-1])")
        }
        
        println(averageOfPairedResults)
        
        calculatePerformanceThresholds(averageOfPairedResults)
    }
    
    func calculatePerformanceThresholds(arrayOfAverages: [NSInteger]) {
        
        println(arrayOfAverages)
        
        if arrayOfAverages.count > 4 {
            
            // Sorrt array
            
            let sortedArrayOfAverages = arrayOfAverages.sorted(>)
            
            println(sortedArrayOfAverages)
            
            var topTotal: NSInteger = 0
            var bottomTotal: NSInteger = 0
            var topAverage: NSInteger = 0
            var bottomAverage: NSInteger = 0
            var counter = 0
            var topThresholdPercent = 0.1
            var bottomThresholdPercent = 0.9
            
            // Adjust threshold levels if there are an insufficient amount of results
            
            if sortedArrayOfAverages.count < 100 {
                
                topThresholdPercent = 0.2
                bottomThresholdPercent = 0.8
            }
            
            var topPercent = round(Double(sortedArrayOfAverages.count) * topThresholdPercent)
            var bottomPercent = round(Double(sortedArrayOfAverages.count) * bottomThresholdPercent)

            for var i = 0; i < Int(topPercent); i++ {

                topTotal = topTotal + sortedArrayOfAverages[i]
                
                counter++
            }
            
            let strongThreshold = topTotal / counter
            
            counter = 0
            
            for var i = Int(bottomPercent); i < sortedArrayOfAverages.count; i++ {
                println("here...")
                
                bottomTotal = bottomTotal + sortedArrayOfAverages[i]
                
                counter++
            }
            
            let weakThreshold = bottomTotal / counter
            
            NSUserDefaults.standardUserDefaults().setObject(strongThreshold, forKey: "strongThreshold")
            NSUserDefaults.standardUserDefaults().setObject(weakThreshold, forKey: "weakThreshold")
            println("Strong threshold = \(strongThreshold) AND weak threshold = \(weakThreshold)")
        }
        else {
            
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "strongThreshold")
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "weakThreshold")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        return rightScore.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: cellResult = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as cellResult
        
        var leftScoreString = String(leftScore[indexPath.row])
        var rightScoreString = String(rightScore[indexPath.row])
        
        if leftScore[indexPath.row] == 0 {
            
            leftScoreString = "--"
        }

        if rightScore[indexPath.row] == 0 {
            
            rightScoreString = "--"
        }
        
        cell.labelDay.text = dayString[indexPath.row]
        cell.labelMonth.text = monthString[indexPath.row].uppercaseString
        cell.labelLeftScore.text = "L:" + leftScoreString
        cell.labelRightScore.text = "R:" + rightScoreString
        cell.imageNote.hidden = hideNoteIcon[indexPath.row]
        //cell.imageSync.hidden = hideSyncIcon[indexPath.row]
        cell.imageSync.hidden = true
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("jumpToNotes", sender: self)
    }

    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            // DELETE RECORD. Update record with sync status = 3
            
            // Initiate core data
            
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext!
            
            var request = NSFetchRequest(entityName: "Results")
            let filterPredicate: NSPredicate = NSPredicate(format: "date = %@", dateResult[indexPath.row])!
            request.predicate = filterPredicate
            
            var error : NSError?
            var updateError : NSError?
            
            if let results = context.executeFetchRequest(request, error: &error) {
                
                for result in results {
                    
                    result.setValue(3, forKey: "syncStatusParse")
                    result.setValue(3, forKey: "syncStatusQuantid")
                }
                
                context.save(&updateError)
                
                if updateError == nil {
                    
                    // Success
                }
                else {
                    
                    println("Failed to register deleted record. Error: \(updateError)")
                }
            }
            else {
                
                println("Fetch failed: \(error)")
            }
            
            // Remove from array and refresh table
            
            dateResult.removeAtIndex(indexPath.row)
            leftScore.removeAtIndex(indexPath.row)
            rightScore.removeAtIndex(indexPath.row)
            monthString.removeAtIndex(indexPath.row)
            dayString.removeAtIndex(indexPath.row)
            hideNoteIcon.removeAtIndex(indexPath.row)
            hideSyncIcon.removeAtIndex(indexPath.row)
            
            tableView.reloadData()
        }
    }

    func setupPerformanceView() {
        
        // Setup background
        imageBackground.backgroundColor = UIColor(red: 78/255, green: 88/255, blue: 98/255, alpha: 0.7)
        imageBackground.frame = CGRectMake(0, 75, screenSize.width, 50)
        
        view.addSubview(imageBackground)
        
        // Setup labels
        labelTitle.frame = CGRectMake(72, imageBackground.frame.origin.y + 3, 90, 12)
        labelTitle.backgroundColor = UIColor.clearColor()
        labelTitle.textColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
        labelTitle.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        labelTitle.text = "LIFE AVERAGE"
        
        view.addSubview(labelTitle)
        
        labelLeftAverage.frame = CGRectMake(72, imageBackground.frame.origin.y + 17, 60, 28)
        labelLeftAverage.backgroundColor = UIColor.clearColor()
        labelLeftAverage.textColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
        labelLeftAverage.font = UIFont(name: "HelveticaNeue-Thin", size: 23)
        
        view.addSubview(labelLeftAverage)
        
        labelRightAverage.frame = CGRectMake(screenSize.width - (screenSize.width / 3), imageBackground.frame.origin.y + 17, 60, 28)
        labelRightAverage.backgroundColor = UIColor.clearColor()
        labelRightAverage.textColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
        labelRightAverage.font = UIFont(name: "HelveticaNeue-Thin", size: 23)
        
        view.addSubview(labelRightAverage)
        
        // Setup profile photo
        let imageUserPhotoNS: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("image")
        
        if let imageData: NSData = imageUserPhotoNS as? NSData {
            
            imageUserPhoto.image = UIImage (data: imageData)
            imageUserPhoto.frame = CGRectMake(13, imageBackground.frame.origin.y + 2, 46, 46)
            imageUserPhoto.contentMode = UIViewContentMode.ScaleAspectFit
            imageUserPhoto.layer.cornerRadius = imageUserPhoto.frame.size.width/2
            imageUserPhoto.layer.borderWidth = 2
            imageUserPhoto.layer.borderColor = UIColor(red: 78/255, green: 88/255, blue: 98/255, alpha: 1.0).CGColor
            imageUserPhoto.layer.masksToBounds = true
            
            view.addSubview(imageUserPhoto)
        }
    }

    func setupChartingButtons() {
        
        // Set button background
        let imageButtonBackground: UIImageView = UIImageView()
        imageButtonBackground.backgroundColor = UIColor(red: 86/255, green: 199/255, blue: 149/255, alpha: 1.0)
        imageButtonBackground.frame = CGRectMake(0, screenSize.height - 65, screenSize.width, 65)
        view.addSubview(imageButtonBackground)
        
        // Setup the three charting buttons
        let oneThirdWidth = screenSize.width / 3
        let halfOneThirdWidth = oneThirdWidth / 2
        
        var buttonCharts = [UIButton]()
        
        for var i = 0; i < 3; i++ {
            
            var j: CGFloat = CGFloat(i)
            
            buttonCharts.append(UIButton())
            
            buttonCharts[i].frame = CGRectMake(0, 0, 50, 40)
            //buttonCharts[i].backgroundColor = UIColor(red: 86/255, green: 199/255, blue: 149/255, alpha: 1.0)
            buttonCharts[i].tag = 19 + i
            buttonCharts[i].center = CGPoint(x: halfOneThirdWidth + (oneThirdWidth * j), y: screenSize.height - 33)
            buttonCharts[i].addTarget(self, action: "actionCharting:", forControlEvents: UIControlEvents.TouchUpInside)
            view.addSubview(buttonCharts[i])
        }
        
        buttonCharts[0].setImage(UIImage(named: "icon-chart-left.png"), forState: UIControlState.Normal)
        buttonCharts[1].setImage(UIImage(named: "icon-chart-both.png"), forState: UIControlState.Normal)
        buttonCharts[2].setImage(UIImage(named: "icon-chart-right.png"), forState: UIControlState.Normal)
    }
    
    func actionCharting(sender: UIButton) {

        performSegueWithIdentifier("jumpToCharts", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "jumpToNotes" {
            
            if let selectedIndex = self.tableView.indexPathForSelectedRow()?.row {
                
                var dateOfSelectedItem = dateResult[selectedIndex] as NSDate
                
                var secondVC: NotesViewController = segue.destinationViewController as NotesViewController
                
                secondVC.dateOfNote = dateOfSelectedItem
                secondVC.returnSegue = "jumpToResults"
            }
        }
        else {
            
            if let senderId = sender?.tag {
                println("Chart button segue tag working")
                
                var chartVC: ChartViewController = segue.destinationViewController as ChartViewController
                
                chartVC.chartLeftData = leftScore
                chartVC.chartRightData = rightScore
                chartVC.chartDateData = dateResult
                
                switch senderId {
                    
                case 19:
                    chartVC.chartType = "left"
                case 20:
                    chartVC.chartType = "left+right"
                case 21:
                    chartVC.chartType = "right"
                default:
                    break
                }
            }
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
