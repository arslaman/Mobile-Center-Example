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
