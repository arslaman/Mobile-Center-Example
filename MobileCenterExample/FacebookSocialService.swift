//
//  FacebookSocialService.swift
//  MobileCenterExample
//
//  Created by Ruslan Mansurov on 6/1/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

import FBSDKCoreKit
import FBSDKLoginKit

class FacebookSocialService: SocialService {
    
    /**
     Call this method from the [UIApplicationDelegate application:didFinishLaunchingWithOptions:] method
     of the AppDelegate for your app. It should be invoked for the proper use of the Facebook SDK.
     As part of SDK initialization basic auto logging of app events will occur, this can be
     controlled via 'FacebookAutoLogAppEventsEnabled' key in the project info plist file.
     
     - Parameter application: The application as passed to [UIApplicationDelegate application:didFinishLaunchingWithOptions:].
     
     - Parameter launchOptions: The launchOptions as passed to [UIApplicationDelegate application:didFinishLaunchingWithOptions:].
     
     - Returns: YES if the url was intended for the Facebook SDK, NO if not.
     */
    @discardableResult func application(_ application: UIApplication!, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any]! = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /**
     Call this method from the [UIApplicationDelegate application:openURL:options:] method
     of the AppDelegate for your app. It should be invoked for the proper processing of responses during interaction
     with the native Facebook app or Safari as part of SSO authorization flow or Facebook dialogs.
     
     - Parameter application: The application as passed to [UIApplicationDelegate application:openURL:options:].
     
     - Parameter url: The URL as passed to [UIApplicationDelegate application:openURL:options:].
     
     - Parameter options: The options dictionary as passed to [UIApplicationDelegate application:openURL:options:].
     
     - Returns: YES if the url was intended for the Facebook SDK, NO if not.
     */
    func application(_ application: UIApplication!, open url: URL!, options: [UIApplicationOpenURLOptionsKey : Any]! = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, options: options)
    }
    
    func logIn(with viewController: UIViewController, completion: @escaping SocialLogInCompletion) {
        
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: [], from: viewController) { ( loginResult, error ) in
            
            guard let loginResult = loginResult, let token = loginResult.token else {
                completion(nil, error)
                return
            }
            
            FBSDKProfile.loadCurrentProfile(completion: { (profile, error) in
                var myUser: User?
                if let profile = profile {
                    myUser = User(fullName: profile.name,
                                  accessToken: token.tokenString,
                                  socialNetwork: SocialNetwork.Facebook,
                                  imageUrlString: profile.imageURL(for: .square, size: CGSize(width: 100, height: 100 )).absoluteString
                    )
                }
                completion(myUser, error)
            })
        }
    }
}
