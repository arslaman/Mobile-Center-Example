//
//  MainTabBarController.swift
//  MobileCenterExample
//
//  Created by nypreHeB on 10.05.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit
import HealthKit

class MainTabBarController: UITabBarController {

    var healthStore = HKHealthStore()
    var userStats = TimedData<UserStats>()
    var operationsCounter = Int()
    
    let actualTypes = [HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                       HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                       HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!]
    
    public var user: User? {
        didSet {
            (self.childViewControllers.first as! ProfilePageViewController).user = user
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear( animated )
        self.checkNeedGenerateHealthKitData()
    }
    
    func updateContent() {
        
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
            updateContent()
        }
        objc_sync_exit( operationsCounter )
    }
    
    func querySample( type: HKQuantityType, for days: Int ) -> Void {
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
            guard let startDate = calendar.date( byAdding: startDateComponents, to: anchorDate ) else {
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
                    
                    self.writeHealthKitData( for: dayIndex, and: type, value: value )
                }
            })
            
//            DispatchQueue.main.async {
//                self.sampleValueChanged(type: type)
//            }
        }
        
        healthStore.execute( query )
    }
    
    func loadHealthKitData() -> Void {
        let readTypes = Set( actualTypes )
        
        healthStore.requestAuthorization(toShare: [], read: readTypes ) { ( result, error ) in
            if ( error == nil )
            {
                for readType in readTypes {
                    self.querySample( type: readType, for: 1 )
                }
            }
        }
    }
    
    func writeHealthKitData( for day: Int, and type: HKQuantityType, value: Double ) -> Void {
        self.userStats.getOrCreate(for: day)[type.identifier] = value
    }
    
    
    func writeRandomData( from: Date, to: Date, identifier: HKQuantityTypeIdentifier ) {
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
        
        healthStore.save( sample ) { ( completed, error ) in
            if let error = error {
                print(["error: ", error] )
            }
        }
    }
    
    func fillRandomData( days: Int ) {
        let now = Date()
        let calendar = NSCalendar.current
        
        for hour in 0...24 * days {
            let endDate = calendar.date(byAdding: .hour, value: -hour, to: now)!
            let startDate = calendar.date(byAdding: .hour, value: -hour - 1, to: now)!
            
            
            writeRandomData(from: startDate, to: endDate, identifier: HKQuantityTypeIdentifier.stepCount)
            writeRandomData(from: startDate, to: endDate, identifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
            writeRandomData(from: startDate, to: endDate, identifier: HKQuantityTypeIdentifier.activeEnergyBurned)
            writeRandomData(from: startDate, to: endDate, identifier: HKQuantityTypeIdentifier.appleExerciseTime)
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
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { ( success, error ) in
            if ( success ) {
                //                self.healthStore.preferredUnits(for: [HKQuantityType.quantityType(forIdentifier:HKQuantityTypeIdentifier.distanceWalkingRunning)!]) { ( result, error ) in
                //                    print( result )
                //                    print( error )
                //                }
                
                //                self.fillRandomData( days: 5 )
            }
        }
    }
}
