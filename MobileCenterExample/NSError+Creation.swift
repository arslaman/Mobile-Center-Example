//
//  NSError+Creation.swift
//  MobileCenterExample
//
//  Created by Ruslan Mansurov on 6/1/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

public enum ErrorType: Int {
    
    case Unknown = 1
    
    func localizedUserInfo() -> [String: String] {
        var localizedDescription: String = ""
        
        switch self {
        case .Unknown:
            localizedDescription = "Unknown error"
        }
        return [ NSLocalizedDescriptionKey: localizedDescription ]
    }
}

public let ProjectErrorDomain = "ProjectErrorDomain"

extension NSError {
    
    public convenience init(type: ErrorType) {
        self.init(domain: ProjectErrorDomain, code: type.rawValue, userInfo: type.localizedUserInfo())
    }
}
