//
//  SideBar.swift
//  BlurrySideBar
//
//  Created by Training on 01/09/14.
//  Copyright (c) 2014 Training. All rights reserved.
//

import UIKit

@objc protocol SideBarDelegate{
    func sideBarDidSelectButtonAtIndex(index:Int)
    optional func sideBarWillClose()
    optional func sideBarWillOpen()
}

class SideBar: NSObject, SideBarTableViewControllerDelegate {
    
    let barWidth:CGFloat = 240.0
    let sideBarTableViewTopInset:CGFloat = 200.0
    let sideBarContainerView:UIView = UIView()
    let sideBarTableViewController:SideBarTableViewController = SideBarTableViewController()
    let originView:UIView!
   
    var animator:UIDynamicAnimator!
    var delegate:SideBarDelegate?
    var isSideBarOpen:Bool = false
    
    override init() {
        super.init()
    }
    
    init(sourceView:UIView, menuItems:Array<String>, menuIconItems:Array<String>){
        super.init()
        originView = sourceView
        sideBarTableViewController.tableData = menuItems
        sideBarTableViewController.menuIconData = menuIconItems
        
        setupSideBar()
        
        animator = UIDynamicAnimator(referenceView: originView)
        
        let showGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        originView.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        originView.addGestureRecognizer(hideGestureRecognizer)
        
    }
    
    
    func setupSideBar(){
        
        sideBarContainerView.frame = CGRectMake(-barWidth - 1, originView.frame.origin.y - 3, barWidth, originView.frame.size.height)
        sideBarContainerView.backgroundColor = UIColor.clearColor()
        sideBarContainerView.clipsToBounds = false
        sideBarContainerView.layoutMargins = UIEdgeInsetsZero
        
        // Add shadow
        
        sideBarContainerView.layer.shadowColor = UIColor.blackColor().CGColor
        sideBarContainerView.layer.shadowOffset = CGSizeMake(2, 0)
        sideBarContainerView.layer.shadowRadius = 2
        sideBarContainerView.layer.shadowOpacity = 0.8
        
        originView.addSubview(sideBarContainerView)
        
        // Add blur effect
        
        //let blurView:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        //blurView.frame = sideBarContainerView.bounds
        //sideBarContainerView.addSubview(blurView)
        
        
        sideBarTableViewController.delegate = self
        //sideBarTableViewController.tableView.frame = sideBarContainerView.bounds
        sideBarTableViewController.tableView.frame = CGRectMake(sideBarContainerView.bounds.origin.x - 15, sideBarContainerView.bounds.origin.y, sideBarContainerView.bounds.width, sideBarContainerView.bounds.height)
        sideBarTableViewController.tableView.clipsToBounds = false
        sideBarTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        sideBarTableViewController.tableView.backgroundColor = UIColor(red: 78/255, green: 88/255, blue: 98/255, alpha: 1.0)
        sideBarTableViewController.tableView.scrollsToTop  = false
        sideBarTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideBarTableViewTopInset, 0, 0, 0)
        sideBarTableViewController.tableView.preservesSuperviewLayoutMargins = false
        
        sideBarTableViewController.tableView.reloadData()
        
        sideBarContainerView.addSubview(sideBarTableViewController.tableView)
        
        sideBarTableViewController.tableView.tableFooterView = UIView(frame:CGRectZero)
        
        // Add masthead image
        
        let image = UIImage(named: "masthead.png")
        let imageMasthead = UIImageView(image: image)
        imageMasthead.frame = CGRectMake(sideBarContainerView.bounds.origin.x - 15, 0, sideBarContainerView.bounds.width, 130)
        imageMasthead.contentMode = UIViewContentMode.ScaleAspectFit
        
        sideBarContainerView.addSubview(imageMasthead)
        
        // Add user profile image
        
        let imageUserPhoto = UIImageView()
        let imageUserPhotoNS: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("image")

        if let imageData: NSData = imageUserPhotoNS as? NSData {
            
            imageUserPhoto.image = UIImage (data: imageData)
            imageUserPhoto.frame = CGRectMake(sideBarContainerView.bounds.origin.x - 15 + 68, 70, 105, 105)
            imageUserPhoto.contentMode = UIViewContentMode.ScaleAspectFit
            imageUserPhoto.layer.cornerRadius = imageUserPhoto.frame.size.width/2
            imageUserPhoto.layer.borderWidth = 5
            imageUserPhoto.layer.borderColor = UIColor(red: 138/255, green: 150/255, blue: 158/255, alpha: 1.0).CGColor
            imageUserPhoto.layer.masksToBounds = true
            
            sideBarContainerView.addSubview(imageUserPhoto)
        }

    }
    
    
    func handleSwipe(recognizer:UISwipeGestureRecognizer){
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left{
            showSideBar(false)
            delegate?.sideBarWillClose?()
            
        }else{
            showSideBar(true)
            delegate?.sideBarWillOpen?()
        }
    
    }
    
    
    func showSideBar(shouldOpen: Bool){
        animator.removeAllBehaviors()
        isSideBarOpen = shouldOpen
        
        let gravityX:CGFloat = (shouldOpen) ? 0.7 : -0.7
        let magnitude:CGFloat = (shouldOpen) ? 20 : -20
        let boundaryX:CGFloat = (shouldOpen) ? barWidth : -barWidth - 1
        
        
        let gravityBehavior:UIGravityBehavior = UIGravityBehavior(items: [sideBarContainerView])
        gravityBehavior.gravityDirection = CGVectorMake(gravityX, 0)
        animator.addBehavior(gravityBehavior)
        
        let collisionBehavior:UICollisionBehavior = UICollisionBehavior(items: [sideBarContainerView])
        collisionBehavior.addBoundaryWithIdentifier("sideBarBoundary", fromPoint: CGPointMake(boundaryX, 20), toPoint: CGPointMake(boundaryX, originView.frame.size.height))
        animator.addBehavior(collisionBehavior)
        
        let pushBehavior:UIPushBehavior = UIPushBehavior(items: [sideBarContainerView], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.magnitude = magnitude
        animator.addBehavior(pushBehavior)
        
        
        let sideBarBehavior:UIDynamicItemBehavior = UIDynamicItemBehavior(items: [sideBarContainerView])
        sideBarBehavior.elasticity = 0.1
        animator.addBehavior(sideBarBehavior)
    
    }

    func sideBarControlDidSelectRow(indexPath: NSIndexPath) {
        delegate?.sideBarDidSelectButtonAtIndex(indexPath.row)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
