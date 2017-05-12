//
//  ProfilePageViewController.swift
//  MobileCenterExample
//
//  Created by Insaf Safin on 27.04.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit
import Charts
import HealthKit
import MobileCenterAnalytics
import MobileCenterCrashes

class StatisticsViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet var chartView: LineChartView?
    @IBOutlet var stepsButton: UIButton?
    @IBOutlet var caloriesButton: UIButton?
    @IBOutlet var distanceButton: UIButton?
    @IBOutlet var timeButton: UIButton?
    
    var buttons = [UIButton]()
    
    let actualTypes = [HKQuantityTypeIdentifier.stepCount,
                       HKQuantityTypeIdentifier.activeEnergyBurned,
                       HKQuantityTypeIdentifier.distanceWalkingRunning]
    
    private class DayChartFormatter: NSObject, IAxisValueFormatter {
        
        var labels: [String] = []
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//            return labels[Int(value)]
            return String(Int(value))
        }
        
        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
    }
    
    private var selectedDataType: HKQuantityTypeIdentifier? {
        didSet {
            if oldValue != selectedDataType {
                setChartData()
            }
        }
    }
    
    public var userStats: TimedData<UserStats>? {
        didSet {
            setChartData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedDataType = actualTypes.first
        
        if let button = self.stepsButton {
            deselectButtonsExcept(button: button)
            buttons.append( button )
        }
        if let button = self.caloriesButton {
            buttons.append( button )
        }
        if let button = self.distanceButton {
            buttons.append( button )
        }
        if let button = self.timeButton {
            buttons.append( button )
        }
        
        for button in buttons {
            button.layer.cornerRadius = 3
            button.clipsToBounds = true
        }
        
        if let chartView = chartView {
            chartView.delegate = self;
            chartView.dragEnabled = false
            chartView.scaleXEnabled = false
            chartView.scaleYEnabled = false
            
            chartView.xAxis.drawGridLinesEnabled = false
            chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
            chartView.xAxis.valueFormatter = DayChartFormatter(labels: [])
            
            chartView.leftAxis.drawAxisLineEnabled = false
            chartView.leftAxis.setLabelCount( 5, force: false )
            
            chartView.rightAxis.enabled = false
            
            chartView.drawBordersEnabled = false
            chartView.legend.enabled = false
            chartView.chartDescription?.enabled = false
        }
        
        setChartData()
    }
    
    func setChartData() {
        
        if let chartView = chartView {
            
            guard let typeId = selectedDataType else {
                return
            }
            
            var values = Array<ChartDataEntry>()
            
            if let userStats = userStats {
                for i in 0...4 {
                    if let stats = userStats.get(for: i ) {
                        let value = stats[typeId.rawValue]
                        values.append( ChartDataEntry( x: Double(i), y: value ) )
                    }
                    else {
                        values.append( ChartDataEntry( x: Double(i), y: 0 ) )
                    }
                    
                }
            }
            else {
                return
            }
            
            let set1 = LineChartDataSet( values: values, label: "" )
            set1.drawIconsEnabled = false
            
            set1.mode = .linear
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
            
            
            chartView.xAxis.setLabelCount( values.count - 1, force: false )
            chartView.data = data;
        }
    }

    func deselectButtonsExcept( button: UIButton ) {
        for btn in buttons {
            if ( btn != button ) {
                btn.backgroundColor = UIColor.clear
            }
            else {
                btn.backgroundColor = UIColor.init(white: 244.0/255.0, alpha: 1)
            }
        }
    }
    
    @IBAction func crashApplication() {
        MSCrashes.generateTestCrash()
    }
    
    @IBAction func returnBack() {
        
    }
    
    @IBAction func statButtonTap( sender: UIButton ) {
        deselectButtonsExcept(button: sender)
//            selectedDataType = actualTypes[sender.selectedSegmentIndex]
    }
}
