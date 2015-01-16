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
        
        self.tableView.dataSource = self
        self.tableView.delegate = self

        var dateMonthFormatter = NSDateFormatter()
        var dateDayFormatter = NSDateFormatter()
        
        dateMonthFormatter.dateFormat = "MMM"
        dateDayFormatter.dateFormat = "dd"
        
        setupPerformanceView()  // Setup performace view at the top of table
        
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

        // Establish side bar menu
        
        sideBar = SideBar(sourceView: self.view,
            menuItems: ["Tap Test", "Performance", "Profile", "Settings"],
            menuIconItems: ["icon-menu-taptest.png", "icon-menu-performance.png", "icon-menu-profile.png", "icon-menu-settings.png"])
        
        sideBar.delegate = self
        
        // Initialise core data
        
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Results")
     
        request.propertiesToFetch = NSArray(object: "date")
        request.returnsObjectsAsFaults = false
        request.returnsDistinctResults = true
        request.resultType = NSFetchRequestResultType.DictionaryResultType
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        var dates:NSArray = context.executeFetchRequest(request, error: nil)!
        
        for date in dates {
            
            var dateQuery = date["date"] as NSDate
            
            var request = NSFetchRequest(entityName: "Results")
            
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "date = %@", dateQuery)

            var results = context.executeFetchRequest(request, error: nil)!
            
            var interval = dateQuery.timeIntervalSinceDate(dateLastWeek) / daysInSeconds
            
            if results[0].valueForKey("hand")! as NSString == "right" {
                
                var tc = results[0].valueForKey("tapCount") as NSInteger
                
                rightScore.append(tc)
                
                if interval < averagingPeriod {
                    rightTotal = rightTotal + tc
                    rightCounter++
                }
                
                if results.count > 1 {
                    
                    var tc = results[1].valueForKey("tapCount") as NSInteger
                    
                    leftScore.append(tc)
                    
                    if interval < averagingPeriod {
                        
                        leftTotal = leftTotal + tc
                        leftCounter++
                    }
                }
                else {
                    
                    leftScore.append(0)
                }
            }
            else {
                
                var tc = results[0].valueForKey("tapCount") as NSInteger
                
                leftScore.append(tc)
                
                if interval < averagingPeriod {
                    
                    leftTotal = leftTotal + tc
                    leftCounter++
                }
                
                if results.count > 1 {
                    
                    var tc = results[1].valueForKey("tapCount") as NSInteger
                    
                    rightScore.append(tc)
                    
                    if interval < averagingPeriod {
                        
                        rightTotal = rightTotal + tc
                        rightCounter++
                    }
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
            
            //tableView?.reloadData()
        }
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "jumpToNotes" {
            
            if let selectedIndex = self.tableView.indexPathForSelectedRow()?.row {
                
                var dateOfSelectedItem = dateResult[selectedIndex] as NSDate
                
                var secondVC: NotesViewController = segue.destinationViewController as NotesViewController
                
                secondVC.dateOfNote = dateOfSelectedItem
                secondVC.returnSegue = "jumpToResults"
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("jumpToNotes", sender: self)
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
