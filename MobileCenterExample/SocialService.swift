//
//  SocialService.swift
//  MobileCenterExample
//
//  Created by Ruslan Mansurov on 6/1/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

typealias SocialLogInCompletion = (User?, Error?) -> Void

protocol SocialService {
    func logIn(with viewController: UIViewController, completion: @escaping SocialLogInCompletion);
}
