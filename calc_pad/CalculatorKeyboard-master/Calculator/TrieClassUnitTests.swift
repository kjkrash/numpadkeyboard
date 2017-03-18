//
//  TrieClassUnitTests.swift
//  CalculatorKeyboard
//
//  Created by Alex Hsieh on 2/18/17.
//  Copyright © 2017 Visual Recruit Pty Ltd. All rights reserved.
//

import XCTest
@testable import Calculator

class TrieClassUnitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoad() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var tn = Trie(filename: "dict.txt")
        tn.loadTrie()
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
