//
//  TimedData.swift
//  MobileCenterExample
//
//  Created by nypreHeB on 11.05.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

func autocast<T>(some: Any) -> T {
    return some as! T
}


protocol Addable {
    static func +(lhs: Self, rhs: Self) -> Self
}

protocol Initable {
    init()
}

class TimedData<T: Initable & Addable> {
    private var dataContainer = [Int: T?]()
    
    func set( data: T, for day: Int ) {
        dataContainer[day] = data
    }
    
    func get( for day: Int ) -> T? {
        if let dayStats = dataContainer[day] {
            return dayStats
        }

        return nil
    }
    
    func get( from: Int, to: Int ) -> T {
        var result = T()
        
        for day in from...to {
            if let value = get(for: day) {
                result = result + value
            }
        }
        return result
    }
    
    func getOrCreate( for day: Int ) -> T {
        if let value = get( for: day ) {
            return value
        }
        
        let value = T()
        set( data: value, for: day )
        
        return value
    }
}
