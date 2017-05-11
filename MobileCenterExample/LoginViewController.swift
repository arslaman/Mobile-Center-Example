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
    
    private var user: User?
    
    @IBOutlet var errorIcon: UIView?
    @IBOutlet var errorLabel1: UIView?
    @IBOutlet var errorLabel2: UIView?
    
    @IBOutlet var normalStateIcon1: UIView?
    @IBOutlet var normalStateIcon2: UIView?
    
    @IBOutlet var twitterLoginButton: UIButton?
    @IBOutlet var facebookLoginButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let wasCrashed = MSCrashes.hasCrashedInLastSession()
//        
//        if  wasCrashed {
//            
//        }
//        
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
    
    @IBAction func loginViaTwitter() {
        setLoginButtons(enabled: false)
        
        Twitter.sharedInstance().logIn(with: self, completion: {
            ( session, error ) in
            if let session = session {
                
                let twitterClient = TWTRAPIClient.withCurrentUser()
                guard let userId = twitterClient.userID else {
                    self.showErrorState()
                    return
                }
                
                twitterClient.loadUser(withID: userId, completion: {
                    ( user, error ) in
                    if let user = user {
                        self.user = User(fullName: session.userName, accessToken: session.authToken, socialNetwork: SocialNetwork.Twitter, imageUrlString: user.profileImageLargeURL )
                        self.showMainPage()
                    }
                    else {
                        self.showErrorState()
                    }
                })
            }
            else {
                if let error = error as? NSError {
                    if error.domain == TWTRLogInErrorDomain && error.code == TWTRLogInErrorCode.canceled.rawValue {
                        self.setLoginButtons(enabled: true)
                        return
                    }
                    print( "an error occured: ", error )
                }
                else {
                    print( "unknown error occured" )
                }
                self.showErrorState()
            }
        })
    }
    
    @IBAction func loginViaFacebook() {
        setLoginButtons(enabled: false)
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: [], from: self, handler: { ( loginResult, error ) in
            if let error = error {
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
                                self.showMainPage()
                            }
                            else {
                                if let error = error {
                                    print( "an error occured: ", error )
                                }
                                else {
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

