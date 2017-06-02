//
//  FitnessDailyData.swift
//  MobileCenterExample
//
//  Created by Ruslan Mansurov on 6/1/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

class FitnessDailyData: Initable {
    var stepsCount: Int = 0
    var distanceInKM: Double = 0.0
    var calories: Double = 0.0
    var activeTimeInMinutes: Double = 0.0
    private(set) public var date: Date
    
    required init(date: Date) {
        self.date = date
    }
}
