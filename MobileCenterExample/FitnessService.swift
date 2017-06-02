//
//  FitnessService.swift
//  MobileCenterExample
//
//  Created by Ruslan Mansurov on 6/1/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import HealthKit

typealias FitnessDataCompletion = (TimedData<FitnessDailyData>?, Error?) -> Void
typealias FitnessAuthorizationCompletion = (Bool, Error?) -> Void

enum FitnessType: Int {
    case Steps
    case Calories
    case Distance
    case ActiveTime
}

protocol FitnessService {
    var  userStats: TimedData<FitnessDailyData> { get }
    func requestAuthorization(completion: @escaping FitnessAuthorizationCompletion)
    func loadHealthKitData(days: Int, completion: @escaping FitnessDataCompletion)
}

class HealthKitFitnessService: FitnessService {
    var healthStore = HKHealthStore()
    var userStats = TimedData<FitnessDailyData>()
    var operationsCounter = Int()
    var dataCompletion: FitnessDataCompletion?
    var error: Error?
    
    var fitnessTypes: Set<HKQuantityType> {
        var types = Set<HKQuantityType>()
        types.insert( HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)! )
        types.insert( HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)! )
        types.insert( HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)! )
        types.insert( HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)! )
        
        return types
    }
    
    func requestAuthorization(completion: @escaping FitnessAuthorizationCompletion) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: fitnessTypes) { ( success, error ) in
            completion(success, error)
        }
    }
    
    func loadHealthKitData(days: Int, completion: @escaping FitnessDataCompletion) {
        dataCompletion = completion
        for type in fitnessTypes {
            self.querySample(type, for: days)
        }
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
            dataFetchCompleted(error: nil)
        }
        objc_sync_exit( operationsCounter )
    }
    
    func dataFetchCompleted(error: Error?) {
        DispatchQueue.main.async() {
            if let completion = self.dataCompletion {
                completion(self.userStats, error)
            }
            self.dataCompletion = nil
        }
    }

    func querySample( _ type: HKQuantityType, for days: Int ) -> Void {
        
        increaseOperationsCounter()
        
        var interval = DateComponents()
        interval.day = 1
        
        let anchorDate = Date().startOfDay
        let startDate = anchorDate.daysAgo(days: days)
        
        let query = HKStatisticsCollectionQuery(quantityType: type,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = { query, results, error in
            
            guard let statsCollection = results else {
                self.dataFetchCompleted(error: error)
                return
            }
            
            let unit = self.unitFromQuantityType(type)
            
            statsCollection.enumerateStatistics(from: startDate, to: anchorDate) { ( statistics, stop ) in
                if let quantity = statistics.sumQuantity() {
                    
                    let date = statistics.startDate
                    let value = quantity.doubleValue( for: unit )
                    
                    self.writeHealthKitData( forDate: date, and: type, value: value )
                }
            }
            
            self.decreaseOperationsCounter()
        }
        
        healthStore.execute( query )
    }
    
    func unitFromQuantityType(_ type: HKQuantityType) -> HKUnit {
        var unit: HKUnit
        switch type.identifier {
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            unit = HKUnit.count()
        case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
            unit = HKUnit.meterUnit(with: HKMetricPrefix.kilo)
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
            unit = HKUnit.kilocalorie()
        case HKQuantityTypeIdentifier.appleExerciseTime.rawValue:
            unit = HKUnit.minute()
        default:
            fatalError( "unsupported HKQuantityTypeIdentifier" )
        }
        return unit
    }
    
    func writeHealthKitData( forDate date: Date, and type: HKQuantityType, value: Double ) -> Void {
        let fitnessDaylyData = self.userStats.getOrCreate(for: date)
        
        switch type.identifier {
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            fitnessDaylyData.stepsCount = Int(value)
        case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
            fitnessDaylyData.distanceInKM = value
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
            fitnessDaylyData.calories = value
        case HKQuantityTypeIdentifier.appleExerciseTime.rawValue:
            fitnessDaylyData.activeTimeInMinutes = value
        default:
            fatalError( "unsupported HKQuantityTypeIdentifier" )
        }
    }
    
}
