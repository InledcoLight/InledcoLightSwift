//
//  BlueToothManager.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/14.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//  蓝牙管理对象处理
//

import UIKit

// 设备开关状态
enum DeviceState {
    case POWER_ON
    case POWER_OFF
    case UNKNOWN_STATE
}

// 蓝牙设置运行模式
enum DeviceRunMode {
    case MANUAL_RUN_MODE
    case AUTO_RUN_MODE
    case UNKNOWN_RUN_MODE
}

// 命令头
enum CommandHeader: String {
    case COMMANDHEAD_ONE = "6801"
    case COMMANDHEAD_TWO = "6802"
    case COMMANDHEAD_THREE = "6803"
    case COMMANDHEAD_FOUR = "6804"
    case COMMANDHEAD_FIVE = "6805"
    case COMMANDHEAD_SIX = "6806"
    case COMMANDHEAD_ELEVEN = "680B"
    case COMMANDHEAD_TWELVE = "680C"
}

// 命令类型
enum CommandType {
    case SYNCTIME_COMMAND
    case POWERON_COMMAND
    case POWEROFF_COMMAND
    case FINDDEVICE_COMMAND
    case SETTINGUSERDEFINED_COMMAND
    case READTIME_COMMAND
    case MANUALMODE_COMMAN
    case AUTOMODE_COMMAN
    case UNKNOWN_COMMAND
}

class BlueToothManager: NSObject, BLEManagerDelegate {

    private static var bluetoothManager: BlueToothManager?;
    private let bleManager: BLEManager! = BLEManager<AnyObject, AnyObject>.default()
    private let reconnectInterval: TimeInterval! = 2
    private let maxConnectCount: Int! = 3
    private var connectCount: Int! = 0
    private var connectTimer: Timer?
    private var isReceiveDataAll: Bool! = false
    private var lastCommandSendTime: TimeInterval! = 0.0
    private let maxCommandLength: Int = 30
    private var currentCommandType: CommandType! = .UNKNOWN_COMMAND
    private var receivedData: String = ""
    typealias oneStrParameterType = (_ dataStr: String?, _ commandType: CommandType) -> Void
    var completeReceiveDataCallback: oneStrParameterType?
    var connectFailedCallback: oneStrParameterType?
    
    static func sharedBluetoothManager() -> BlueToothManager {
        if bluetoothManager == nil {
            bluetoothManager = BlueToothManager()
        }
        
        bluetoothManager?.bleManager.delegate = bluetoothManager
        bluetoothManager?.connectCount = 0
        bluetoothManager?.isReceiveDataAll = false
        bluetoothManager?.lastCommandSendTime = 0
        
        return bluetoothManager!
    }
    
    override init() {

    }
    
