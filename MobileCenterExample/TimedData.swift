//
//  TimedData.swift
//  MobileCenterExample
//
//  Created by nypreHeB on 11.05.17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

func autocast<T>(_ some: Any) -> T {
    return some as! T
}


protocol Addable {
    static func +(lhs: Self, rhs: Self) -> Self
}

protocol Initable {
    init(date: Date)
}

class TimedData<T: Initable> {
    private var dataContainer = [Date: T?]()
    
    func set( data: T, for date: Date ) {
        dataContainer[date] = data
    }
    
    func get( for date: Date ) -> T? {
        if let dayStats = dataContainer[date] {
            return dayStats
        }

        return nil
    }
    
    func get( _ index: Int ) -> T? {
        guard index >= 0, dataContainer.count > index else {
            return nil
        }
        
        let date = dataContainer.keys.sorted()[index]
        return dataContainer[date]!
    }
    
    func last() -> T? {
        guard dataContainer.count > 0 else {
            return nil
        }
        
        let lastDate = dataContainer.keys.sorted().last!
        return dataContainer[lastDate]!
    }
    
    func getOrCreate( for date: Date ) -> T {
        if let value = get( for: date ) {
            return value
        }
        
        let value = T(date: date)
        set( data: value, for: date )
        
        return value
    }
}
