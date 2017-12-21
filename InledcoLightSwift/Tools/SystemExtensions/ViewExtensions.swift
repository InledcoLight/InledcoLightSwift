//
//  ViewExtensions.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/12/20.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

extension UIView {
    var x: CGFloat {
        get{
            return frame.origin.x
        }
        
        set{
            var tmpFrame = frame
            
            tmpFrame.origin.x = x
            
            frame = tmpFrame
        }
    }
    
    var y: CGFloat {
        get{
            return frame.origin.y
        }
        
        set{
            var tmpFrame = frame
            
            tmpFrame.origin.y = y
            
            frame = tmpFrame
        }
    }
    
    var height: CGFloat {
        get{
            return frame.size.height
        }
        
        set{
            var tmpFrame = frame
            
            tmpFrame.size.height = height
            
            frame = tmpFrame
        }
    }
    
    var width: CGFloat {
        get{
            return frame.size.width
        }
        
        set{
            var tmpFrame = frame
            
            tmpFrame.size.width = width
            
            frame = tmpFrame
        }
    }
}
