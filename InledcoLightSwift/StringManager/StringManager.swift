//
//  StringManager.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/14.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

extension String {
    static let MAXCOLORVALUE: Double! = 1000.0
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
    
    /// 转换两个字符：即两个字符的16进制的字符串为整形 例如：3E -> 62
    ///
    /// - returns: 16进制整形数
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
    
    /// 转换四个字符：即四个字符的16进制的字符串为整形 例如：DE03 -> 990 高位在后
    ///
    /// - returns: 10进制整形
    var hexaToDecimal: Int {
        return Int(strtoul(self, nil, 16))
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
    
    /// 转换16进制小时 分钟 的字符串为分钟数
    /// - parameter timeStr: 16进制时间值
    ///
    /// - returns: 转换后的分钟数
    func converTimeStrToMinute(timeStr: String?) -> Int? {
        if timeStr == nil || timeStr?.count != 4 {
            return nil
        }
        
        var minuteCount: Int16 = 0
        var cIndex = 0
        var hourStr: String = ""
        var minuteStr: String = ""
        for c in timeStr! {
            if cIndex < 2 {
                hourStr.append(c)
            } else {
                minuteStr.append(c)
            }
            
            cIndex = cIndex + 1
        }
        
        minuteCount = (hourStr.hexToInt16()) * Int16(60) + (minuteStr.hexToInt16())
        
        return Int(minuteCount)
    }
    
    /// 16进制时间字符串格式化 1100 -> 17:00  1212 -> 18:18
    ///
    /// - returns:
    func convertHexTimeToFormatTime() -> String {
        var index = 0
        var hourStr = ""
        var minuteStr = ""
        for c in self {
            if index < 2 {
                hourStr.append(c)
            } else {
                minuteStr.append(c)
            }
            
            index = index + 1
        }
        
        return String.init(format: "%02d:%02d", hourStr.hexToInt16(),minuteStr.hexToInt16())
    }
    
    /// 16进制时间字符串格式化  17:00 -> 1100 18:18 -> 1212
    ///
    /// - returns:
    func convertFormatTimeToHexTime() -> String {
        var index = 0
        var hourStr = ""
        var minuteStr = ""
        for c in self {
            if index < 2 {
                hourStr.append(c)
            } else if index > 2 {
                minuteStr.append(c)
            }
            
            index = index + 1
        }
        
        return String.init(format: "%02x%02x", strtol(hourStr, nil, 10),strtol(minuteStr, nil, 10))
    }
    
    /// 转换16进制颜色值字符串为Double数组
    ///
    /// - returns: 16进制对应的double数组
    func convertColorStrToDoubleValue() -> [Double]! {
        var colorDoubleArray: [Double] = [Double]()
        
        var hexStr: String = ""
        var cIndex: Int = 0
        for c in self {
            hexStr.append(c)
            if cIndex % 2 != 0 {
                colorDoubleArray.append(Double(hexStr.hexToInt16()))
                hexStr = ""
            }
            
            cIndex = cIndex + 1
        }
        
        return colorDoubleArray
    }
    
    /// 转换用户自定义数据(百分比表示)为颜色值字符串(16进制整型表示): 32643232 -> 0.5 * 1000 1.0 * 1000 0.5 * 1000 0.5 * 1000 -> 01F403E801F401F4
    ///
    /// - returns:
    func convertUserPercentToHexColorValue() -> String {
        var colorDoubleArray: [Double] = [Double]()
        
        colorDoubleArray = self.convertColorStrToDoubleValue()
        var colorValue: Int = 0
        var hexColorStr = ""
        for percent in colorDoubleArray {
            colorValue = Int(percent / 100.0 * String.MAXCOLORVALUE)
            hexColorStr = hexColorStr.appendingFormat("%04x", colorValue)
        }

        return hexColorStr
    }
}