    /// 连接设备
    /// - parameter uuid: 设备标识
    ///
    /// - returns: 空
    func connectDeviceWithUuid(uuid: String!) -> Void {
        self.connectCount = 0
        self.connectTimer = Timer.scheduledTimer(timeInterval: reconnectInterval, target: self, selector: #selector(sendConnectCommandToDevice(timer:)), userInfo: uuid, repeats: true)
    }
    
    ///
    /// - parameter one:
    /// - parameter two:
    ///
    /// - returns:
    func disConnectDevice(uuid: String!) -> Void {
        self.bleManager.disconnectDevice(self.bleManager.getDeviceByUUID(uuid))
    }
    
    /// 连接设备定时器方法
    /// - parameter timer: 调用该方法的定时器
    ///
    /// - returns: 空
    @objc private func sendConnectCommandToDevice(timer: Timer) -> Void {
        self.connectCount = self.connectCount + 1
        if self.connectCount >= self.maxConnectCount {
            self.connectTimer?.invalidate()
            self.connectTimer = nil
            
            // 调用连接超时回调
            if connectFailedCallback != nil {
                self.connectFailedCallback!(nil, CommandType.UNKNOWN_COMMAND)
            }
            
            return
        }
        
        // 连接设备
        let uuid = timer.userInfo as! String
        let device: CBPeripheral = self.bleManager.getDeviceByUUID(uuid)
        if !self.bleManager.dev_DICARRAY.contains(device) {
            self.bleManager.dev_DICARRAY.add(device)
        }
        
        self.bleManager.connect(toDevice: device)
    }
    
    /// 发送同步时间命令
    /// - parameter device: 设备
    ///
    /// - returns: Void
    func sendSynchronizationTimeCommand(device: CBPeripheral) -> Void {
        self.isReceiveDataAll = false
        self.receivedData = ""
        self.currentCommandType = .SYNCTIME_COMMAND
        
        // 获取当前时间
        let currentDate: Date! = Date()
        let calendar: Calendar! = Calendar.current
        let weekComps: DateComponents! = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: currentDate)
        
        // 构建同步时间命令
        let commandStr: String! = String(format: "680E%02x%02x%02x%02x%02x%02x%02x", weekComps.year! % 2000, weekComps.month!, weekComps.day!, weekComps.weekday!, weekComps.hour!, weekComps.minute!, weekComps.second!)
        
        print("同步时间字符串校验码: \(String(describing: commandStr.calculateXor()))")
        self.bleManager.sendData(toDevice1: commandStr + commandStr.calculateXor()!, device: device)
    }
    
    /// 发送打开开关命令
    /// - parameter uuid: 设备标识
    ///
    /// - returns: void
    func sendPowerOnCommand(uuid: String!) -> Void {
        sendCommandToDevice(uuid: uuid, commandStr: "680301", commandType: .POWERON_COMMAND, isXORCommand: true)
    }
    
    /// 发送关闭开关命令
    /// - parameter uuid: 设备标识
    ///
    /// - returns: void
    func sendPowerOffCommand(uuid: String) -> Void {
         sendCommandToDevice(uuid: uuid, commandStr: "680300", commandType: .POWEROFF_COMMAND, isXORCommand: true)
    }
    
    /// 发送手动模式命令
    /// - parameter uuid: 设备标识
    ///
    /// - returns: void
    func sendManualModeCommand(uuid: String) -> Void {
        sendCommandToDevice(uuid: uuid, commandStr: "680200", commandType: .MANUALMODE_COMMAN, isXORCommand: true)
    }
    
    /// 发送自动模式命令
    /// - parameter uuid: 设备标识
    ///
    /// - returns: void
    func sendAutoModeCommand(uuid: String) -> Void {
        sendCommandToDevice(uuid: uuid, commandStr: "680201", commandType: .AUTOMODE_COMMAN, isXORCommand: true)
    }
    
    /// 发送读取时间命令
    /// - parameter uuid: 设备标识
    ///sendFindDeviceCommand
    /// - returns: void
    func sendReadTimeCommand(uuid: String) -> Void {
        sendCommandToDevice(uuid: uuid, commandStr: "680D", commandType: .READTIME_COMMAND, isXORCommand: true)
    }
    
    /// 发送查找设备命令
    /// - parameter uuid: 设备标识
    ///
    /// - returns: void
    func sendFindDeviceCommand(uuid: String) -> Void {
        sendCommandToDevice(uuid: uuid, commandStr: "680F", commandType: .FINDDEVICE_COMMAND, isXORCommand: true)
    }
    
    /// 设置设备名称
    /// - parameter one:
    /// - parameter two:
    ///
    /// - returns:
    func setDeviceName(uuid:String , name: String!) -> Void {
        self.bleManager.isEncryption = false
        self.bleManager.setDeviceName(name, device: self.bleManager.getDeviceByUUID(uuid))
        self.bleManager.isEncryption = true
    }
    
