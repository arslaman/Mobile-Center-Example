//
//  ProfilePageViewController.swift
//  MobileCenterExample
//
//  Created by Insaf Safin on 27.04.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit
import Charts

class StatisticsViewController: UIViewController, ChartViewDelegate {
    
    fileprivate var analyticsService: AnalyticsService?
    fileprivate var crashesService: CrashesService?
    
    @IBOutlet var chartView: LineChartView!
    @IBOutlet var stepsButton: UIButton!
    @IBOutlet var caloriesButton: UIButton!
    @IBOutlet var distanceButton: UIButton!
    @IBOutlet var timeButton: UIButton!
    
    lazy var buttons: [UIButton] = {
        return [self.stepsButton!, self.caloriesButton!, self.distanceButton!, self.timeButton!]
    }()
    
    lazy var typesForButtons: [UIButton: FitnessType] = {
        return [
            self.stepsButton!: .Steps,
            self.caloriesButton!: .Calories,
            self.distanceButton!: .Distance,
            self.timeButton!: .ActiveTime,
        ]
    }()
    
    fileprivate class DayChartFormatter: NSObject, IAxisValueFormatter {
        let referenceDate: Date
        let dateFormatter = DateFormatter()

        init(referenceDate: Date) {
            dateFormatter.dateFormat = "MMM\ndd"
            self.referenceDate = referenceDate
        }
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let date = Calendar.current.date(byAdding: .day, value: Int(value), to: referenceDate)
            let result = dateFormatter.string(from: date!)
            return result
        }
    }
    
    fileprivate var selectedDataType: FitnessType? {
        didSet {
            if oldValue != selectedDataType {
                updateChartData()
            }
        }
    }
    
    open var fitnessData: TimedData<FitnessDailyData>? {
        didSet {
            updateChartData()
        }
    }
    
    func configure(analyticsService: AnalyticsService, crashesService: CrashesService) {
        self.analyticsService = analyticsService
        self.crashesService = crashesService
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedDataType = .Steps
        deselectButtonsExcept(stepsButton)
        
        for button in buttons {
            button.layer.cornerRadius = 3
            button.clipsToBounds = true
        }
        
        configureChartView()
        updateChartData()
    }
    
    func configureChartView() {
        chartView.delegate = self;
        chartView.dragEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.leftAxis.setLabelCount( 5, force: false )
        chartView.leftAxis.axisMinimum = 0.0
        
        chartView.rightAxis.enabled = false
        
        chartView.drawBordersEnabled = false
        chartView.legend.enabled = false
        chartView.chartDescription?.enabled = false
    }
    
    func updateChartData() {
        
        guard let type = selectedDataType else {
            return
        }
        
        guard let dataByDays = fitnessData?.array(), dataByDays.count > 0 else {
            return
        }
        
        var values = Array<ChartDataEntry>()
        for i in 0..<dataByDays.count {
            let dailyData = dataByDays[i]
            let value = appropriateValueForType(type, daylyData: dailyData)
            values.append( ChartDataEntry( x: Double(i), y: value ) )
        }
        
        let dataSets = [lineDataSet(values: values)]
        let data = LineChartData(dataSets: dataSets)
        
        let referenceDate = dataByDays.first!.date
        chartView.xAxis.valueFormatter = DayChartFormatter(referenceDate: referenceDate)
        chartView.xAxis.setLabelCount( values.count - 1, force: false )
        chartView.data = data;
    }
    
    func lineDataSet(values: [ChartDataEntry]) -> LineChartDataSet {
        let set = LineChartDataSet( values: values, label: "" )
        set.drawIconsEnabled = false
        
        set.mode = .linear
        set.lineDashLengths = nil
        set.highlightEnabled = false
        set.setColor( UIColor( red: 0.0/255.0, green: 156.0/255.0, blue: 205.0/255.0, alpha: 1 ) )
        set.setCircleColor( UIColor(red: 0.0/255.0, green: 156.0/255.0, blue: 205.0/255.0, alpha: 1 ) )
        set.lineWidth = 2.0
        set.drawCirclesEnabled = false
        set.drawCircleHoleEnabled = false
        set.drawValuesEnabled = false
        set.valueFont = UIFont.systemFont( ofSize: 9 )
        set.formLineDashLengths = nil
        set.formLineWidth = 0.0
        set.formSize = 15.0
        
        let gradientColors = [
            UIColor(red: 220.0/255.0, green: 242.0/255.0, blue: 250.0/255.0, alpha: 0.6).cgColor,
            UIColor(red: 220.0/255.0, green: 242.0/255.0, blue: 250.0/255.0, alpha: 0.6).cgColor
            ] as CFArray
        
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: nil )
        
        set.fillAlpha = 1;
        set.fill = Fill.fillWithLinearGradient( gradient!, angle: 90 )
        set.drawFilledEnabled = true;
        
        return set
    }
    
    func appropriateValueForType(_ type: FitnessType, daylyData: FitnessDailyData) -> Double {
        switch type {
        case .Steps:
            return Double(daylyData.stepsCount)
        case .Calories:
            return daylyData.calories
        case .Distance:
            return daylyData.distanceInKM
        case .ActiveTime:
            return daylyData.activeTimeInMinutes
        }
    }

    func deselectButtonsExcept( _ button: UIButton ) {
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
        analyticsService?.trackCrashClick()
        crashesService?.generateTestCrash()
    }
    
    @IBAction func statButtonTap( sender: UIButton ) {
        deselectButtonsExcept(sender)
        selectedDataType = typesForButtons[sender]
    }
}
