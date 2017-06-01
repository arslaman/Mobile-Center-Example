//
//  ViewController.swift
//  MobileCenterExample
//
//  Created by Insaf Safin on 24.04.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    fileprivate var routing: Routing?
    fileprivate var analyticsService: AnalyticsService?
    fileprivate var twitterService: SocialService?
    fileprivate var facebookService: SocialService?
    
    @IBOutlet var errorIcon: UIView?
    @IBOutlet var errorLabel1: UIView?
    @IBOutlet var errorLabel2: UIView?
    
    @IBOutlet var normalStateIcon1: UIView?
    @IBOutlet var normalStateIcon2: UIView?
    
    @IBOutlet var twitterLoginButton: UIButton?
    @IBOutlet var facebookLoginButton: UIButton?
    
    func configure(routing: Routing,
                   analyticsService: AnalyticsService,
                   twitterService: SocialService,
                   facebookService: SocialService) {
        
        self.routing = routing
        self.analyticsService = analyticsService
        self.twitterService = twitterService
        self.facebookService = facebookService
    }
    
    func showMainPage(user: User) {
        routing?.presentMainController(user: user)
    }
    
    func showErrorState() {
        UIView.animate(withDuration: 0.2, animations: { 
            self.errorIcon?.alpha = 1
            self.errorLabel1?.alpha = 1
            self.errorLabel2?.alpha = 1
            
            self.normalStateIcon1?.alpha = 0
            self.normalStateIcon2?.alpha = 0
        }) { (completed) in
            self.setLoginButtons(enabled: true)
        }
    }
    
    func setLoginButtons( enabled: Bool ) {
        self.twitterLoginButton?.isEnabled = enabled
        self.facebookLoginButton?.isEnabled = enabled
    }
    
    @IBAction func loginViaTwitter() {
        // track click event
        analyticsService?.trackLoginTwitterClick()
        
        // disable buttons to prevent clicks while authenticating
        setLoginButtons(enabled: false)
        
        socialLogIn(.Twitter)
    }
    
    @IBAction func loginViaFacebook() {
        // track click event
        analyticsService?.trackLoginFacebookClick()
        
        // disable buttons to prevent clicks while authenticating
        setLoginButtons(enabled: false)
        
        socialLogIn(.Facebook)
    }
    
    func socialLogIn(_ socialNetwork: SocialNetwork) {
        let completion: SocialLogInCompletion = { (user, error) in
            // it's time to enable buttons back
            self.setLoginButtons(enabled: true)
            
            // if user is nil, then there were some problems
            guard let myUser = user else {
                self.analyticsService?.trackSocialSignInResult(socialNetwork: socialNetwork, success: false, errorMessage: error?.localizedDescription)
                self.showErrorState()
                return
            }
            
            self.analyticsService?.trackSocialSignInResult(socialNetwork: socialNetwork, success: true, errorMessage: nil)
            
            // proceed to main screen
            self.showMainPage(user: myUser)
        }
        
        switch socialNetwork {
        case .Facebook:
            facebookService?.logIn(with: self, completion: completion)
        case .Twitter:
            twitterService?.logIn(with: self, completion: completion)
        }
    }
}

