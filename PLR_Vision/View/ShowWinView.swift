//
//  ShowWinView.swift
//  PLR_Vision
//
//  Created by Nathan Yu on 2020/4/14.
//  Copyright © 2020 NathanYu. All rights reserved.
//

import Cocoa

class ShowWinView: NSView {
    
    var leftView: PlateDetailView!
    var rightView: PlateDetailView!
    var centerView: PlateDetailView!
    var cacheView: PlateDetailView!
    
    let MaxWidth: CGFloat = 360     
    let MaxHeight: CGFloat = 130
    let nScaleRate: CGFloat = 0.8   // 左右视图缩放比例
    let mScaleRate: CGFloat = 0.6   // 隐藏试图缩放比例
    
    var timer: Timer!
    var isAnimating = false
    
    var plateModels = [PlateInfoModel]()
    var currentIndex = 0    // 轮播图当前显示的模型index


    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.wantsLayer = true
        self.layer?.cornerRadius = 20
        self.layer?.backgroundColor = CGColor(red: 249 / 255, green: 60 / 255, blue: 26 / 255, alpha: 0.6)
        
        setupViews()
    }
    
    
    // MARK: - animation
    func setupViews() {
        
        if leftView == nil {
            leftView = PlateDetailView(frame: NSRect(x: -228, y: 23, width: MaxWidth * nScaleRate, height: MaxHeight * nScaleRate))
            addSubview(leftView)
        }
        
        if centerView == nil {
            centerView = PlateDetailView(frame: NSRect(x: 120, y: 10, width: MaxWidth, height: MaxHeight))
            addSubview(centerView)
        }

        if rightView == nil {
            rightView = PlateDetailView(frame: NSRect(x: 540, y: 23, width: MaxWidth * nScaleRate, height: MaxHeight * nScaleRate))
            addSubview(rightView)
        }
        
        if cacheView == nil {
            cacheView = PlateDetailView(frame: NSRect(x: 900, y: 40, width: MaxWidth * mScaleRate, height: MaxHeight * mScaleRate))
            addSubview(cacheView)
        }
    }
    
    // 开启轮播动画
    func startAnimation() {
        if !isAnimating {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.slideAnimation), userInfo: nil, repeats: true)
                self.timer.fire()
            }
        }
    }
    
    // 停止动画
    func stopAnimation() {
        
        // 关闭定时器
        timer.invalidate()
        
        // 更新当前动画状态
        isAnimating = false
        
        // 清空缓存模型
        self.plateModels.removeAll()
        currentIndex = 0
    }
    
    // 更新模型
    func updateModels(models: [PlateInfoModel]) {
        self.plateModels = models
        
        // 开启动画
        startAnimation()
    }
    
    // 轮播动画
    @objc func slideAnimation() {
        
        if self.plateModels.count > 0 && currentIndex < self.plateModels.count {
               // 设置左右视图的内容
               rightView.updateUI(plateModel: plateModels[currentIndex])
               
               NSAnimationContext.runAnimationGroup({ (context) in
                   context.duration = 0.5
                   context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            
                   leftView.animator().setFrameOrigin(NSPoint(x: -500, y: 40))
                   leftView.animator().setFrameSize(NSSize(width: MaxWidth * mScaleRate, height: MaxHeight * mScaleRate))
                   
                   centerView.animator().setFrameOrigin(NSPoint(x: -228, y: 23))
                   centerView.animator().setFrameSize(NSSize(width: MaxWidth * nScaleRate, height: MaxHeight * nScaleRate))
                   
                   rightView.animator().setFrameOrigin(NSPoint(x: 120, y: 10))
                   rightView.animator().setFrameSize(NSSize(width: MaxWidth, height: MaxHeight))
                   
                   cacheView.animator().setFrameOrigin(NSPoint(x: 540, y: 23))
                   cacheView.animator().setFrameSize(NSSize(width: MaxWidth * nScaleRate, height: MaxHeight * nScaleRate))
                   
               }) {

                   self.leftView.frame = NSRect(x: 900, y: 40, width: self.MaxWidth * self.mScaleRate, height: self.MaxHeight * self.mScaleRate)
                   
                   let tempCenter = self.centerView     // 此时移到 leftView
                   let tempLeft = self.leftView         // 此时移到 最左侧
                   let tempRight = self.rightView       // 此时移到 centerView
                   let tempCache = self.cacheView       // 此时移到 rightView

                   self.centerView = tempRight
                   self.leftView = tempCenter
                   self.rightView = tempCache
                   self.cacheView = tempLeft
                   
                   self.currentIndex += 1
               }
        }
    }
    
    
}
