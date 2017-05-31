//
//  SettingsService.swift
//  MobileCenterExample
//
//  Created by Ruslan Mansurov on 5/31/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

protocol SettingsService {
    var mobileCenterAppSecret: String { get }
    var twitterConsumerKey: String { get }
    var twitterConsumerSecret: String { get }
}

class MCSettingsService: SettingsService {
    var mobileCenterAppSecret: String {
        return valueFor("MSMobileCenterAppSecret")
    }
    
    var twitterConsumerKey: String {
        return valueFor("TwitterConsumerKey")
    }
    
    var twitterConsumerSecret: String {
        return valueFor("TwitterConsumerSecret")
    }
    
    var config: [String: AnyObject] {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let configDict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            return configDict
        }
        return [String: AnyObject]()
    }
    
    func valueFor(_ key: String) -> String {
        if let value = config[key] as? String {
            return value
        }
        fatalError("*** Unable to read " + key + " from plist ***")
    }
}
