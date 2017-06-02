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
/**
 Used to store any data in convenient way with separation by dates
 */
class TimedData<T: Initable> {
    private var dataContainer = [Date: T?]()
    
    /**
     Sets data for particular date
     If data for that date already exists, then data will be overwritten
     
     - Parameter data: data to store
     - Parameter date: linked date
     
     */
    func set( data: T, for date: Date ) {
        dataContainer[date] = data
    }
    
    /**
     Gets data for particular date
     If data for that date not exists, then it returns nil
     
     - Parameter date: linked date
     
     */
    func get( for date: Date ) -> T? {
        if let dayStats = dataContainer[date] {
            return dayStats
        }
        
        return nil
    }
    
    /**
     Gets data as an array sorted by dates.
     */
    func array() -> [T]? {
        guard dataContainer.count > 0 else {
            return nil
        }
        
        let result = dataContainer.keys.sorted(by: { $0 < $1 }).flatMap({ dataContainer[$0]! })
        return result
    }
    
    /**
     Get data by index
     Latest data (according to its date) has bigger index
     
     - Parameter index: index of data
     */
    func get( _ index: Int ) -> T? {
        guard index >= 0, dataContainer.count > index else {
            return nil
        }
        
        let date = dataContainer.keys.sorted()[index]
        return dataContainer[date]!
    }
    
    /**
     Get the last data according to its date
     */
    func last() -> T? {
        guard dataContainer.count > 0 else {
            return nil
        }
        
        let lastDate = dataContainer.keys.sorted().last!
        return dataContainer[lastDate]!
    }
    
    /**
     Get data for particular date.
     If data for that date is not exists, then it will be created
     */
    func getOrCreate( for date: Date ) -> T {
        if let value = get( for: date ) {
            return value
        }
        
        let value = T(date: date)
        set( data: value, for: date )
        
        return value
    }
}
