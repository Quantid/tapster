//
//  PageContentViewController.swift
//  tapster
//
//  Created by Matthew Lewis on 22/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let imageActivity: UIImageView = UIImageView()
    
    
    var dataObject: AnyObject?
    var pageNumber: NSInteger?
    
    @IBOutlet weak var labelBlurb: UILabel!
    @IBAction func actionStartWalkthrough(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup image view
        imageActivity.image = UIImage(named: "image-walkthrough\(pageNumber! + 1).png")
        imageActivity.frame = CGRectMake(0, 30, screenSize.width, 128)
        imageActivity.contentMode = UIViewContentMode.ScaleAspectFill
        view.addSubview(imageActivity)
        
        // Setup page control (dots)
        
        let pageControl: UIPageControl = UIPageControl()
        pageControl.frame = CGRectMake(0, 0, 200, 20)
        pageControl.center = CGPoint(x: screenSize.width / 2, y: screenSize.height - 30)
        pageControl.numberOfPages = 4
        pageControl.currentPage = pageNumber!
        view.addSubview(pageControl)
    }

    override func viewWillAppear(animated: Bool) {
        
        let blurb = dataObject as String
        labelBlurb.text = blurb
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
