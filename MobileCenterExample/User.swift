//
//  User.swift
//  MobileCenterExample
//
//  Created by Insaf Safin on 26.04.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

class User {
    
    var fullName: String
    var accessToken: String
    var imageUrlString: String
    var socialNetwork: SocialNetwork
    
    init( fullName: String, accessToken: String, socialNetwork: SocialNetwork, imageUrlString: String ) {
        self.fullName = fullName
        self.accessToken = accessToken
        self.socialNetwork = socialNetwork
        self.imageUrlString = imageUrlString
    }
}

class UserStats : Initable, Addable {
    fileprivate var quantities = [String : Double]()
    
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
    
    required init(date: Date) {
        
    }
    
    static func +(lhs: UserStats, rhs: UserStats) -> Self {
        let result: UserStats = UserStats(date: Date())
        result.quantities = lhs.quantities
        
        for ( key, value ) in rhs.quantities {
            result[key] = result[key] + value
        }
        
        return autocast( some: result )
    }
}
