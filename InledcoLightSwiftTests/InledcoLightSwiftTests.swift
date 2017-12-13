//
//  InledcoLightSwiftTests.swift
//  InledcoLightSwiftTests
//
//  Created by huang zhengguo on 2017/7/31.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import XCTest
@testable import InledcoLightSwift

class InledcoLightSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStringManager() {
        
    }
    
    func testBlueToothManager() {
        print("开始测试蓝牙工具!")
        let bluetoothManager = BlueToothManager.sharedBluetoothManager()
        
        XCTAssert(bluetoothManager.calculateReceiveDataLength(channelNum: 3, runModeStr: "00") == 48)
        XCTAssert(bluetoothManager.calculateReceiveDataLength(channelNum: 4, runModeStr: "00") == 60)
        XCTAssert(bluetoothManager.calculateReceiveDataLength(channelNum: 5, runModeStr: "00") == 72)
        XCTAssert(bluetoothManager.calculateReceiveDataLength(channelNum: 6, runModeStr: "00") == 84)
        
        XCTAssert(bluetoothManager.calculateReceiveDataLength(channelNum: 3, runModeStr: "01") == 36)
        XCTAssert(bluetoothManager.calculateReceiveDataLength(channelNum: 4, runModeStr: "01") == 40)
        XCTAssert(bluetoothManager.calculateReceiveDataLength(channelNum: 5, runModeStr: "01") == 44)
        XCTAssert(bluetoothManager.calculateReceiveDataLength(channelNum: 6, runModeStr: "01") == 48)
        print("结束测试蓝牙工具!")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
