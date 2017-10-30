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
    
    typealias circleSliderPassValueType = (Int, Int) -> Void
    var passColorValueCallback: circleSliderPassValueType?
    var progressViewArray: [CircularSlider]! = [CircularSlider]()
    
    init(frame: CGRect, channelNum: Int!, colorArray: [UIColor]!, colorPercentArray: [Int]!, colorTitleArray: [String]!) {
        super.init(frame: frame)
        
        self.frame = frame
        
        // 根据通道数量添加圆形调光
        let centerCircleWidth = CGFloat(60)
        let circleLineWidth = CGFloat(frame.size.width - CGFloat(centerCircleWidth)) / CGFloat(channelNum * 2)
        var progressView: CircularSlider?
        var progressViewCenter:CGPoint? = nil
        for i in 0 ..< channelNum {
            progressView = CircularSlider(frame: CGRect(x: 0.0, y:0.0, width: Double(centerCircleWidth + CGFloat(2 * (channelNum - i)) * circleLineWidth), height: Double(centerCircleWidth + CGFloat(2 * (channelNum - i)) * circleLineWidth)))
            
            progressView?.tag = 1000 + i
            progressView?.minimumValue = 0.0
            progressView?.maximumValue = 1000
            progressView?.layer.zPosition = CGFloat(i)
            progressView?.lineWidth = circleLineWidth
            progressView?.backtrackLineWidth = circleLineWidth
            progressView?.backgroundColor = UIColor.clear
            progressView?.endThumbTintColor = colorArray[i]
            progressView?.endThumbStrokeColor = UIColor.gray
            progressView?.trackColor = colorArray[i]
            progressView?.layer.cornerRadius = (progressView?.frame.size.width)! / 2;
            progressView?.clipsToBounds = true
            progressView?.layer.masksToBounds = true
            
            if progressViewCenter != nil {
                progressView?.center = progressViewCenter!
            } else {
                progressView?.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: (progressView?.center.y)!)
            }
            
            progressView?.addTarget(self, action: #selector(colorValueChanged(view:)), for: UIControlEvents.valueChanged)
            
            progressViewArray?.append(progressView!)
            self.addSubview(progressView!)
            
            progressViewCenter = progressView?.center
        }
        
        updateManualCircleView(colorPercentArray: colorPercentArray)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for progressView in self.progressViewArray {
            if touchPointInsideCircle(center: progressView.center, radius: progressView.layer.cornerRadius + progressView.lineWidth / 2.0, point: point) && touchPointOutsideCircle(center: progressView.center, radius: progressView.layer.cornerRadius - progressView.lineWidth / 2.0, point: point) {
                return progressView
            }
        }
        return nil
    }
    
    func touchPointInsideCircle(center: CGPoint, radius: CGFloat, point: CGPoint) -> Bool {
        let x = (point.x - center.x) * (point.x - center.x)
        let y = (point.y - center.y) * (point.y - center.y)
        let dist: CGFloat  = CGFloat(sqrtf(Float(x + y)))
        return (dist <= radius)
    }
    
    func touchPointOutsideCircle(center: CGPoint, radius: CGFloat, point: CGPoint) -> Bool {
        let x = (point.x - center.x) * (point.x - center.x)
        let y = (point.y - center.y) * (point.y - center.y)
        let dist: CGFloat  = CGFloat(sqrtf(Float(x + y)))
        return (dist > radius)
    }
    
    @objc func colorValueChanged(view: UIView) -> Void {
        let progressView: CircularSlider! = view as! CircularSlider;
    
        if passColorValueCallback != nil {
            passColorValueCallback!(progressView.tag - 1000, Int(progressView.endPointValue))
        }
    }
    
    func updateManualCircleView(colorPercentArray: [Int]!) -> Void {
        for i in 0 ..< colorPercentArray.count {
            progressViewArray![i].endPointValue = CGFloat(colorPercentArray[i])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}





























