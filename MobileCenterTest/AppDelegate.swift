//
//  AppDelegate.swift
//  MobileCenterTest
//
//  Created by Insaf Safin on 24.04.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

import MobileCenter
import MobileCenterAnalytics
import MobileCenterCrashes

import Fabric
import TwitterKit

import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
   
        let mobileCenterAppSecretKey = "MSMobileCenterAppSecret"
        
        let twitterConsumerKey = "TwitterConsumerKey"
        let twitterConsumerSecret = "TwitterConsumerSecret"
        
        
        Fabric.with( [Twitter.self] )
        
        if let path = Bundle.main.path(forResource: "AppConfig", ofType: "plist") {
            let url = URL(fileURLWithPath: path)
            if let data = try? Data(contentsOf: url) {
                if let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) {
                    let configDict = plist as! [String:String]
                    
                    MSMobileCenter.start( configDict[mobileCenterAppSecretKey], withServices: [MSAnalytics.self, MSCrashes.self] )
                    
                    if let consumerKey = configDict[twitterConsumerKey],
                        let consumerSecret = configDict[twitterConsumerSecret] {
                        Twitter.sharedInstance().start( withConsumerKey: consumerKey, consumerSecret: consumerSecret )
                    }
                }
            }
        }
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

