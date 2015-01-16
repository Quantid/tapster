//
//  SideBarTableViewController.swift
//  BlurrySideBar
//
//  Created by Training on 01/09/14.
//  Copyright (c) 2014 Training. All rights reserved.
//

import UIKit


protocol SideBarTableViewControllerDelegate{
    func sideBarControlDidSelectRow(indexPath:NSIndexPath)
}

class SideBarTableViewController: UITableViewController {

    var delegate:SideBarTableViewControllerDelegate?
    var tableData:Array<String> = []
    var menuIconData:Array<String> = []
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return tableData.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell

        let menuIconView:UIImageView = UIImageView(frame: CGRect(x: 24, y: 8, width: 30, height: 30))
        menuIconView.contentMode = UIViewContentMode.ScaleAspectFit
        
        let menuTextView:UILabel = UILabel(frame: CGRect(x: 80, y: 0, width: 120, height: 50))
        menuTextView.textColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
        menuTextView.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        menuTextView.contentMode = UIViewContentMode.Center
        
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            
            // Configure the cell...
            
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
            cell!.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 14)

            let selectedView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)

            cell!.selectedBackgroundView = selectedView
        }
        
        //cell!.textLabel?.text = tableData[indexPath.row]
        menuTextView.text = tableData[indexPath.row]
        cell!.addSubview(menuTextView)
        
        menuIconView.image = UIImage(named: menuIconData[indexPath.row])
        cell!.addSubview(menuIconView)

        return cell!
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.sideBarControlDidSelectRow(indexPath)
    }



}
