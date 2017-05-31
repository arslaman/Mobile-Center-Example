//
//  AnalyticsService.swift
//  MobileCenterExample
//
//  Created by Ruslan Mansurov on 5/30/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

protocol AnalyticsService {
    /**
     * Track Facebook login button click event
     */
    func trackLoginFacebookClick()
    
    /**
     * Track Twitter login button click event
     */
    func trackLoginTwitterClick()
    
    /**
     * Track social sign in request result event
     */
    func trackSocialSignInResult(socialNetwork: SocialNetwork, success: Bool, errorMessage: String?)
    
    /**
     * Track HealthKit retrieve result event
     */
    func trackHealthKitRetrieveResult(success: Bool, errorMessage: String?)
    
    /**
     * Track statistics button click event
     */
    func trackStatisticsClick()
    
    /**
     * Track home button click event
     */
    func trackHomeClick()
    
    /**
     * Track crash button click event
     */
    func trackCrashClick()
}
