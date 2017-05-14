//
//  MainPageViewController.swift
//  MobileCenterExample
//
//  Created by Insaf Safin on 26.04.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

import HealthKit

import MobileCenterAnalytics

class ProfilePageViewController: UIViewController {

    @IBOutlet var caloriesLabel: UILabel?
    @IBOutlet var stepsLabel: UILabel?
    @IBOutlet var distanceLabel: UILabel?
    @IBOutlet var greetingsLabel: UILabel?
    @IBOutlet var timeLabel: UILabel?
    
    @IBOutlet var profileImageView: UIImageView?
    @IBOutlet var profileBorderView: UIView?
    
    let actualTypes = [HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                       HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                       HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
                       HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)!]
    
    var labels = [String : UILabel]()
    
    let doubleFormatter = NumberFormatter()
    let integerFormatter = NumberFormatter()
    var formatters = [String: NumberFormatter]()
    
    public var userStats: TimedData<UserStats>? {
        didSet {
            self.updateLabels()
        }
    }
    
    public var user: User? {
        didSet {
            self.fillContent()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doubleFormatter.groupingSize = 3
        doubleFormatter.maximumFractionDigits = 1
        
        integerFormatter.maximumFractionDigits = 0
        integerFormatter.groupingSize = 3
        
        formatters[HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue] = doubleFormatter
        formatters[HKQuantityTypeIdentifier.activeEnergyBurned.rawValue] = integerFormatter
        formatters[HKQuantityTypeIdentifier.stepCount.rawValue] = integerFormatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView?.layer.cornerRadius = (profileImageView?.bounds.size.width)! / 2
        profileImageView?.clipsToBounds = true
        
        profileBorderView?.layer.cornerRadius = (profileBorderView?.bounds.size.width)! / 2
        profileBorderView?.layer.borderWidth = 1
        profileBorderView?.layer.borderColor = profileBorderView?.backgroundColor?.cgColor
        profileBorderView?.backgroundColor = UIColor.clear
        
        labels[HKQuantityTypeIdentifier.stepCount.rawValue] = stepsLabel
        labels[HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue] = distanceLabel
        labels[HKQuantityTypeIdentifier.activeEnergyBurned.rawValue] = caloriesLabel
        labels[HKQuantityTypeIdentifier.appleExerciseTime.rawValue] = timeLabel
        
        self.fillContent()
    }

    func fillContent() -> Void {
        if !self.isViewLoaded {
            return
        }
        
        if let user = user {
            greetingsLabel?.text = "HI, \(user.fullName.uppercased())!"
            
            guard let url = URL(string: user.imageUrlString) else { return }
            profileImageView?.setImage(from: url)
        }
        
        updateLabels()
    }
    
    func updateLabels() {
        for type in actualTypes {
            self.updateLabel(for: type)
        }
    }
    
    func updateLabel( for type: HKQuantityType ) -> Void {
        guard let label = labels[type.identifier] else {
            return
        }
        var optionalValue = self.userStats?.get( for: 0 )?[type.identifier]
        if optionalValue == nil {
            optionalValue = 0.0
        }
        
        let value = optionalValue!
        
        if label == timeLabel {
            func minutesToHoursMinutes (minutes : Double) -> (Int, Int) {
                return (Int(minutes) / 60, (Int(minutes) % 60) )
            }
            let (hours, minutes) = minutesToHoursMinutes(minutes: value)
            if ( hours > 0 ) {
                let attributedString = NSMutableAttributedString(string: String(hours))
                attributedString.append(NSAttributedString(string: "h ",
                                                           attributes: [NSForegroundColorAttributeName: UIColor.init(white: 144.0/255.0,
                                                                                                                     alpha: 1),
                                                                        NSFontAttributeName: UIFont.systemFont(ofSize: 11)]))
                attributedString.append(NSAttributedString(string: String(minutes)))
                attributedString.append(NSAttributedString(string: "m",
                                                           attributes: [NSForegroundColorAttributeName: UIColor.init(white: 144.0/255.0,
                                                                                                                     alpha: 1),
                                                                        NSFontAttributeName: UIFont.systemFont(ofSize: 11)]))
                label.attributedText = attributedString
            }
            else {
                let attributedString = NSMutableAttributedString(string: String(minutes))
                attributedString.append(NSAttributedString(string: "m",
                                                           attributes: [NSForegroundColorAttributeName: UIColor.init(white: 144.0/255.0,
                                                                                                                     alpha: 1),
                                                                        NSFontAttributeName: UIFont.systemFont(ofSize: 11)]))
                label.attributedText = attributedString
            }
        }
        else if let formatter = formatters[type.identifier] {
            if label == self.distanceLabel {
                if let string = formatter.string(from: value as NSNumber) {
                    let attributedString = NSMutableAttributedString(string: string)
                    attributedString.append(NSAttributedString(string: " Km",
                                                               attributes: [NSForegroundColorAttributeName: UIColor.init(white: 144.0/255.0,
                                                                                                                         alpha: 1),
                                                                            NSFontAttributeName: UIFont.systemFont(ofSize: 11)]))
                    label.attributedText = attributedString
                }
            }
            else {
                label.text = formatter.string(from: value as NSNumber)
            }
        }
    }
}
