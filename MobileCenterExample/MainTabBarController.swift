//
//  MainTabBarController.swift
//  MobileCenterExample
//
//  Created by nypreHeB on 10.05.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    fileprivate var analyticsService: AnalyticsService?
    fileprivate var fitnessService: FitnessService?
    
    var fitnessData: TimedData<FitnessDailyData>?
    
    func configure(analyticsService: AnalyticsService, fitnessService: FitnessService) {
        self.analyticsService = analyticsService
        self.fitnessService = fitnessService
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear( animated )
        self.fitnessService?.requestAuthorization() { (success, errror) in
            if success {
                self.fitnessService?.loadHealthKitData(days: 4) { (data, error) in
                    if let data = data {
                        self.fitnessData = data
                        self.updateContent()
                    }
                }
            }
        }
    }
    
    func updateContent() {
        (self.childViewControllers.first as! ProfilePageViewController).fitnessData = fitnessData
        (self.childViewControllers.last as! StatisticsViewController).fitnessData = fitnessData
    }
    
}

// MARK - UITabBarControllerDelegate
extension MainTabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let _ = viewController as? ProfilePageViewController {
            self.analyticsService?.trackHomeClick()
        } else {
            self.analyticsService?.trackStatisticsClick()
        }
    }
}
