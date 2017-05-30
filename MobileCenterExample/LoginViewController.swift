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

import MobileCenterAnalytics
import MobileCenterCrashes

class LoginViewController: UIViewController {
    
    fileprivate var user: User?
    
    @IBOutlet var errorIcon: UIView?
    @IBOutlet var errorLabel1: UIView?
    @IBOutlet var errorLabel2: UIView?
    
    @IBOutlet var normalStateIcon1: UIView?
    @IBOutlet var normalStateIcon2: UIView?
    
    @IBOutlet var twitterLoginButton: UIButton?
    @IBOutlet var facebookLoginButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showMainPage() {
        self.performSegue(withIdentifier: "ShowMainPage", sender: self.user)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "ShowMainPage":
                (segue.destination as! MainTabBarController).user = self.user
            default:
                break
            }
        }
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
    
    func trackLoginResult(_ socialNetwork: String, success: Bool, errorMessage: String? ) {
        var params = ["Page": "Login",
                      "Category": "Result",
                      "Social network": socialNetwork,
                      "Result": success ? "true" : "false"
                      ]
        if !success {
            if let errorMessage = errorMessage {
                params["Error message"] = errorMessage
            }
        }
        MSAnalytics.trackEvent("Trying to login in \(socialNetwork)", withProperties: params)
    }
    
    @IBAction func loginViaTwitter() {
        setLoginButtons(enabled: false)
        
        MSAnalytics.trackEvent("Twitter login button clicked", withProperties: ["Page": "Login",
                                                                                "Category": "Clicks"])
        
        Twitter.sharedInstance().logIn(with: self, completion: {
            ( session, error ) in
            if let session = session {
                
                let twitterClient = TWTRAPIClient.withCurrentUser()
                guard let userId = twitterClient.userID else {
                    self.showErrorState()
                    self.trackLoginResult("Twitter", success: false, errorMessage: "Unknown error")
                    return
                }
                
                twitterClient.loadUser(withID: userId, completion: {
                    ( user, error ) in
                    if let user = user {
                        self.user = User(fullName: session.userName, accessToken: session.authToken, socialNetwork: SocialNetwork.Twitter, imageUrlString: user.profileImageLargeURL )
                        self.trackLoginResult("Twitter", success: true, errorMessage: nil)
                        self.showMainPage()
                    }
                    else {
                        if let error = error {
                            self.trackLoginResult("Twitter", success: false, errorMessage: error.localizedDescription)
                        }
                        else {
                            self.trackLoginResult("Twitter", success: false, errorMessage: "Unknown error")
                        }
                        self.showErrorState()
                    }
                })
            }
            else {
                if let error = error as NSError? {
                    if error.domain == TWTRLogInErrorDomain && error.code == TWTRLogInErrorCode.canceled.rawValue {
                        self.setLoginButtons(enabled: true)
                        return
                    }
                    print( "an error occured: ", error )
                    self.trackLoginResult("Twitter", success: false, errorMessage: error.localizedDescription)
                }
                else {
                    print( "unknown error occured" )
                    self.trackLoginResult("Twitter", success: false, errorMessage: "Unknown error")
                }
                self.showErrorState()
            }
        })
    }
    
    @IBAction func loginViaFacebook() {
        setLoginButtons(enabled: false)
        
        MSAnalytics.trackEvent("Facebook login button clicked", withProperties: ["Page": "Login",
                                                                                 "Category": "Clicks"])
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: [], from: self, handler: { ( loginResult, error ) in
            if let error = error {
                self.trackLoginResult("Facebook", success: false, errorMessage: error.localizedDescription)
                print( "an error occured: ", error )
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
                                self.trackLoginResult("Facebook", success: true, errorMessage: nil)
                                self.showMainPage()
                            }
                            else {
                                if let error = error {
                                    self.trackLoginResult("Facebook", success: false, errorMessage: error.localizedDescription)
                                    print( "an error occured: ", error )
                                }
                                else {
                                    self.trackLoginResult("Facebook", success: false, errorMessage: "Unknown error")
                                    print( "unknown error occured" )
                                }
                                self.showErrorState()
                            }
                        })
                    }
                }
            }
        })
    }
}

