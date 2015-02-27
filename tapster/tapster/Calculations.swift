//
//  Calculations.swift
//  Taptimal
//
//  Created by Matthew Lewis on 25/02/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit
import CoreData

class Calculations: NSObject {
    
    func performanceThresholds(arrayOfAverages: [NSInteger]) {
        println("array of averages\(arrayOfAverages)")
        if arrayOfAverages.count > 4 {

            let sortedArrayOfAverages = arrayOfAverages.sorted(>)

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
   
    func lifeAverage() -> [NSInteger]{

        var response = [0]
        var foundAtLeastOnePair: Bool = false
        var rightScore = [NSInteger]()
        var leftScore = [NSInteger]()
        var averageScore = [NSInteger]()
        let dateToday = NSDate()
        let oneMonthAgo: NSTimeInterval = (-1 * 60 * 60 * 24 * 30)
        let dateLastMonth = dateToday.dateByAddingTimeInterval(oneMonthAgo)
        var pairedResultAverages = [NSInteger]() // An array of the averages of all paird results

        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Results")
        request.propertiesToFetch = NSArray(object: "date")
        request.returnsObjectsAsFaults = false
        request.returnsDistinctResults = true
        request.resultType = NSFetchRequestResultType.DictionaryResultType
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.predicate = NSPredicate(format: "syncStatusParse < 3 AND date > %@", dateLastMonth)
        
        var dates:NSArray = context.executeFetchRequest(request, error: nil)!
        
        for date in dates {
            
            var dateQuery = date["date"] as NSDate
            
            var request = NSFetchRequest(entityName: "Results")
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "date == %@", dateQuery)
            
            var results = context.executeFetchRequest(request, error: nil)!
            
            if results[0].valueForKey("hand")! as NSString == "right" {
                var rc = results[0].valueForKey("tapCount") as NSInteger
                
                if results.count > 1 {
                    var lc = results[1].valueForKey("tapCount") as NSInteger
                    
                    leftScore.append(lc)
                    rightScore.append(rc)
                    averageScore.append(Int((lc + rc) / 2))
                    foundAtLeastOnePair = true
                }
            }
            else {
                var lc = results[0].valueForKey("tapCount") as NSInteger
                
                if results.count > 1 {
                    var rc = results[1].valueForKey("tapCount") as NSInteger
                    
                    leftScore.append(lc)
                    rightScore.append(rc)
                    averageScore.append(Int((lc + rc) / 2))
                    foundAtLeastOnePair = true
                }
            }
        }
        performanceThresholds(averageScore)
        
        if foundAtLeastOnePair {
            let count = leftScore.count
            let leftAverage: NSInteger = Int(leftScore.reduce(0,+) / count)
            let rightAverage: NSInteger = Int(rightScore.reduce(0,+) / count)
            var lifeAverage: NSInteger = Int((leftAverage + rightAverage) / 2)
            
            response = [leftAverage, rightAverage, lifeAverage]
        }
        return response
    }
}
