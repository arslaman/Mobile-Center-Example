//
//  User.swift
//  MobileCenterExample
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

func autocast<T>(some: Any) -> T {
    return some as! T
}
   
class UserStats : Initable, Addable {
    private var quantities = [String : Double]()
    
    subscript( index: String ) -> Double {
        get {
            if let quantity = quantities[index] {
                return quantity
            }
            
            return 0
        }
        
        set ( value ) {
            quantities[index] = value
        }
    }
    
    required init() {
        
    }
    
    static func +(lhs: UserStats, rhs: UserStats) -> Self {
        let result: UserStats = UserStats()
        result.quantities = lhs.quantities
        
        for ( key, value ) in rhs.quantities {
            result[key] = result[key] + value
        }
        
        return autocast( some: result )
    }
}

protocol Addable {
    static func +(lhs: Self, rhs: Self) -> Self
}

protocol Initable {
    init()
}

class TimedData<T: Initable & Addable> {
    private var dataContainer = [Int: [Int: T?]]()
    
    func set( data: T, for day: Int, and hour: Int ) {
        var dayContainer = dataContainer[day]
        
        if dataContainer[day] == nil {
            dayContainer = [Int: T]()
            dataContainer[day] = dayContainer
        }
        
        dataContainer[day]![hour] = data
    }
    
    func get( for day: Int, and hour: Int ) -> T? {
        if let dayContainer = dataContainer[day] {
            if let result = dayContainer[hour] {
                return result
            }
        }
        
        return nil
    }
    
    func get( for day: Int ) -> T {
        var result = T()
        if let dayContainer = dataContainer[day] {
            for ( _, value ) in dayContainer {
                if let value = value {
                    result = result + value
                }
            }
        }
        return result
    }
    
    func getOrCreate( for day: Int, and hour: Int ) -> T {
        if let value = get( for: day, and: hour ) {
            return value
        }
        
        let value = T()
        set( data: value, for: day, and: hour )
        
        return value
    }
}
