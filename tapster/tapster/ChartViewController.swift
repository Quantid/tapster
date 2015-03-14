//
//  ChartViewController.swift
//  
//
//  Created by Matthew Lewis on 18/01/2015.
//
//

import UIKit

extension UIColor {
    class func leftPlotColor() -> UIColor {
        return UIColor(red: 160/255.0, green: 175/255.0, blue: 201/255.0, alpha: 1.0)
    }
    
    class func rightPlotColor() -> UIColor {
        return UIColor(red: 247/255.0, green: 101/255.0, blue: 72/255.0, alpha: 1.0)
    }
    
}

class ChartViewController: UIViewController, JBBarChartViewDelegate, JBBarChartViewDataSource {
    
    let barChartView = JBBarChartView()
    let barChartView2 = JBBarChartView()
    let headerHeight:CGFloat = 15
    let footerHeight:CGFloat = 15
    let headerView = UIView()
    let footerView = UIView()
    let padding:CGFloat = 10
    
    var chartDataX = [NSInteger]()
    var chartDataX2 = [NSInteger]()
    var chartDataY = [NSInteger]()
    var chartLeftData = [NSInteger]()
    var chartRightData = [NSInteger]()
    var chartDateData = [NSDate]()
    var chartType = ""
    var chartTitle = ""
    var subTitle = ""
    
    let labelTitle: UILabel = UILabel()
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    @IBOutlet weak var selectorChartPeriod: UISegmentedControl!
    @IBAction func actionChangeChartPeriod(sender: AnyObject) {
        
        // Get the selected period
        
        switch selectorChartPeriod.selectedSegmentIndex {
        case 0:
            subTitle = " - past month"
        case 1:
            subTitle = " - past 6 month"
        case 2:
            subTitle = " - past year"
        default:
            subTitle = ""
        }

        labelTitle.text = chartTitle + subTitle
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red:45/255, green:55/255, blue:64/255, alpha:1.0)
        
        // Handle chart data
        
        switch chartType {
            case "left":
                chartDataX = chartLeftData.reverse()
                chartTitle = "Left taps"
            case "right":
                chartDataX = chartRightData.reverse()
                chartTitle = "Right taps"
            case "left+right":
                chartDataX = chartLeftData.reverse()
                chartDataX2 = chartRightData.reverse()
                chartTitle = "Left and Right taps"
        default:
            chartDataX = chartLeftData.reverse()
            chartTitle = "Left taps"
        }
        
        if chartType == "left" || chartType == "right" {
            // Remove 0 from results array
            while (find(chartDataX, 0) != nil) {
                var indx = find(chartDataX, 0)
                chartDataX.removeAtIndex(indx!)
            }
            
            while (find(chartDataX2, 0) != nil) {
                var indx = find(chartDataX2, 0)
                chartDataX2.removeAtIndex(indx!)
            }
        }

        // Get max and min values
        
        let dataMax = chartDataX.reduce(Int.min, { max($0, $1) })
        let dataMin = chartDataX.reduce(Int.max, { min($0, $1) })
        let dataMinFl = CGFloat(dataMin)
        let chartDataMin: CGFloat = dataMinFl - (dataMinFl * 0.2)
        let chartDataMax = CGFloat(dataMax)
        
        selectorChartPeriod.setEnabled(true, forSegmentAtIndex: 3)  // Set segment selector to default
        
        // Setup bar chart
        barChartView.tag = 19
        barChartView.dataSource = self;
        barChartView.delegate = self;
        barChartView.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.2)
        barChartView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height / 2)
        barChartView.center = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        barChartView.minimumValue = chartDataMin
        
        // Header
        headerView.frame = CGRectMake(padding, ceil(self.view.bounds.size.height * 0.5) - ceil(headerHeight * 0.5),self.view.bounds.width - padding*2, headerHeight)
        
        // Footer
        footerView.frame = CGRectMake(padding, ceil(self.view.bounds.size.height * 0.5) - ceil(footerHeight * 0.5),self.view.bounds.width - padding*2, footerHeight)
        
        if chartType == "left" || chartType == "right" {
         
            // Establish chart
            
            barChartView.headerView = headerView
            barChartView.footerView = footerView
            
            barChartView.reloadData()
            
            self.view.addSubview(barChartView)
        }
        else {
            
            // Establish top (lefthand) chart
            barChartView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height / 3)
            barChartView.center = CGPoint(x: screenSize.width / 2, y: screenSize.height / 3)
            barChartView.headerView = headerView
            
            barChartView.reloadData()
            
            self.view.addSubview(barChartView)
            
            // Establish bottom (righthand) chart
            // Get max and min values
            
            let dataMax2 = chartDataX2.reduce(Int.min, { max($0, $1) })
            let dataMin2 = chartDataX2.reduce(Int.max, { min($0, $1) })
            let dataMinFl2 = CGFloat(dataMin2)
            let chartDataMin2: CGFloat = dataMinFl2 - (dataMinFl2 * 0.2)
            let chartDataMax2 = CGFloat(dataMax2)
            
            // Setup bottom chart
            
            barChartView2.tag = 29
            barChartView2.dataSource = self;
            barChartView2.delegate = self;
            barChartView2.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.2)
            barChartView2.frame = CGRectMake(0, 0, screenSize.width, screenSize.height / 3)
            barChartView2.center = CGPoint(x: screenSize.width / 2, y: (barChartView.center.y + screenSize.height / 3))
            barChartView2.minimumValue = chartDataMin2
            
            barChartView2.inverted = true
            
            barChartView2.reloadData()
            
            self.view.addSubview(barChartView2)
        }
        
        // Setup chart title
        labelTitle.frame = CGRectMake(0, 0, 300, 21)
        labelTitle.center = CGPointMake(screenSize.width / 2, barChartView.frame.origin.y - 18)
        labelTitle.textAlignment = NSTextAlignment.Center
        labelTitle.textColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
        labelTitle.font = UIFont(name: "HelveticaNeue-Regular", size: 14)
        labelTitle.text = chartTitle
        
        self.view.addSubview(labelTitle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {

        return UInt(chartDataX.count) //number of lines in chart
    }
    
    func barChartView(barChartView: JBBarChartView, heightForBarViewAtIndex index: UInt) -> CGFloat {
        
        var i = Int(index)
        
        if barChartView.tag == 19 {
            var plotValue = CGFloat(chartDataX[i])
            return plotValue
        }
        else {
            var plotValue = CGFloat(chartDataX2[i])
            return plotValue
        }
    }

    func barChartView(barChartView: JBBarChartView, colorForBarViewAtIndex index: UInt) -> UIColor {
        
        switch chartType {
            
        case "left":
                return (UIColor.leftPlotColor());
        case "right":
                return (UIColor.rightPlotColor());
        default:
            if barChartView.tag == 19 {
                return (UIColor.leftPlotColor());
            }
            else {
                return (UIColor.rightPlotColor());
            }
        }
    }
}
