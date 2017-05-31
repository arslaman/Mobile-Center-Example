//
//  Routing.swift
//  MobileCenterExample
//
//  Created by Ruslan Mansurov on 5/31/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import UIKit

class Routing {
    var services: ServicesFactory
    var window: UIWindow!
    
    var mainStoryboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    init(servicesFactory: ServicesFactory) {
        services = servicesFactory
    }
    
    func installToWindow(_ window: UIWindow) {
        self.window = window
        
        presentLoginController()
    }
    
    func presentLoginController() {
        window.rootViewController = loginController()
    }
    
    func presentMainController(user: User) {
        let controller = mainController()
        controller.viewControllers = [profileController(), statisticsController()]
        
        window.rootViewController?.present(controller, animated: true, completion: nil)
    }
    
    func loginController() -> LoginViewController {
        let loginController = mainStoryboard.instantiateInitialViewController() as! LoginViewController
        loginController.configure(routing: self, analyticsService: services.analyticsService)
        
        return loginController;
    }
    
    func mainController() -> MainTabBarController {
        let identifier = String(describing: MainTabBarController.self)
        let controller = mainStoryboard.instantiateViewController(withIdentifier: identifier) as! MainTabBarController
        
        return controller;
    }
    
    func profileController() -> ProfilePageViewController {
        let identifier = String(describing: ProfilePageViewController.self)
        let controller = mainStoryboard.instantiateViewController(withIdentifier: identifier) as! ProfilePageViewController
        
        return controller;
    }
    
    func statisticsController() -> StatisticsViewController {
        let identifier = String(describing: StatisticsViewController.self)
        let controller = mainStoryboard.instantiateViewController(withIdentifier: identifier) as! StatisticsViewController
        
        return controller;
    }
}
