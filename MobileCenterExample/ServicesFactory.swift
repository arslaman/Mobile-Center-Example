//
//  ServicesFactory.swift
//  MobileCenterExample
//
//  Created by Ruslan Mansurov on 5/31/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

class ServicesFactory {
    
    lazy var analyticsService: AnalyticsService = {
        return MSAnalyticsService(settingsService: self.settingsService)
    }()
    
    lazy var crashesService: CrashesService = MCCrashesService()
    
    lazy var twitterService: SocialService = {
        return TwitterSocialService(settingsService: self.settingsService)
    }()
    
    lazy var facebookService: SocialService = FacebookSocialService()
    
    lazy var fitnessService: FitnessService = HealthKitFitnessService()
    
    lazy var settingsService: SettingsService = MCSettingsService()
}
