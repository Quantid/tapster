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
        return UIColor(red: 21.0/255.0, green: 46.0/255.0, blue: 158.0/255.0, alpha: 1.0)
    }
    
    class func rightPlotColor() -> UIColor {
        return UIColor(red: 158.0/255.0, green: 27.0/255.0, blue: 21.0/255.0, alpha: 1.0)
    }
    
}

class ChartViewController: UIViewController, JBBarChartViewDelegate, JBBarChartViewDataSource {
    
    let barChartView = JBBarChartView()
    let headerHeight:CGFloat = 15
    let footerHeight:CGFloat = 15
    let headerView = UIView()
    let footerView = UIView()
    let padding:CGFloat = 10
    
    var chartDataX = [NSInteger]()
    var chartDataX1 = [NSInteger]()
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
                chartDataX = chartLeftData
                chartTitle = "Left hand taps"
            
            case "right":
                chartDataX = chartRightData
                chartTitle = "Right hand taps"
            
            case "left+right":
                chartDataX = chartLeftData
                chartDataX1 = chartRightData
                chartTitle = "Left and Right hand taps"

        default:
            chartDataX = chartLeftData
            chartTitle = "Left hand taps"
        }
        
        // Remove 0 from results array
        
        println(chartDataX)
        while (find(chartDataX, 0) != nil) {
            
            var indx = find(chartDataX, 0)
            
            chartDataX.removeAtIndex(indx!)
        }
        
        while (find(chartDataX1, 0) != nil) {
            
            var indx = find(chartDataX1, 0)
            
            chartDataX1.removeAtIndex(indx!)
        }

        // Get max and min values
        
        let dataMax = chartDataX.reduce(Int.min, { max($0, $1) })
        let dataMin = chartDataX.reduce(Int.max, { min($0, $1) })
        let dataMinFl = CGFloat(dataMin)
        let chartDataMin: CGFloat = dataMinFl - (dataMinFl * 0.2)
        let chartDataMax = CGFloat(dataMax)
        
        selectorChartPeriod.setEnabled(true, forSegmentAtIndex: 3)  // Set segment selector to default
        
        // Setup bar chart
        
        barChartView.dataSource = self;
        barChartView.delegate = self;
        barChartView.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.2)
        barChartView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height / 2)
        barChartView.center = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        barChartView.minimumValue = chartDataMin
        
        // Header
        headerView.frame = CGRectMake(padding, ceil(self.view.bounds.size.height * 0.5) - ceil(headerHeight * 0.5),self.view.bounds.width - padding*2, headerHeight)
        barChartView.headerView = headerView
        
        // Footer
        footerView.frame = CGRectMake(padding, ceil(self.view.bounds.size.height * 0.5) - ceil(footerHeight * 0.5),self.view.bounds.width - padding*2, footerHeight)
        barChartView.footerView = footerView
        
        barChartView.reloadData()
        
        self.view.addSubview(barChartView)
        
        // Setup chart title
        
        labelTitle.frame = CGRectMake(0, 0, 200, 21)
        labelTitle.center = CGPointMake(screenSize.width / 2, barChartView.frame.origin.y - 20)
        labelTitle.textAlignment = NSTextAlignment.Center
        labelTitle.textColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
        labelTitle.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        labelTitle.text = chartTitle
        
        self.view.addSubview(labelTitle)
        
        println("Launched");
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {

        return UInt(chartDataX.count) //number of lines in chart
    }
    
    func barChartView(barChartView: JBBarChartView, heightForBarViewAtIndex index: UInt) -> CGFloat {
        println("barChartView", index)
        var i = Int(index)
        var plotValue = CGFloat(chartDataX[i])
        return plotValue
    }

    func barChartView(barChartView: JBBarChartView, colorForBarViewAtIndex index: UInt) -> UIColor {
        
        if chartType == "left" {
            
            return (UIColor.leftPlotColor());
        }
        else {
            
            return (UIColor.rightPlotColor());
        }
    }
    
}
