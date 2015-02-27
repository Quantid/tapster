//
//  RankingViewController.swift
//  Taptimal
//
//  Created by Matthew Lewis on 23/02/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit

class RankingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SideBarDelegate {
    
    var sideBar:SideBar = SideBar()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var busyIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let dateFormatter = NSDateFormatter()

    var playerName = [String]()
    var playerScore = [NSInteger]()
    var playerScoreDate = [NSDate]()
    var playerScoreLR = [NSString]()
    var playerImagePhoto = [UIImage]()

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func actionMenu(sender: AnyObject) {
        sideBar.showSideBar(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var i = 0
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Establish side bar menu
        sideBar = SideBar(sourceView: self.view)
        sideBar.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if Reachability.isConnectedToNetwork() {
            busyIndicator = activityIndicator.launchIndicator(self.view)
            populateTableWithPlayers()
        }
        else {
            showAlert("No Internet", msg: "Check your data connection and try again.")
        }
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRectMake(0, 60, screenSize.width, screenSize.height)
    }
    
    func populateTableWithPlayers() {
        
        var query = PFUser.query()
        query.whereKey("isSharing", equalTo: true)
        query.orderByDescending("lifeAverage")
        query.findObjectsInBackgroundWithBlock({
            (players, error) -> Void in
            
            for player in players {
                
                self.playerName.append(player["name"] as NSString)
                self.playerScore.append(player["lifeAverage"] as NSInteger)
                self.playerScoreDate.append(player["dateLifeAverage"] as NSDate)
                
                let LR_String = player["lifeAverageLR"] as String
                let LR_Array = split(LR_String) {$0 == "#"}
                self.playerScoreLR.append("L\(LR_Array[0]) | R\(LR_Array[1])")
                
                let imageFile = player["profileImage"] as? PFFile
                if let imageData = imageFile?.getData() {
                    self.playerImagePhoto.append(UIImage(data: imageData)!)
                }
                else {
                    self.playerImagePhoto.append(UIImage(named: "profile-silhuette.png")!)
                }
                self.tableView.reloadData()
            }
            activityIndicator.stopIndicator(self.busyIndicator)
        })
    }
    
    func timeSince(date: NSDate) -> NSString {
        var response = "unknown"
        
        let interval = abs(date.timeIntervalSinceNow)
        let days = Int(interval / (60 * 60 * 24))
        
        if days < 1 {
            response = "just now"
        }
        else if days < 2 {
            response = "1 day ago"
        }
        else if days < 7 {
            response = "\(days) days ago"
        }
        else if days < 8 {
            response = "last week"
        }
        else if days < 30 {
            response = "a few weeks ago"
        }
        else if days < 32 {
            response = "last month"
        }
        else {
            response = "a while ago"
        }

        return response
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerName.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: cellRanking = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as cellRanking

        cell.labelRank.text = "#\(indexPath.row + 1)"
        cell.imageProfilePhoto.image = playerImagePhoto[indexPath.row]
        cell.labelName.text = playerName[indexPath.row]
        cell.labelTimeSince.text = timeSince(playerScoreDate[indexPath.row])
        cell.labelScore.text = ("\(playerScore[indexPath.row])")
        cell.labelLeftRight.text = playerScoreLR[indexPath.row]
        
        cell.imageProfilePhoto.contentMode = UIViewContentMode.ScaleAspectFit
        cell.imageProfilePhoto.layer.cornerRadius = cell.imageProfilePhoto.frame.size.width/2
        cell.imageProfilePhoto.layer.borderWidth = 3
        cell.imageProfilePhoto.layer.borderColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 0.9).CGColor
        cell.imageProfilePhoto.layer.masksToBounds = true
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 0.1)
        } else {
            cell.backgroundColor = UIColor(red: 51/255, green: 58/255, blue: 64/255, alpha: 1.0)
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    func showAlert(title: NSString, msg: NSString) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
