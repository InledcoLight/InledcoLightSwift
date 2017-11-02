//
//  OldParameterModelHelper.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/31.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

// 旧的模型辅助方法
extension DeviceParameterModel {
    /// 解析协议数据到模型中
    /// - parameter receiveData: 协议数据
    ///
    /// - returns: Void
    func parseOldDeviceDataFromReceiveStrToModel(receiveData: String) -> Void {
        // 解析参数模型数据
        var index = 0
        var commandCharacters: [Character]! = [Character]()
        for c in receiveData {
            commandCharacters.append(c)
        }
        // 解析命令帧头
        self.commandHeader.append(commandCharacters[index])
        self.commandHeader.append(commandCharacters[index + 1])
        
        // 解析命令码
        index = index + 2
        self.commandCode.append(commandCharacters[index])
        self.commandCode.append(commandCharacters[index + 1])
        
        // 解析设备运行模式
        index = index + 2
        var runModeStr: String = ""
        runModeStr.append(commandCharacters[index])
        runModeStr.append(commandCharacters[index + 1])
        index = index + 2
        
        if runModeStr == "00" {
            // 手动模式
            self.runMode = DeviceRunMode.MANUAL_RUN_MODE
            
            // 解析开关状态
            var powerStateStr: String = ""
            powerStateStr.append(commandCharacters[index])
            powerStateStr.append(commandCharacters[index + 1])
            if powerStateStr == "00" {
                self.powerState = DeviceState.POWER_OFF
            } else if powerStateStr == "01" {
                self.powerState = DeviceState.POWER_ON
            } else {
                self.powerState = DeviceState.UNKNOWN_STATE
                return
            }
            
            // 解析动态模式
            index = index + 2
            self.dynamicMode?.append(commandCharacters[index])
            self.dynamicMode?.append(commandCharacters[index + 1])
            
            // 解析手动模式下，所有通道的数据，按照键值1,2,3,4,5...存储到字典中
            index = index + 2
            var colorStr: String?
            var colorIndex = 0
            for _ in 0 ..< self.channelNum! {
                colorStr = ""
                // 由于高位在后，需要先添加高位
                colorStr?.append(commandCharacters[index + 2])
                colorStr?.append(commandCharacters[index + 3])
                colorStr?.append(commandCharacters[index])
                colorStr?.append(commandCharacters[index + 1])
                
                self.manualModeValueDic[colorIndex] = colorStr
                
                colorIndex = colorIndex + 1
                index = index + 4
            }
            
            // 解析用户自定义数据
            self.userDefinedValueDic.removeAll()
            colorStr = ""
            colorIndex = 0
            for _ in 0 ..< 4 {
                colorStr = ""
                for _ in 0 ..< self.channelNum! * 2 {
                    colorStr?.append(commandCharacters[index])
                    index = index + 1
                }
                
                self.userDefinedValueDic![colorIndex] = colorStr
                colorIndex = colorIndex + 1
            }
            
        } else if runModeStr == "01" {
            // 自动模式
            self.timePointArray.removeAll()
            self.timePointValueDic.removeAll()
            
            self.runMode = DeviceRunMode.AUTO_RUN_MODE
            let timePointNum = 2
            var timePointStr = ""
            var colorStr = ""
            for i in 0 ..< timePointNum {
                // 开始时间
                for _ in 0 ..< 4 {
                    timePointStr.append(commandCharacters[index])
                    index = index + 1
                }
                
                self.timePointArray.append(timePointStr)
                
                // 结束时间
                timePointStr = ""
                for _ in 0 ..< 4 {
                    timePointStr.append(commandCharacters[index])
                    index = index + 1
                }
                self.timePointArray.append(timePointStr)
                
                // 解析时间对应的颜色值
                for _ in 0 ..< self.channelNum! * 2 {
                    colorStr.append(commandCharacters[index])
                    index = index + 1
                }
                
                if i == (timePointNum - 1) {
                    self.timePointValueDic[0] = colorStr
                    self.timePointValueDic[2 * timePointNum - 1] = colorStr
                } else {
                    self.timePointValueDic[2 * i + 1] = colorStr
                    self.timePointValueDic[2 * i + 2] = colorStr
                }
                
                timePointStr = ""
                colorStr = ""
            }
        } else {
            // 解析数据出错
            self.runMode = DeviceRunMode.UNKNOWN_RUN_MODE
            return
        }
    }
    
    /// 根据模型生成设置自动模式命令
    ///
    /// - returns: 设置自动模式的命令
    func generateOldSetAutoCommand() -> String {
        var commandStr: String! = CommandHeader.COMMANDHEAD_SEVEN.rawValue
        
        for index in 0 ..< self.timePointValueDic.keys.count / 2 {
            // 1.拼接时间点
            commandStr.append(self.timePointArray[2 * index])
            commandStr.append(self.timePointArray[2 * index + 1])
            // 2.拼接时间点对应的颜色值
            if index == 0 {
                commandStr.append(self.timePointValueDic[1]!)
            } else {
                commandStr.append(self.timePointValueDic[2 * index + 1]!)
            }
        }
        
        return commandStr
    }
}
