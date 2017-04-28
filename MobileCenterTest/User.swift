//
//  User.swift
//  MobileCenterTest
//
//  Created by Insaf Safin on 26.04.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

enum SocialNetwork : String {
    case Twitter = "Twitter"
    case Facebook = "Facebook"
}

class User {
    struct UserStats {
        
    }
    
    var fullName: String
    var accessToken: String
    var socialNetwork: SocialNetwork
    var userStats: TimedData<UserStats>
    
    init( fullName: String, accessToken: String, socialNetwork: SocialNetwork ) {
        self.fullName = fullName
        self.accessToken = accessToken
        self.socialNetwork = socialNetwork
        self.userStats = TimedData<UserStats>()
    }
}

struct TimedData<T> {
    private var dataContainer = [Int: [Int: T?]]()
    
    mutating func set( data: T, for day: Int, and hour: Int ) {
        var dayContainer = dataContainer[day]
        
        if dataContainer[day] == nil {
            dayContainer = [Int: T]()
            dataContainer[day] = dayContainer
        }
        
        dataContainer[day]![hour] = data
    }
    
    func get( for day: Int, and hour: Int ) -> T? {
        return (dataContainer[day]?[hour])!
    }
}
