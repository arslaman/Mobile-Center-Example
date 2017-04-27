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

    var fullName: String
    var accessToken: String
    var socialNetwork: SocialNetwork
    
    init( fullName: String, accessToken: String, socialNetwork: SocialNetwork ) {
        self.fullName = fullName
        self.accessToken = accessToken
        self.socialNetwork = socialNetwork
    }
}
