//
//  MainPageViewController.swift
//  MobileCenterExample
//
//  Created by Insaf Safin on 26.04.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

import HealthKit

class ProfilePageViewController: UIViewController {

    @IBOutlet var caloriesLabel: UILabel?
    @IBOutlet var stepsLabel: UILabel?
    @IBOutlet var distanceLabel: UILabel?
    @IBOutlet var greetingsLabel: UILabel?
    @IBOutlet var timeLabel: UILabel?
    
    @IBOutlet var profileImageView: UIImageView?
    @IBOutlet var profileBorderView: UIView?
    
    var doubleFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSize = 3
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    var integerFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSize = 3
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    open var userStats: TimedData<FitnessDailyData>? {
        didSet {
            self.updateData()
        }
    }
    
    open var user: User? {
        didSet {
            self.updateData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        updateData()
    }
    
    func configureViews() {
        profileImageView?.layer.cornerRadius = (profileImageView?.bounds.size.width)! / 2
        profileImageView?.clipsToBounds = true
        
        profileBorderView?.layer.cornerRadius = (profileBorderView?.bounds.size.width)! / 2
        profileBorderView?.layer.borderWidth = 1
        profileBorderView?.layer.borderColor = profileBorderView?.backgroundColor?.cgColor
        profileBorderView?.backgroundColor = UIColor.clear
    }

    func updateData() {
        guard self.isViewLoaded else {
            return
        }
        
        updateUserData()
        updateStatisticsLabels()
    }
    
    func updateUserData() {
        if let user = user {
            greetingsLabel?.text = "HI, \(user.fullName.uppercased())!"
            
            guard let url = URL(string: user.imageUrlString) else { return }
            profileImageView?.setImage(from: url)
        }
    }
    
    func updateStatisticsLabels() {
        guard let daylyData = userStats?.last() else {
            return
        }
        
        updateStepsLabel(daylyData.stepsCount)
        updateCaloriesLabel(daylyData.calories)
        updateDistanceLabel(daylyData.distanceInKM)
        updateTimeLabel(daylyData.activeTimeInMinutes)
    }
    
    func updateStepsLabel(_ value: Int) {
        stepsLabel?.text = String(value)
    }
    
    func updateCaloriesLabel(_ value: Double) {
        caloriesLabel?.text = integerFormatter.string(from: value as NSNumber)!
    }
    
    func updateDistanceLabel(_ value: Double) {
        let string = doubleFormatter.string(from: value as NSNumber)!
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.append(grayColoredAttributedString(" Km"))
        
        distanceLabel?.attributedText = attributedString
    }
    
    func updateTimeLabel(_ minutesValue: Double) {
        
        func minutesToHoursMinutes (_ minutes : Double) -> (Int, Int) {
            return (Int(minutes) / 60, (Int(minutes) % 60) )
        }
        let (hours, minutes) = minutesToHoursMinutes(minutesValue)
        
        let attributedString = NSMutableAttributedString()
        if (hours > 0) {
            attributedString.append(NSAttributedString(string: String(hours)))
            attributedString.append(grayColoredAttributedString("h "))
        }
        attributedString.append(NSAttributedString(string: String(minutes)))
        attributedString.append(grayColoredAttributedString("m"))
        
        timeLabel?.attributedText = attributedString
    }
    
    func grayColoredAttributedString(_ string: String) -> NSAttributedString {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.init(white: 144.0/255.0, alpha: 1),
            NSFontAttributeName: UIFont.systemFont(ofSize: 11)
        ]
        let attributedString = NSAttributedString(string: string, attributes: attributes)
        
        return attributedString
    }
}
