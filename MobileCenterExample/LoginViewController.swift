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


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet var twitterButton: TWTRLogInButton!
    @IBOutlet var facebookButton: FBSDKLoginButton!
    
    private var user: User?
    
    let healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        twitterButton.addTarget( self, action: #selector(LoginViewController.onTwitterTap), for: UIControlEvents.touchUpInside )
        twitterButton.logInCompletion = { session, error in
            if let session = session {
                self.user = User(fullName: session.userName, accessToken: session.authToken, socialNetwork: SocialNetwork.Twitter )
                self.showMainPage()
            }
        }
        
        facebookButton.delegate = self;
//        
//        let wasCrashed = MSCrashes.hasCrashedInLastSession()
//        
//        if  wasCrashed {
//            
//        }
//        
        self.checkNeedGenerateHealthKitData()
    }

    func onTwitterTap() {
        MSAnalytics.trackEvent( "Login Button Tap", withProperties: ["Social Network": "Twitter"] )
    }

    func onFacebookTap() {
        MSAnalytics.trackEvent( "Login Button Tap", withProperties: ["Social Network": "Facebook"] )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        self.onFacebookTap()
        return true
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print( ["an error occured: ", error] )
        }
        else {
            FBSDKProfile.loadCurrentProfile(completion: { (profile, error) in
                if let profile = profile {
                    self.user = User(fullName: profile.name, accessToken: result.token.tokenString, socialNetwork: SocialNetwork.Facebook )
                    self.showMainPage()
                }
                else {
                    if let error = error {
                        print( ["an error occured: ", error] )
                    }
                    else {
                        print( "unknown error occured" )
                    }
                }
            })
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func showMainPage() {
        self.performSegue(withIdentifier: "ShowMainPage", sender: self.user)
    }

    func writeRandomData( from: Date, to: Date, identifier: HKQuantityTypeIdentifier ) {
        var unit: HKUnit
        switch identifier {
        case HKQuantityTypeIdentifier.stepCount:
            unit = HKUnit.count()
        case HKQuantityTypeIdentifier.distanceWalkingRunning:
            unit = HKUnit.meterUnit(with: HKMetricPrefix.kilo)
        case HKQuantityTypeIdentifier.activeEnergyBurned:
            unit = HKUnit.kilocalorie()
        default:
            fatalError()
        }
        
        let value = (0...100).random()
        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let type = HKSampleType.quantityType(forIdentifier: identifier)!
        
        let sample = HKQuantitySample(type: type, quantity: quantity, start: from, end: to)
        
        healthStore.save( sample ) { ( completed, error ) in
            if let error = error {
                print(["error: ", error] )
            }
        }
    }
    
    func fillRandomData( days: Int ) {
        let now = Date()
        let calendar = NSCalendar.current
        
        for hour in 0...24 * days {
            let endDate = calendar.date(byAdding: .hour, value: -hour, to: now)!
            let startDate = calendar.date(byAdding: .hour, value: -hour - 1, to: now)!
            
            
            writeRandomData(from: startDate, to: endDate, identifier: HKQuantityTypeIdentifier.stepCount)
            writeRandomData(from: startDate, to: endDate, identifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
            writeRandomData(from: startDate, to: endDate, identifier: HKQuantityTypeIdentifier.activeEnergyBurned)
        }
    }
    
    func generateHealthKitData() {
        var writeTypes = Set<HKSampleType>()
        writeTypes.insert( HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)! )
        writeTypes.insert( HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)! )
        writeTypes.insert( HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)! )
        
        healthStore.requestAuthorization(toShare: writeTypes, read: [] ) { ( result, error ) in
            if let error = error {
                print( ["error: ", error] )
                return
            }
            self.fillRandomData( days: 5 )
        }
    }
    
    func checkNeedGenerateHealthKitData() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "ShowMainPage":
                (segue.destination as! MainPageViewController).user = self.user
            default:
                break
            }
        }
        
    }
}

