//
//  MUNCHIEBOXUnitTests.swift
//  MUNCHIEBOXUnitTests
//
//  Created by Johnathan Chen on 8/20/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import XCTest
@testable import Firebase
@testable import MUNCHIEBOX


class MUNCHIEBOXUnitTests: XCTestCase {
    
    let util = Utilities()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsOpen() {
        let result = util.isTimeOpen(open: String, close: String)
        XCTAssert()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