    /// 发送命令：所有的命令发送都要通过这个方法发送，该方法可以放松任意长度的命令
    /// - parameter uuid: 设置标识
    /// - parameter commandStr: 不带校验的命令
    /// - parameter commandType: 命令类型
    /// - parameter isXORCommand: 发送命令时是否计算校验码
    /// - parameter commandInterval: 命令发送时间间隔，默认为50毫秒
    ///
    /// - returns: void
    func sendCommandToDevice(uuid: String, commandStr: String, commandType: CommandType, isXORCommand: Bool, commandInterval: TimeInterval = 50) -> Void {
        
        self.isReceiveDataAll = false
        var xorCommand: String! = commandStr
        if isXORCommand {
            // 计算校验码
            xorCommand.append(xorCommand.calculateXor()!)
        }
        
        var subLastCommandStr: String! = xorCommand
        while subLastCommandStr.count > maxCommandLength {
            let startSlicingIndex = subLastCommandStr.index(subLastCommandStr.startIndex, offsetBy: maxCommandLength - 1)
            self.sendSafeCommand(uuid: uuid, commandStr: String(subLastCommandStr[..<startSlicingIndex]), commandType: commandType, commandInterval: commandInterval)
            
            subLastCommandStr = String(subLastCommandStr[startSlicingIndex...])
        }
        
        self.sendSafeCommand(uuid: uuid, commandStr: subLastCommandStr, commandType: commandType, commandInterval: commandInterval)
    }
    
    private func sendSafeCommand(uuid: String, commandStr: String, commandType: CommandType, commandInterval: TimeInterval) -> Void {
        if Date().timeIntervalSince1970 * 1000 - self.lastCommandSendTime < commandInterval {
            return
        }
        
        self.currentCommandType = commandType
        
        let device: CBPeripheral = self.bleManager.getDeviceByUUID(uuid)
        self.bleManager.sendData(toDevice1: commandStr, device: device)
        
        self.lastCommandSendTime = Date().timeIntervalSince1970 * 1000
    }
    
    // 蓝牙回调
    func connectDeviceSuccess(_ device: CBPeripheral!, error: Error!) {
        print("连接成功:\(String(describing: device.name))")
        self.connectCount = 0
        if self.connectTimer != nil {
            self.connectTimer?.invalidate()
            self.connectTimer = nil
        }
        
        // 发送同步时间命令
        sendSynchronizationTimeCommand(device: device)
    }
    
    func didDisconnectDevice(_ device: CBPeripheral!, error: Error!) {
        print("断开设备:\(String(describing: device.name))")
        // 调用断开设备回调
    }
    
    func receiveDeviceAdvertData(_ dataStr: String!, device: CBPeripheral!) {
        print("获取广播数据成功")
    }
    
    func receiveDeviceDataSuccess_1(_ data: Data!, device: CBPeripheral!) {
        // 处理OTA

        // 处理正常命令返回的数据
        if self.isReceiveDataAll {
            return
        }
        
        // 拼接接收到的数据
        self.receivedData.append(String.dataToHexString(data: data)!)
        if self.receivedData.count <= 0 {
            return
        }
        
        // 检验数据是否接收完毕
        if self.receivedData.calculateXor() == "00" {
            self.isReceiveDataAll = true
            // print("接收到的完整数据:\(self.receivedData)")
            
            // 根据命令类型，处理返回的数据
            print("发送的命令：\(self.currentCommandType),receivedData=\(String(self.receivedData))")
            switch self.currentCommandType {
            case .SYNCTIME_COMMAND,
                 .POWERON_COMMAND,
                 .POWEROFF_COMMAND,
                 .MANUALMODE_COMMAN,
                 .SETTINGUSERDEFINED_COMMAND,
                 .AUTOMODE_COMMAN:
                if self.completeReceiveDataCallback != nil {
                    self.completeReceiveDataCallback!(self.receivedData, self.currentCommandType)
                }
              
            default:
                print("未知命令")
            }
            
            self.receivedData = ""
        }
    }
    
