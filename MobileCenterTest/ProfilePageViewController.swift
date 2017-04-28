//
//  ProfilePageViewController.swift
//  MobileCenterTest
//
//  Created by Insaf Safin on 27.04.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

import Charts

import HealthKit

class ProfilePageViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet var chartView: LineChartView?
    
    public var user: User? {
        didSet {
            setChartData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let chartView = chartView {
            chartView.delegate = self;
            chartView.dragEnabled = false
            chartView.scaleXEnabled = false
            chartView.scaleYEnabled = false
            
            chartView.xAxis.drawGridLinesEnabled = false
            chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
            
            
            chartView.drawBordersEnabled = false
            chartView.legend.enabled = false
            chartView.chartDescription?.enabled = false
            
            chartView.leftAxis.setLabelCount( 5, force: false )
            chartView.rightAxis.enabled = false
        }
        
        setChartData()
    }
    
    func setChartData() {
        
        if let chartView = chartView {
            
            var values = Array<ChartDataEntry>()
            
            if let user = user {
                for i in 0...24 {
                    if let stats = user.userStats.get(for: 0, and: i ) {
                        let value = stats[HKQuantityTypeIdentifier.stepCount.rawValue]
                        values.append( ChartDataEntry( x: Double(i), y: value ) )
                    }
                    else {
                        values.append( ChartDataEntry( x: Double(i), y: 0 ) )
                    }
                    
                }
            }
            else {
                let dataAmount = 24
                let range = 200
                
                for i in 0...dataAmount {
                    let value = arc4random_uniform(UInt32(range)) + 3
                    values.append( ChartDataEntry( x: Double(i), y: Double(value) ) )
                }
            }
            
            let set1 = LineChartDataSet( values: values, label: "" )
            set1.drawIconsEnabled = false
            
            set1.lineDashLengths = nil
            set1.highlightEnabled = false
            set1.setColor( UIColor( red: 0.0/255.0, green: 156.0/255.0, blue: 205.0/255.0, alpha: 1 ) )
            set1.setCircleColor( UIColor(red: 0.0/255.0, green: 156.0/255.0, blue: 205.0/255.0, alpha: 1 ) )
            set1.lineWidth = 2.0
            set1.drawCirclesEnabled = false
            set1.drawCircleHoleEnabled = false
            set1.drawValuesEnabled = false
            set1.valueFont = UIFont.systemFont( ofSize: 9 )
            set1.formLineDashLengths = nil
            set1.formLineWidth = 0.0
            set1.formSize = 15.0
            
            let gradientColors = [
                UIColor(red: 220.0/255.0, green: 242.0/255.0, blue: 250.0/255.0, alpha: 0.6).cgColor,
                UIColor(red: 220.0/255.0, green: 242.0/255.0, blue: 250.0/255.0, alpha: 0.6).cgColor
                ] as CFArray
            
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: nil )
            
            set1.fillAlpha = 1;
            set1.fill = Fill.fillWithLinearGradient( gradient!, angle: 90 )
            set1.drawFilledEnabled = true;
            
            let dataSets = [set1] as Array
            let data = LineChartData(dataSets: dataSets)
            
            
            chartView.xAxis.setLabelCount( values.count / 2, force: false )
            chartView.data = data;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func crashApplication() {
        self.setChartData()
    }
    
    @IBAction func returnBack() {
        
    }
}
