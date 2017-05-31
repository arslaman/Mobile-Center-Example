//
//  MSAnalyticsService.swift
//  MobileCenterExample
//
//  Created by Ruslan Mansurov on 5/31/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import MobileCenter
import MobileCenterAnalytics

class MSAnalyticsService: AnalyticsService {
    
    init(settingsService: SettingsService) {
        MSMobileCenter.start( settingsService.mobileCenterAppSecret, withServices: [MSAnalytics.self] )
    }
    
    /**
     * Track Facebook login button click event
     */
    func trackLoginFacebookClick() {
        let properties = [
            "Page": "Login",
            "Category": "Clicks"
        ]
        MSAnalytics.trackEvent("Facebook login button clicked", withProperties: properties)
    }
    
    /**
     * Track Twitter login button click event
     */
    func trackLoginTwitterClick() {
        let properties = [
            "Page": "Login",
            "Category": "Clicks"
        ]
        MSAnalytics.trackEvent("Twitter login button clicked", withProperties: properties)
    }
    
    /**
     * Track social sign in request result event
     */
    func trackSocialSignInResult(socialNetwork: SocialNetwork, success: Bool, errorMessage: String?) {
        let properties = [
            "Page": "Login",
            "Category": "Request",
            "API": "Social network",
            "Social network": socialNetwork.rawValue,
            "Result": String(success),
            "Error message": errorMessage ?? ""
        ]
        MSAnalytics.trackEvent("Trying to login in Facebook/Twitter", withProperties: properties)
    }
    
    /**
     * Track HealthKit retrieve result event
     */
    func trackHealthKitRetrieveResult(success: Bool, errorMessage: String?) {
        let properties = [
            "Page": "Main",
            "Category": "Request",
            "API": "HealthKit",
            "Result": String(success),
            "Error message": errorMessage ?? ""
        ]
        MSAnalytics.trackEvent("Trying to retrieve data from HealthKit", withProperties: properties)
    }
    
    /**
     * Track statistics button click event
     */
    func trackStatisticsClick() {
        let properties = [
            "Page": "Main",
            "Category": "Clicks"
        ]
        MSAnalytics.trackEvent("View statistics button clicked", withProperties: properties)
    }
    
    /**
     * Track home button click event
     */
    func trackHomeClick() {
        let properties = [
            "Page": "Main",
            "Category": "Clicks"
        ]
        MSAnalytics.trackEvent("View home button clicked", withProperties: properties)
    }
    
    /**
     * Track crash button click event
     */
    func trackCrashClick() {
        let properties = [
            "Page": "Profile",
            "Category": "Clicks"
        ]
        MSAnalytics.trackEvent("Crash application button clicked", withProperties: properties)
    }
}
