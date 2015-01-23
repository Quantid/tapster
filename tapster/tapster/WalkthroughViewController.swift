//
//  WalkthroughViewController.swift
//  tapster
//
//  Created by Matthew Lewis on 22/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var pageController: UIPageViewController?
    var pageContent = NSArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createContentPages()
        
        pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        
        pageController?.delegate = self
        pageController?.dataSource = self
        
        let startingViewController: PageContentViewController = viewControllerAtIndex(0)!
        
        let viewControllers: NSArray = [startingViewController]
        
        pageController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
        
        self.addChildViewController(pageController!)
        self.view.addSubview(self.pageController!.view)
        
        var pageViewRect = self.view.bounds  
        pageController!.view.frame = pageViewRect    
        pageController!.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createContentPages() {
        
        var pageStrings = [String]()
        
        pageStrings.append("Taptimal keeps you at the peak of your game, helping you to work harder, play better and train stronger.")
        pageStrings.append("Taptimal is based on the finger-tapping test, which reflects the status of your central nervous system (CNS), which controls your mental and physical performance. Demanding cognitive or physical tasks are best performed on days when your CNS is at its strongest. Taptimal let’s you know when those optimal days are.")
        pageStrings.append("Place your phone on a flat surface. With your wrist and palm planted flat on the surface, tap on the screen as fast as you can using your index finger (that’s the one next to your thumb). Use only the motion of your finger…no wrist action – that’s cheating. ")
        pageStrings.append("To get the most out of Taptimal, use it everyday at the same time – ideally as soon as you get out of bed. Test both your left and right hand. Over time, Taptimal will learn your baseline ability and will tell you when your performance is strong, normal or weak.")

        pageContent = pageStrings
    }
    
    func viewControllerAtIndex(index: Int) -> PageContentViewController? {
        
        if (pageContent.count == 0) ||
            (index >= pageContent.count) {
                return nil
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let dataViewController = storyBoard.instantiateViewControllerWithIdentifier("PageContentViewController") as PageContentViewController
        
        dataViewController.dataObject = pageContent[index]
        dataViewController.pageNumber = index
        return dataViewController
    }
    
    func indexOfViewController(viewController: PageContentViewController) -> Int {
        
        if let dataObject: AnyObject = viewController.dataObject {
            return pageContent.indexOfObject(dataObject)
        } else {
            return NSNotFound
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = indexOfViewController(viewController as PageContentViewController)
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = indexOfViewController(viewController as PageContentViewController)
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        if index == pageContent.count {
            return nil
        }
        return viewControllerAtIndex(index)
    }
}
