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
    
    fileprivate var user: User?
    fileprivate var routing: Routing?
    fileprivate var analyticsService: AnalyticsService?
    
    @IBOutlet var errorIcon: UIView?
    @IBOutlet var errorLabel1: UIView?
    @IBOutlet var errorLabel2: UIView?
    
    @IBOutlet var normalStateIcon1: UIView?
    @IBOutlet var normalStateIcon2: UIView?
    
    @IBOutlet var twitterLoginButton: UIButton?
    @IBOutlet var facebookLoginButton: UIButton?
    
    func configure(routing: Routing, analyticsService: AnalyticsService) {
        self.routing = routing
        self.analyticsService = analyticsService
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showMainPage() {
        routing?.presentMainController(user: user!)
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
        
        // disable log in buttons to prevent clicks while authenticating
        setLoginButtons(enabled: false)
        
        Twitter.sharedInstance().logIn(with: self, completion: {
            ( session, error ) in
            if let session = session {
                
                let twitterClient = TWTRAPIClient.withCurrentUser()
                guard let userId = twitterClient.userID else {
                    self.showErrorState()
                    self.trackSignInResult(socialNetwork: .Twitter, success: false, errorMessage: nil)
                    return
                }
                
                twitterClient.loadUser(withID: userId, completion: {
                    ( user, error ) in
                    if let user = user {
                        self.user = User(fullName: session.userName, accessToken: session.authToken, socialNetwork: SocialNetwork.Twitter, imageUrlString: user.profileImageLargeURL )
                        self.analyticsService?.trackSocialSignInResult(socialNetwork: .Twitter, success: true, errorMessage: nil)
                        self.showMainPage()
                    }
                    else {
                        self.trackSignInResult(socialNetwork: .Twitter, success: false, errorMessage: error?.localizedDescription)
                        self.showErrorState()
                    }
                })
            }
            else {
                self.trackSignInResult(socialNetwork: .Twitter, success: false, errorMessage: error?.localizedDescription)
                
                if let error = error as NSError? {
                    if error.domain == TWTRLogInErrorDomain && error.code == TWTRLogInErrorCode.canceled.rawValue {
                        self.setLoginButtons(enabled: true)
                        return
                    }
                    print( "an error occured: ", error )
                }
                self.showErrorState()
            }
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
                                self.user = User(fullName: profile.name, accessToken: loginResult.token.tokenString, socialNetwork: SocialNetwork.Facebook, imageUrlString: profile.imageURL(for: .square, size: CGSize(width: 100, height: 100 )).absoluteString)
                                self.trackSignInResult(socialNetwork: .Facebook, success: true, errorMessage: nil)
                                self.showMainPage()
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