    /// 1.解析数据
    /// - parameter receiveData: 接收到的数据
    /// - parameter parameterModel: 参数模型
    ///
    /// - returns: void
    func parseDeviceDataFromReceiveStrToModel(receiveData: String, parameterModel: DeviceParameterModel) -> Void {
        // 解析参数模型数据
        var index = 0
        var commandCharacters: [Character]! = [Character]()
        for c in receiveData {
            commandCharacters.append(c)
        }
        // 解析命令帧头
        parameterModel.commandHeader.append(commandCharacters[index])
        parameterModel.commandHeader.append(commandCharacters[index + 1])
        
        // 解析命令码
        index = index + 2
        parameterModel.commandCode.append(commandCharacters[index])
        parameterModel.commandCode.append(commandCharacters[index + 1])
        
        // 解析设备运行模式
        index = index + 2
        var runModeStr: String = ""
        runModeStr.append(commandCharacters[index])
        runModeStr.append(commandCharacters[index + 1])
        index = index + 2
     
        if runModeStr == "00" {
            // 手动模式
            parameterModel.runMode = DeviceRunMode.MANUAL_RUN_MODE
            
            // 解析开关状态
            var powerStateStr: String = ""
            powerStateStr.append(commandCharacters[index])
            powerStateStr.append(commandCharacters[index + 1])
            if powerStateStr == "00" {
                parameterModel.powerState = DeviceState.POWER_OFF
            } else if powerStateStr == "01" {
                parameterModel.powerState = DeviceState.POWER_ON
            } else {
                parameterModel.powerState = DeviceState.UNKNOWN_STATE
                return
            }
            
            // 解析动态模式
            index = index + 2
            parameterModel.dynamicMode?.append(commandCharacters[index])
            parameterModel.dynamicMode?.append(commandCharacters[index + 1])
            
            // 解析手动模式下，所有通道的数据，按照键值1,2,3,4,5...存储到字典中
            index = index + 2
            var colorStr: String?
            var colorIndex = 0
            for _ in 0 ..< parameterModel.channelNum! {
                colorStr = ""
                // 由于高位在后，需要先添加高位
                colorStr?.append(commandCharacters[index + 2])
                colorStr?.append(commandCharacters[index + 3])
                colorStr?.append(commandCharacters[index])
                colorStr?.append(commandCharacters[index + 1])

                parameterModel.manualModeValueDic[colorIndex] = colorStr
                
                colorIndex = colorIndex + 1
                index = index + 4
            }
            
            // 解析用户自定义数据
            colorStr = ""
            colorIndex = 0
            for _ in 0 ..< 4 {
                colorStr = ""
                for _ in 0 ..< parameterModel.channelNum! * 2 {
                    colorStr?.append(commandCharacters[index])
                    index = index + 1
                }
                
                parameterModel.userDefinedValueDic![colorIndex] = colorStr
                colorIndex = colorIndex + 1
            }
            
        } else if runModeStr == "01" {
            // 自动模式
            parameterModel.runMode = DeviceRunMode.AUTO_RUN_MODE
            let timePointNum = 2
            var timePointStr = ""
            var colorStr = ""
            for i in 0 ..< timePointNum {
                // 开始时间
                for _ in 0 ..< 4 {
                    timePointStr.append(commandCharacters[index])
                    index = index + 1
                }
                
                parameterModel.timePointArray.append(timePointStr)
                
                // 结束时间
                timePointStr = ""
                for _ in 0 ..< 4 {
                    timePointStr.append(commandCharacters[index])
                    index = index + 1
                }
                parameterModel.timePointArray.append(timePointStr)
                
                // 解析时间对应的颜色值
                for _ in 0 ..< parameterModel.channelNum! * 2 {
                    colorStr.append(commandCharacters[index])
                    index = index + 1
                }

                parameterModel.timePointValueDic[i] = colorStr
                
                timePointStr = ""
                colorStr = ""
            }
        } else {
            // 解析数据出错
            parameterModel.runMode = DeviceRunMode.UNKNOWN_RUN_MODE
            return
        }
    }
}

































