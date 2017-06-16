//
//  TimedDataTests.swift
//  MobileCenterIOSNativeTests
//
//  Created by Ruslan Mansurov on 6/15/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import XCTest
@testable import MobileCenterExample

class StubInitable: Initable, Equatable {
    let date: Date
    required init(date: Date) {
        self.date = date
    }
    
    static func ==(lhs: StubInitable, rhs: StubInitable) -> Bool {
        return lhs.date == rhs.date
    }
}

class TimedDataTests: XCTestCase {
    
    var timedData: TimedData<StubInitable>!
    
    override func setUp() {
        super.setUp()
        
        timedData = TimedData<StubInitable>()
    }
    
    func testArrayForEmptyData() {
        XCTAssertNil(timedData.array(), "It should return nil on empty data")
    }
    
    func testArrayForOneData() {
        let date = Date()
        let initableObject = StubInitable(date: date)
        
        timedData.set(data: initableObject, for: date)
        let array = timedData.array()
        
        XCTAssertNotNil(array, "Array shouldn't be nil")
        XCTAssert(array!.count == 1, "Array should contain one object")
        XCTAssertEqual(array!.first!, initableObject, "Array should contain the object we expect")
    }
    
    func testArrayForMultipleData() {
        let date1 = Date().addingTimeInterval(1)
        let date2 = Date().addingTimeInterval(2)
        let date3 = Date().addingTimeInterval(3)
        
        let initableObject1 = StubInitable(date: date1)
        let initableObject2 = StubInitable(date: date2)
        let initableObject3 = StubInitable(date: date3)
        
        // set objects in random order
        timedData.set(data: initableObject2, for: date2)
        timedData.set(data: initableObject3, for: date3)
        timedData.set(data: initableObject1, for: date1)
        
        let array = timedData.array()
        
        XCTAssertNotNil(array, "Array shouldn't be nil")
        XCTAssert(array!.count == 3, "Array should contain 3 objects")
        // check the order of items
        XCTAssertEqual(array![0], initableObject1, "First object should come first")
        XCTAssertEqual(array![1], initableObject2, "Second object should come second")
        XCTAssertEqual(array![2], initableObject3, "Third object should come third")
    }
    
    func testGetOrCreateOnEmptyData() {
        let date = Date()
        
        let expectedInitableObject = StubInitable(date: date)
        XCTAssertEqual(timedData.getOrCreate(for: date), expectedInitableObject, "It should return expected object")
    }
    
    func testGetOrCreateOnNormalData() {
        let date = Date()
        let expectedInitableObject = StubInitable(date: date)
        
        timedData.set(data: expectedInitableObject, for: date)
        XCTAssertEqual(timedData.getOrCreate(for: date), expectedInitableObject, "It should return expected object")
    }
    
    func testGetByIndex() {
        let date1 = Date().addingTimeInterval(1)
        let date2 = Date().addingTimeInterval(2)
        let date3 = Date().addingTimeInterval(3)
        
        let initableObject1 = StubInitable(date: date1)
        let initableObject2 = StubInitable(date: date2)
        let initableObject3 = StubInitable(date: date3)
        
        // set objects in random order
        timedData.set(data: initableObject2, for: date2)
        timedData.set(data: initableObject3, for: date3)
        timedData.set(data: initableObject1, for: date1)
        
        // check the order of items
        XCTAssertEqual(timedData.get(0), initableObject1, "First object should come first")
        XCTAssertEqual(timedData.get(1), initableObject2, "Second object should come second")
        XCTAssertEqual(timedData.get(2), initableObject3, "Third object should come third")
        XCTAssertNil(timedData.get(3), "Should return nil when index is outside of elements count")
    }
    
    func testGetByDate() {
        let unexpectedDate = Date().addingTimeInterval(-100)
        let date1 = Date().addingTimeInterval(1)
        let date2 = Date().addingTimeInterval(2)
        let date3 = Date().addingTimeInterval(3)
        
        let initableObject1 = StubInitable(date: date1)
        let initableObject2 = StubInitable(date: date2)
        let initableObject3 = StubInitable(date: date3)
        
        // set objects in random order
        timedData.set(data: initableObject2, for: date2)
        timedData.set(data: initableObject3, for: date3)
        timedData.set(data: initableObject1, for: date1)
        
        // check the order of items
        XCTAssertEqual(timedData.get(for: date1), initableObject1, "Should return expected object for the following date")
        XCTAssertEqual(timedData.get(for: date2), initableObject2, "Should return expected object for the following date")
        XCTAssertEqual(timedData.get(for: date3), initableObject3, "Should return expected object for the following date")
        XCTAssertNil(timedData.get(for: unexpectedDate), "Should return nil when no elements with such date")
    }
}
