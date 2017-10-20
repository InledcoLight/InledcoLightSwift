//
//  ManualCircleView.swift
//  InledcoLightSwift
//
//  Created by huang zhengguo on 2017/10/18.
//  Copyright © 2017年 huang zhengguo. All rights reserved.
//

import UIKit
import HGCircularSlider

class ManualCircleView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var circleBackgroundView: UIView!
    
    init(frame: CGRect, channelNum: Int, colorArray: [UIColor]?, colorPercentArray: [Int]?, colorTitleArray: [String]?) {
        super.init(frame: frame)
        
        // 圆形调光图形背景
        circleBackgroundView = UIView(frame: CGRect(x: 0, y:0, width:frame.size.width, height:frame.size.width))
        circleBackgroundView.backgroundColor = UIColor.green
        
        // 根据通道数量添加圆形调光
        let centerCircleWidth = 55
        let circleLineWidth = 20
        var progressView: CircularSlider?
        for i in 0 ..< channelNum {
            progressView = CircularSlider(frame: CGRect(x: 0.0, y:0.0, width: Double(centerCircleWidth + 2 * circleLineWidth * (i + 1)), height: Double(centerCircleWidth + 2 * circleLineWidth * (i + 1))))
            
            progressView?.layer.zPosition = CGFloat(channelNum - i)
            progressView?.lineWidth = 20
            progressView?.trackColor = UIColor.red
            progressView?.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
            circleBackgroundView.addSubview(progressView!)
        }
        
        self.addSubview(circleBackgroundView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}





























