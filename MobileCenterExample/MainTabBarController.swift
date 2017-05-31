//
//  MainTabBarController.swift
//  MobileCenterExample
//
//  Created by nypreHeB on 10.05.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit
import HealthKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    fileprivate var analyticsService: AnalyticsService?
    
    var healthStore = HKHealthStore()
    var userStats = TimedData<UserStats>()
    var operationsCounter = Int()
    var needGenerateData = [Int: Bool]()
    var triedToGenerateData = false
    
    
    let actualTypes = [HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                       HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                       HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!]
    
    open var user: User? {
        didSet {
            (self.childViewControllers.first as! ProfilePageViewController).user = user
        }
    }
    
    func configure(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear( animated )
        if !triedToGenerateData {
            triedToGenerateData = false
            self.checkNeedGenerateHealthKitData()
        }
    }
    
    func updateContent() {
        (self.childViewControllers.first as! ProfilePageViewController).userStats = userStats
        (self.childViewControllers.last as! StatisticsViewController).userStats = userStats
    }
    
    func increaseOperationsCounter() -> Void {
        objc_sync_enter( operationsCounter )
        operationsCounter += 1
        objc_sync_exit( operationsCounter )
    }
    
    func decreaseOperationsCounter() -> Void {
        objc_sync_enter( operationsCounter )
        operationsCounter -= 1
        if operationsCounter == 0 {
            
            var needGenerate = false
            for (_, value) in needGenerateData {
                if ( value ) {
                    needGenerate = true
                    break
                }
            }
            
            if needGenerate {
                fillRandomData()
            }
            else {
                DispatchQueue.main.async() {
                    self.updateContent()
                    }
            }
            
        }
        objc_sync_exit( operationsCounter )
    }
    
    func querySample( _ type: HKQuantityType, for days: Int ) -> Void {
        
        increaseOperationsCounter()
        
        let calendar = Calendar.current
        var interval = DateComponents()
        interval.day = 1
        
        guard let anchorDate = Date().endOfDay else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
        
        let query = HKStatisticsCollectionQuery(quantityType: type,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
            }
            
            var startDateComponents = DateComponents()
            startDateComponents.day = -days
            guard let startDate = calendar.date( byAdding: startDateComponents, to: anchorDate )?.startOfDay else {
                fatalError()
            }
            
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
            
            statsCollection.enumerateStatistics(from: startDate, to: anchorDate, with:{
                ( statistics, stop ) in
                if let quantity = statistics.sumQuantity() {
                    
                    let date = statistics.startDate
                    let value = quantity.doubleValue( for: unit )
                    
                    let difference = calendar.dateComponents( [.day, .hour], from: startDate, to: date )
                    guard let day = difference.day else {
                        fatalError()
                    }
                    let dayIndex = days - day - 1
                    self.needGenerateData[dayIndex] = false
                    
                    self.writeHealthKitData( for: dayIndex, and: type, value: value )
                }
            })
            
            self.decreaseOperationsCounter()
        }
        
        healthStore.execute( query )
    }
    
    func loadHealthKitData() -> Void {
        let readTypes = Set( actualTypes )
        
        healthStore.requestAuthorization(toShare: [], read: readTypes ) { ( result, error ) in
            if ( error == nil )
            {
                for readType in readTypes {
                    self.querySample( readType, for: 5 )
                }
            }
        }
    }
    
    func writeHealthKitData( for day: Int, and type: HKQuantityType, value: Double ) -> Void {
        self.userStats.getOrCreate(for: day)[type.identifier] = value
    }
    
    
    func generateRandomSample( _ from: Date, to: Date, identifier: HKQuantityTypeIdentifier ) -> HKQuantitySample {
        var unit: HKUnit
        switch identifier {
        case HKQuantityTypeIdentifier.stepCount:
            unit = HKUnit.count()
        case HKQuantityTypeIdentifier.distanceWalkingRunning:
            unit = HKUnit.meterUnit(with: HKMetricPrefix.kilo)
        case HKQuantityTypeIdentifier.activeEnergyBurned:
            unit = HKUnit.kilocalorie()
        case HKQuantityTypeIdentifier.appleExerciseTime:
            unit = HKUnit.minute()
        default:
            fatalError()
        }
        
        let value = (0...60).random()
        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let type = HKSampleType.quantityType(forIdentifier: identifier)!
        
        let sample = HKQuantitySample(type: type, quantity: quantity, start: from, end: to)
        
        return sample
    }
    
    func fillRandomData() {
        var days = [Int]()
        for (day, value) in needGenerateData {
            if ( value ) {
                days.append(day)
            }
        }
        if ( days.count == 0 ) {
            return;
        }
        
        needGenerateData.removeAll()
        
        let now = Date()
        let calendar = Calendar.current
        var samples = [HKQuantitySample]()
        
        for day in days {
            let hoursDiff = day * 24
            for hour in 0...24  {
                let endDate = calendar.date(byAdding: .hour, value: -hour - hoursDiff, to: now)!
                let startDate = calendar.date(byAdding: .hour, value: -hour - 1 - hoursDiff, to: now)!
                
                samples.append(generateRandomSample(startDate, to: endDate, identifier: HKQuantityTypeIdentifier.stepCount))
                samples.append(generateRandomSample(startDate, to: endDate, identifier: HKQuantityTypeIdentifier.distanceWalkingRunning))
                samples.append(generateRandomSample(startDate, to: endDate, identifier: HKQuantityTypeIdentifier.activeEnergyBurned))
            }
        }

        healthStore.save( samples ) { ( completed, error ) in
            if let error = error {
                print( "error: ", error )
            }
            else {
                self.loadHealthKitData()
            }
        }
    }
    
    func checkNeedGenerateHealthKitData() {
        var readTypes = Set<HKQuantityType>()
        var writeTypes = Set<HKSampleType>()
        
        writeTypes.insert( HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)! )
        writeTypes.insert( HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)! )
        writeTypes.insert( HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)! )
        
        readTypes.insert( HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)! )
        readTypes.insert( HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)! )
        readTypes.insert( HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)! )
        readTypes.insert( HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)! )
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            for i in 0...4 {
                needGenerateData[i] = true
            }
        #endif
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { ( success, error ) in
            self.analyticsService?.trackHealthKitRetrieveResult(success: success, errorMessage: error?.localizedDescription)
            if ( success ) {
                self.loadHealthKitData()
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let _ = viewController as? ProfilePageViewController {
            self.analyticsService?.trackHomeClick()
        } else {
            self.analyticsService?.trackStatisticsClick()
        }
    }
}
