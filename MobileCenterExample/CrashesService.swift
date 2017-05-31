//
//  CrashesService.swift
//  MobileCenterExample
//
//  Created by Ruslan Mansurov on 5/31/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import MobileCenter
import MobileCenterCrashes

protocol CrashesService {
    func generateTestCrash()
}

class MCCrashesService: CrashesService {
    
    init() {
        MSMobileCenter.startService( MSCrashes.self )
    }
    
    func generateTestCrash() {
        MSCrashes.generateTestCrash()
    }
}
