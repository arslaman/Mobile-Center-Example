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
    
    let healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        twitterButton.addTarget( self, action: #selector(LoginViewController.onTwitterTap), for: UIControlEvents.touchUpInside )
//        twitterButton.logInCompletion = { session, error in
//            if let session = session {
//                self.user = User(fullName: session.userName, accessToken: session.authToken, socialNetwork: SocialNetwork.Twitter )
//                self.showMainPage()
//            }
//        }
//        
//        facebookButton.delegate = self;
        
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func checkNeedGenerateHealthKitData() {
        var readTypes = Set<HKQuantityType>()
        var writeTypes = Set<HKSampleType>()
        
        writeTypes.insert( HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)! )
        writeTypes.insert( HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)! )
        writeTypes.insert( HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)! )
        
        readTypes.insert( HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)! )
        readTypes.insert( HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)! )
        readTypes.insert( HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)! )
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { ( success, error ) in
            if ( success ) {
//                self.healthStore.preferredUnits(for: [HKQuantityType.quantityType(forIdentifier:HKQuantityTypeIdentifier.distanceWalkingRunning)!]) { ( result, error ) in
//                    print( result )
//                    print( error )
//                }
                
//                self.fillRandomData( days: 5 )
            }
        }
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
    
    @IBAction func loginViaTwitter() {
        
    }
    
    @IBAction func loginViaFacebook() {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: [], from: self, handler: { ( loginResult, error ) in
            if let error = error {
                print( "an error occured: ", error )
            }
            else {
                if let loginResult = loginResult {
                    if !loginResult.isCancelled {
                        FBSDKProfile.loadCurrentProfile(completion: { (profile, error) in
                            if let profile = profile {
                                self.user = User(fullName: profile.name, accessToken: loginResult.token.tokenString, socialNetwork: SocialNetwork.Facebook )
                                self.showMainPage()
                            }
                            else {
                                if let error = error {
                                    print( "an error occured: ", error )
                                }
                                else {
                                    print( "unknown error occured" )
                                }
                            }
                        })
                    }
                }
            }
        })
    }
}

