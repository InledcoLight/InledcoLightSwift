//
//  StringManager.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/14.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

extension String {
    /// 计算16进制字符串校验码
    ///
    /// - returns: 根据字符串计算出的校验码
    func calculateXor() -> String? {
        if self.count % 2 != 0 || self.count == 0 {
            return nil
        }
        
        var xorStr: String! = "0"
        var index: Int! = 0
        var xorInt: Int16! = 0x0
        for character in self {
            if index % 2 != 0 {
                xorStr.append(character)
                xorInt = xorInt ^ xorStr.hexToInt16()
            } else {
                xorStr = ""
                xorStr.append(character)
            }
            
            index = index + 1
        }
        
        return String.init(format: "%02x", xorInt)
    }
    
    func hexToInt16() -> Int16 {
        let str = self.uppercased()
        var sum:Int16! = 0
        for i in str.utf8 {
            sum = sum * 16 + Int16(i) - 48
            if i >= 65 {
                sum = sum - 7
            }
        }
    
        return sum
    }
    
    /// 转化Data类型数据为16进制字符串
    /// - parameter data: 要转换的数据
    ///
    /// - returns: 转换后的16进制字符串
    static func dataToHexString(data: Data) -> String? {
        var hexStr = ""
        for i in 0 ..< data.count {
            hexStr = hexStr.appendingFormat("%02x", data[i])
        }
        
        return hexStr
    }
}






















