//
//  MainPageViewController.swift
//  MobileCenterTest
//
//  Created by Insaf Safin on 26.04.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

import HealthKit

import MobileCenterAnalytics

class MainPageViewController: UIViewController {

    @IBOutlet var caloriesLabel: UILabel?
    @IBOutlet var stepsLabel: UILabel?
    @IBOutlet var distanceLabel: UILabel?
    @IBOutlet var greetingsLabel: UILabel?
    
    var labels = [String : UILabel]()
    
    var healthStore = HKHealthStore()
    
    let actualTypes = [HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                       HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                       HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!]
    
    let doubleFormatter = NumberFormatter()
    let integerFormatter = NumberFormatter()
    var formatters = [String: NumberFormatter]()
    
    public var user: User? {
        didSet {
            self.fillContent()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doubleFormatter.groupingSize = 3
        doubleFormatter.maximumFractionDigits = 2
        
        integerFormatter.maximumFractionDigits = 0;
        integerFormatter.groupingSize = 3;
        
        formatters[HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue] = doubleFormatter
        formatters[HKQuantityTypeIdentifier.activeEnergyBurned.rawValue] = doubleFormatter
        formatters[HKQuantityTypeIdentifier.stepCount.rawValue] = integerFormatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labels[HKQuantityTypeIdentifier.stepCount.rawValue] = stepsLabel
        labels[HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue] = distanceLabel
        labels[HKQuantityTypeIdentifier.activeEnergyBurned.rawValue] = caloriesLabel
        
        self.loadHealthKitData()
        self.fillContent()
    }

    func fillContent() -> Void {
        if !self.isViewLoaded {
            return
        }
        
        if let user = user {
            greetingsLabel?.text = "Hi, \(user.fullName)"
        }
        for type in actualTypes {
            self.updateLabel(for: type)
        }
    }
    
    func updateLabel( for type: HKQuantityType ) -> Void {
        guard let label = labels[type.identifier] else {
            fatalError()
        }
        
        if let value = self.user?.userStats.get( for: 0 )[type.identifier] {
            if let formatter = formatters[type.identifier] {
                label.text = formatter.string(from: value as NSNumber)
            }
        }
        else {
            label.text = "0"
        }
    }
    
    func sampleValueChanged( type: HKQuantityType ) -> Void {
        self.updateLabel(for: type)
    }
    
    func querySample( type: HKQuantityType, for days: Int ) -> Void {
        
        let calendar = NSCalendar.current
        let startOfToday = Date().startOfDay
        
        for day in 0...days {
            for hour in 0...23 {
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.day = -day
                
                let startDate = calendar.date( byAdding: dateComponents, to: startOfToday )
                let endDate = calendar.date( byAdding: .hour, value: 1, to: startDate! )
                
                let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
                let statisticQuery = HKStatisticsQuery(quantityType: type,
                                                       quantitySamplePredicate: predicate,
                                                       options: [HKStatisticsOptions.cumulativeSum])
                { ( query, result, error) in
                    if let sumQuantity = result?.sumQuantity() {
                        
                        var unit: HKUnit
                        switch type.identifier {
                        case HKQuantityTypeIdentifier.stepCount.rawValue:
                            unit = HKUnit.count()
                        case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
                            unit = HKUnit.meterUnit(with: HKMetricPrefix.kilo)
                        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
                            unit = HKUnit.kilocalorie()
                        default:
                            fatalError( "unsupported HKQuantityTypeIdentifier" )
                        }
                        
                        let value = sumQuantity.doubleValue( for: unit )
                        self.user?.userStats.getOrCreate( for: day, and: hour )[type.identifier] = value
                        DispatchQueue.main.async {
                            self.sampleValueChanged(type: type)
                        }
                    }
                }
                
                self.healthStore.execute( statisticQuery )
            }
        }
    
    }
    
    func loadHealthKitData() -> Void {
        let readTypes = Set( actualTypes )
        
        healthStore.requestAuthorization(toShare: [], read: readTypes ) { ( result, error ) in
            if ( error == nil )
            {
                for readType in readTypes {
                    self.querySample( type: readType, for: 5 )
                }
            }
        }
    }
    
    @IBAction func viewStats() -> Void {
        MSAnalytics.trackEvent( "View Stats Tap" )
    }

}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay( for: self )
    }
    
    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date( byAdding: components, to: startOfDay )
    }
}
