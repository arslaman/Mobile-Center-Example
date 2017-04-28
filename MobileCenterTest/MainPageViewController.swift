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
    
    @IBOutlet var postButton: UIButton?
    
    var quantities = [String : Double]()
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
            postButton?.setTitle( "Post in " + user.socialNetwork.rawValue, for: UIControlState.normal )
        }
        for type in actualTypes {
            self.updateLabel(for: type)
        }
    }
    
    func updateLabel( for type: HKQuantityType ) -> Void {
        guard let label = labels[type.identifier] else {
            fatalError()
        }
        
        if let value = quantities[type.identifier] {
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
    
    func querySample( type: HKQuantityType ) -> Void {
        
        let endDate = Date()
        let startDate = NSCalendar.current.startOfDay(for: endDate )
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
                    fatalError()
                }
                
                let value = sumQuantity.doubleValue( for: unit )
                self.quantities[type.identifier] = value
                DispatchQueue.main.async {
                    self.sampleValueChanged(type: type)
                }
            }
        }
        
        self.healthStore.execute( statisticQuery )
    }
    
    func loadHealthKitData() -> Void {
        let readTypes = Set( actualTypes )
        
        healthStore.requestAuthorization(toShare: [], read: readTypes ) { ( result, error ) in
            if ( error == nil )
            {
                for readType in readTypes {
                    self.querySample( type: readType )
                }
            }
        }
    }
    
    @IBAction func viewStats() -> Void {
        MSAnalytics.trackEvent( "View Stats Tap" )
    }

    @IBAction func postInSocialNetwork() -> Void {
        MSAnalytics.trackEvent( "Post In Social Network Tap", withProperties: ["Social Network": self.user!.socialNetwork.rawValue] )
    }
}
