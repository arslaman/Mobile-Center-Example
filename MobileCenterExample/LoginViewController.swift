//
//  ViewController.swift
//  MobileCenterExample
//
//  Created by Insaf Safin on 24.04.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

import HealthKit

import TwitterKit
import FBSDKLoginKit

import MobileCenterCrashes

class LoginViewController: UIViewController {
    
    fileprivate var routing: Routing?
    fileprivate var analyticsService: AnalyticsService?
    fileprivate var twitterService: SocialService?
    
    @IBOutlet var errorIcon: UIView?
    @IBOutlet var errorLabel1: UIView?
    @IBOutlet var errorLabel2: UIView?
    
    @IBOutlet var normalStateIcon1: UIView?
    @IBOutlet var normalStateIcon2: UIView?
    
    @IBOutlet var twitterLoginButton: UIButton?
    @IBOutlet var facebookLoginButton: UIButton?
    
    func configure(routing: Routing, analyticsService: AnalyticsService, twitterService: SocialService) {
        self.routing = routing
        self.analyticsService = analyticsService
        self.twitterService = twitterService
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func trackSignInResult(socialNetwork: SocialNetwork, success: Bool, errorMessage: String? ) {
        var errorMessage = errorMessage
        if !success {
            errorMessage = errorMessage ?? "Unknown error"
        }
        self.analyticsService?.trackSocialSignInResult(socialNetwork: socialNetwork, success: success, errorMessage: errorMessage)
    }
    
    @IBAction func loginViaTwitter() {
        // track click event
        analyticsService?.trackLoginTwitterClick()
        
        // disable buttons to prevent clicks while authenticating
        setLoginButtons(enabled: false)
        
        self.twitterService?.logIn(with: self, completion: { (user, error) in
            // it's time to enable buttons back
            self.setLoginButtons(enabled: true)
            
            // if user is nil, then there were some problems
            guard let myUser = user else {
                self.trackSignInResult(socialNetwork: .Twitter, success: false, errorMessage: error?.localizedDescription)
                self.showErrorState()
                return
            }
            
            self.analyticsService?.trackSocialSignInResult(socialNetwork: .Twitter, success: true, errorMessage: nil)
            
            // proceed to main screen
            self.showMainPage(user: myUser)
        })
    }
    
    @IBAction func loginViaFacebook() {
        // track click event
        analyticsService?.trackLoginFacebookClick()
        
        // disable log in buttons to prevent clicks while authenticating
        setLoginButtons(enabled: false)
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: [], from: self, handler: { ( loginResult, error ) in
            if let error = error {
                self.trackSignInResult(socialNetwork: .Facebook, success: false, errorMessage: error.localizedDescription)
                self.showErrorState()
            }
            else {
                if let loginResult = loginResult {
                    if loginResult.isCancelled {
                        self.setLoginButtons(enabled: true)
                    }
                    else {
                        FBSDKProfile.loadCurrentProfile(completion: { (profile, error) in
                            if let profile = profile {
                                let myUser = User(fullName: profile.name, accessToken: loginResult.token.tokenString, socialNetwork: SocialNetwork.Facebook, imageUrlString: profile.imageURL(for: .square, size: CGSize(width: 100, height: 100 )).absoluteString)
                                self.trackSignInResult(socialNetwork: .Facebook, success: true, errorMessage: nil)
                                self.showMainPage(user: myUser)
                            }
                            else {
                                self.trackSignInResult(socialNetwork: .Facebook, success: false, errorMessage: error?.localizedDescription)
                                self.showErrorState()
                            }
                        })
                    }
                }
            }
        })
    }
}

