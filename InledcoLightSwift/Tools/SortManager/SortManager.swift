//
//  SortManager.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/12/18.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

// 实现数组按照模型中的字符串的属性的值进行排序，使用泛型
class SortManager<T> {
    /// 冒泡排序
    /// - parameter models: 要排序的数组
    /// - parameter compareAction: 比较规则
    ///
    /// - returns: Void
    class func bubbleSort(models: inout [T], compareAction: (T, T) -> Bool) -> Void {
        var swapped = true
        
        // 冒泡排序，但是比较的规则使用compareAction实现
        repeat {
            swapped = false
            for i in 0 ..< models.count - 1 {
                if compareAction(models[i], models[i + 1]) {
                    let tmpModel = models[i]
                    models[i] = models[i + 1]
                    models[i + 1] = tmpModel
                    
                    swapped = true
                }
            }
        } while swapped
    }
}
