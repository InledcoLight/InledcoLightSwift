//
//  DeviceTypeData.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/18.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit

class DeviceTypeData {    
    // 通用颜色及标题数组
    static let oneColorArray: [UIColor]! = [UIColor.red]
    static let oneColorTitleArray: [String]! = ["Channel One"]
    static let twoColorArray: [UIColor]! = [UIColor.red, UIColor.red]
    static let twoColorTitleArray: [String]! = ["Channel One", "Channel Two"]
    static let threeColorArray: [UIColor]! = [UIColor.red, UIColor.red, UIColor.red]
    static let threeColorTitleArray: [String]! = ["Channel One", "Channel Two", "Channel Three"]
    static let fourColorArray: [UIColor]! = [UIColor.red, UIColor.green, UIColor.blue, UIColor.white]
    static let fourColorTitleArray: [String]! = ["Channel One", "Channel Two", "Channel Three", "Channel Four"]
    static let fiveColorArray: [UIColor]! = [UIColor.red, UIColor.green, UIColor.blue, UIColor.white, UIColor.cyan]
    static let fiveColorTitleArray: [String]! = ["Channel One", "Channel Two", "Channel Three", "Channel Four", "Channel Five"]
    static let sixColorArray: [UIColor]! = [UIColor.red, UIColor.red, UIColor.red, UIColor.red, UIColor.red, UIColor.red]
    static let sixColorTitleArray: [String]! = ["Channel One", "Channel Two", "Channel Three", "Channel Four", "Channel Five", "Channel Six"]
    
    // 对应灯具颜色及颜色标题数组
    static let stripIIIColorArray: [UIColor]! = [UIColor.red,UIColor.green,UIColor.blue,UIColor.white]
    static let stripIIIColorTitleArray: [String]! = ["Red","Green","Blue","White"]
    
    ///  根据设备类型编码获取设备信息
    /// - parameter deviceTypeCode: 设备类型编码
    ///
    /// - returns: 设备相关信息
    static func getDeviceInfoWithTypeCode(deviceTypeCode: DeviceTypeCode) -> DeviceCodeInfo {
        let deviceCodeInfo: DeviceCodeInfo = DeviceCodeInfo()
        
        switch deviceTypeCode {
        case .LIGHT_CODE_STRIP_III:
            deviceCodeInfo.deviceTypeCode = deviceTypeCode
            deviceCodeInfo.deviceName = "HAGEN Strip III"
            deviceCodeInfo.pictureName = "led"
            deviceCodeInfo.channelNum = 4
            deviceCodeInfo.channelColorArray = stripIIIColorArray
            deviceCodeInfo.channelColorTitleArray = stripIIIColorTitleArray
        case .ONECHANNEL_LIGHT:
            deviceCodeInfo.deviceTypeCode = deviceTypeCode
            deviceCodeInfo.deviceName = "One channel light"
            deviceCodeInfo.pictureName = "led"
            deviceCodeInfo.channelNum = 1
            deviceCodeInfo.channelColorArray = oneColorArray
            deviceCodeInfo.channelColorTitleArray = oneColorTitleArray
        case .TWOCHANNEL_LIGHT:
            deviceCodeInfo.deviceTypeCode = deviceTypeCode
            deviceCodeInfo.deviceName = "Two channel light"
            deviceCodeInfo.pictureName = "led"
            deviceCodeInfo.channelNum = 2
            deviceCodeInfo.channelColorArray = twoColorArray
            deviceCodeInfo.channelColorTitleArray = twoColorTitleArray
        case .THREECHANNEL_LIGHT:
            deviceCodeInfo.deviceTypeCode = deviceTypeCode
            deviceCodeInfo.deviceName = "Three channel light"
            deviceCodeInfo.pictureName = "led"
            deviceCodeInfo.channelNum = 3
            deviceCodeInfo.channelColorArray = threeColorArray
            deviceCodeInfo.channelColorTitleArray = threeColorTitleArray
        case .FOURCHANNEL_LIGHT:
            deviceCodeInfo.deviceTypeCode = deviceTypeCode
            deviceCodeInfo.deviceName = "Four channel light"
            deviceCodeInfo.pictureName = "led"
            deviceCodeInfo.channelNum = 4
            deviceCodeInfo.channelColorArray = fourColorArray
            deviceCodeInfo.channelColorTitleArray = fourColorTitleArray
        case .FIVECHANNEL_LIGHT:
            deviceCodeInfo.deviceTypeCode = deviceTypeCode
            deviceCodeInfo.deviceName = "Five channel light"
            deviceCodeInfo.pictureName = "led"
            deviceCodeInfo.channelNum = 5
            deviceCodeInfo.channelColorArray = fiveColorArray
            deviceCodeInfo.channelColorTitleArray = fiveColorTitleArray
        case .SIXCHANNEL_LIGHT:
            deviceCodeInfo.deviceTypeCode = deviceTypeCode
            deviceCodeInfo.deviceName = "Six channel light"
            deviceCodeInfo.pictureName = "led"
            deviceCodeInfo.channelNum = 6
            deviceCodeInfo.channelColorArray = sixColorArray
            deviceCodeInfo.channelColorTitleArray = sixColorTitleArray
        default:
            deviceCodeInfo.deviceTypeCode = deviceTypeCode
            deviceCodeInfo.deviceName = "NEW DEVICE"
            deviceCodeInfo.pictureName = "led"
            deviceCodeInfo.channelNum = 4
            deviceCodeInfo.channelColorArray = fourColorArray
            deviceCodeInfo.channelColorTitleArray = fourColorTitleArray
            break
        }
        
        return deviceCodeInfo
    }
}






















