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
    
    var plateModels: [PlateInfoModel]!
    
    

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.wantsLayer = true
        self.layer?.cornerRadius = 20
        self.layer?.backgroundColor = CGColor(red: 249 / 255, green: 60 / 255, blue: 26 / 255, alpha: 0.6)
        
        
        setupViews()
        
    }
    
    
    // MARK: - animation
    func setupViews() {
        
        leftView = PlateDetailView(frame: NSRect(x: -228, y: 23, width: MaxWidth * nScaleRate, height: MaxHeight * nScaleRate))
        addSubview(leftView)
        
        centerView = PlateDetailView(frame: NSRect(x: 120, y: 10, width: MaxWidth, height: MaxHeight))
        addSubview(centerView)
        
        rightView = PlateDetailView(frame: NSRect(x: 540, y: 23, width: MaxWidth * nScaleRate, height: MaxHeight * nScaleRate))
        addSubview(rightView)
        
        cacheView = PlateDetailView(frame: NSRect(x: 900, y: 40, width: MaxWidth * mScaleRate, height: MaxHeight * mScaleRate))
        addSubview(cacheView)
        
    }
    
    func startAnimation() {
        
        slideAnimation()
        
    }
    
    func stopAnimation() {
        
    }
    
    
    func slideAnimation() {
        
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.55
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
     
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
            
        }
    }
    
}
